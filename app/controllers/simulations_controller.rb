class SimulationsController < ApplicationController
  inherit_resources

  def simulate
    @simulation = Simulation.find(params[:id])
    SimulationContext.new(@simulation).handle
  end

  def results
    @simulation = Simulation.find(params[:id])
    times = @simulation.packets.map {|p| p.sent_time}
    ratios = @simulation.packets.map do |p| 
      p.segments.size.to_f / p.segments.reduce(p.segments.size) { |x, s| x + s.losts } 
    end
    render json: {times: times, ratios: ratios}
  end

  def state
    @simulation = Simulation.find(params[:id])
    data = @simulation.packets.where("arrival <= ?", params[:time]).reduce({segments: {arrived: 0, sent:0, lost: 0}, packets: {arrived: 0, sent: 0}}) do |info, p|
      losts = p.segments.sum(:losts)
      info[:segments][:lost] += losts
      info[:segments][:sent] += losts + p.segments.size
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
end
