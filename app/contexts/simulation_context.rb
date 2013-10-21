class SimulationContext

  def initialize(simulation)
    @simulation = simulation
    @time = 0
  end

  def handle
    @simulation.packets.destroy_all
    @simulation.feed_packets
    @simulation.packets.order(:number).each do |p|
      @time = [p.arrival, @time].max
      send_packet(p)
    end
  end

  def send_packet(packet)
    until packet.sent?
      send_segments(packet.unsent_segments)
      @time += get_method.new(@simulation, packet).ack
    end
  end

  def send_segments(segments)
    segments.each do |segment|
      @time += Simulation.transmission_time(Simulation::SEGMENT_SIZE)

      rand = Random.rand
      if rand > @simulation.loss_probability
        segment.sent = true
        segment.sent_time = @time
      else
        segment.increment(:losts)
      end
      
      segment.increment(:transmitted, Simulation::SEGMENT_SIZE)
      segment.save!
    end
  end

  def get_method
    @simulation.method.downcase.camelize.constantize
  end

end