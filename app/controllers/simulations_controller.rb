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
    times = @simulation.packets.map {|p| p.sent_time}
    ratios = @simulation.packets.map do |p|
      count = p.segments.size * (Simulation::SEGMENT_SIZE + Simulation::SEGMENT_HEADER_SIZE)
      acks = method_ack_count(@simulation.method, p.segments.size) * Simulation::SEGMENT_HEADER_SIZE
      count.to_f / (count + acks + p.segments.sum(:losts) * Simulation::SEGMENT_HEADER_SIZE)
    end
    ratios_groups = ratios.reduce({ "10%" => 0, "20%" => 0, "30%" => 0, "40%" => 0, "50%" => 0, "60%" => 0, "70%" => 0, "80%" => 0, "90%" => 0, "100%" => 0 }) do |m, r|
      m["#{(r.round(1) * 100).to_i}%"] += 1
      m
    end
    ratios_groups = ratios_groups.map { |k, v| [k, v.to_f / @simulation.total_packets] }.select { |a| a.last > 0 }
    time_mean = (times.reduce(:+).to_f/times.size).round(4)
    ratio_mean = (ratios.reduce(:+).to_f/ratios.size).round(4)
    @simulation.update_attributes(time_mean: time_mean, ratio_mean: ratio_mean)
    render json: {times: times, ratios: ratios_groups, time_mean: time_mean, ratio_mean: ratio_mean, time_max: times.max, time_last: times.last}
  end

  def state
    @simulation = Simulation.find(params[:id])
    time = params[:time].to_f
    packets = @simulation.packets.where("arrival <= ?", time)
    data = packets.reduce({bufferSize: 0, segments: {arrived: 0, sent:0, lost: 0}, packets: {arrived: 0, sent: 0}}) do |info, p|
      losts = p.segments.sum(:losts)
      info[:segments][:lost] += losts
      info[:segments][:sent] += losts + p.segments.size + method_ack_count(@simulation.method, p.segments.size)
      info[:segments][:arrived] += p.segments.size
      info[:packets][:sent] += 1 if p.sent_time + p.arrival < time
      info[:packets][:arrived] += 1
      info[:bufferSize] += 1 if p.sent_time + p.arrival >= time
      info
    end
    render json: {state: data}
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
        matched = @simulations.select {|s| s.method == method && s.technology == t}
        time_mean = matched.empty? ? 0 : matched.map(&:time_mean).mean
        ratio_mean = matched.empty? ? 0 : matched.map(&:ratio_mean).mean
        data[:time][method.underscore] << time_mean
        data[:ratio][method.underscore] << ratio_mean
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
end
