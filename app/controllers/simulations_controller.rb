class SimulationsController < ApplicationController
  inherit_resources

  def simulate
    @simulation = Simulation.find(params[:id])
    SimulationContext.new(@simulation).handle
    render nothing: true, status: :ok
  end

  def timeline
    @simulation = Simulation.find(params[:id])
  end

  def final
    @simulation = Simulation.find(params[:id])
  end

  def results
    @simulation = Simulation.find(params[:id])
    times = simulation_times(@simulation)
    ratios = packet_ratios(@simulation.packets, @simulation.method)
    puts ratios
    ratios_groups = group_ratios(ratios)
    time_mean = (times.reduce(:+).to_f/times.size).round(4)
    ratio_mean = (ratios.reduce(:+).to_f/ratios.size).round(4)
    @simulation.update_attributes(time_mean: time_mean,
      ratio_mean: ratio_mean,
      time_min: times.min,
      time_max: times.max,
      ratio_min: ratios.min,
      ratio_max: ratios.max)
    render json: {times: times, ratios: ratios_groups, time_mean: time_mean, ratio_mean: ratio_mean, time_max: times.max, time_last: times.last}
  end

  def state
    @simulation = Simulation.find(params[:id])
    time = params[:time].to_f
    # sent_packets = []
    times = []
    packets = @simulation.packets.where("arrival <= ?", time)
    data = packets.reduce({bufferSize: 0, segments: {arrived: 0, sent:0, lost: 0}, packets: {arrived: 0, sent: 0}}) do |info, p|
      losts = p.segments.sum(:losts)
      info[:segments][:lost] += losts
      info[:segments][:sent] += losts + p.segments.size + method_ack_count(@simulation.method, p.segments.size)
      info[:segments][:arrived] += p.segments.size
      if p.sent_time + p.arrival < time
        info[:packets][:sent] += 1 
        times << p.sent_time
      else
        info[:bufferSize] += 1
      end
      info[:packets][:arrived] += 1
      info
    end
    # ratios = packet_ratios(sent_packets, @simulation.method)
    # ratios_groups = group_ratios(ratios)
    render json: {state: data, times: times}
  end

  def compare
    @simulations = Simulation.find(params[:simulation_ids])
  end

  def compare_data
    @simulations = Simulation.find(params[:simulation_ids])
    data = {time: {}, ratio:{}}
    Simulation.available_methods.each do |method|
      data[:time][method.underscore] = []
      data[:ratio][method.underscore] = []
      Simulation.technologies.each do |t, p|
        matched = @simulations.select {|s| s.method == method && s.technology == t}.first
        time_min = matched.nil? ? 0 : matched.time_min
        ratio_min = matched.nil? ? 0 : matched.ratio_min
        time_max = matched.nil? ? 0 : matched.time_max
        ratio_max = matched.nil? ? 0 : matched.ratio_max
        data[:time][method.underscore] << [time_min, time_max]
        data[:ratio][method.underscore] << [ratio_min.round(2), ratio_max.round(2)]
      end
    end
    data[:simulations] = @simulations
    render json: data
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:simulation).permit(:name, :method, :loss_probability, :lambda, :length_avg, :length_dev, :total_packets)]
    end

    def method_ack_count(method, size)
      case method
      when 'SELECTIVE_REPEAT'
        size
      when 'NEGATIVE_ACKNOWLEDGEMENT'
        (size * Random.rand).ceil
      when 'GO_BACK_N'
        1
      end
    end

    def packet_ratios(packets, method)
      packets.map do |p|
        count = p.segments.size * (Simulation::SEGMENT_SIZE + Simulation::SEGMENT_HEADER_SIZE)
        acks = method_ack_count(method, p.segments.size) * Simulation::SEGMENT_HEADER_SIZE
        1 - (count.to_f / (count + acks + p.segments.sum(:losts) * Simulation::SEGMENT_HEADER_SIZE))
      end
    end

    def simulation_times(simulation)
      simulation.packets.map {|p| p.sent_time}
    end

    def group_ratios(ratios)
      ratios_groups = ratios.reduce({ "10%" => 0, "20%" => 0, "30%" => 0, "40%" => 0, "50%" => 0, "60%" => 0, "70%" => 0, "80%" => 0, "90%" => 0, "100%" => 0 }) do |m, r|
        percent = ((r*10).ceil * 10).to_i
        puts percent
        m["#{percent}%"] += 1
        m
      end
      ratios_groups.map { |k, v| [k, v.to_f / @simulation.total_packets] }.select { |a| a.last > 0 }
    end
end
