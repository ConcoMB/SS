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
      count = p.segments.size
      acks = method_ack_count(@simulation.method, count)
      count.to_f / p.segments.reduce(count + acks) { |x, s| x + s.losts } 
    end
    time_mean = (times.reduce(:+).to_f/times.size).round(4)
    ratio_mean = (ratios.reduce(:+).to_f/ratios.size).round(4)
    @simulation.update_attributes(time_mean: time_mean, ratio_mean: ratio_mean)
    render json: {times: times, ratios: ratios, time_mean: time_mean, ratio_mean: ratio_mean}
  end

  def state
    @simulation = Simulation.find(params[:id])
    packets = @simulation.packets.where("arrival <= ?", params[:time])
    data = packets.reduce({segments: {arrived: 0, sent:0, lost: 0}, packets: {arrived: 0, sent: 0}}) do |info, p|
      losts = p.segments.sum(:losts)
      info[:segments][:lost] += losts
      info[:segments][:sent] += losts + p.segments.size + method_ack_count(@simulation.method, p.segments.size)
      info[:segments][:arrived] += p.segments.size
      info[:packets][:sent] += 1 if p.sent?
      info[:packets][:arrived] += 1
      info
    end
    render json: {state: data}
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
