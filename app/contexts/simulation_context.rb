class SimulateContext

  def initialize(simulation)
    @simulation = simulation
	end

	def handle
    @simulation.clear
    @simulation.feed_packets
    while @simulation.complete?
      p = Simulation.next_packet
      send_packet(packet)
    end
	end

  def send_packet(packet)
    until p.sent?
      send(p.unsent_segments)
      get_method.new(@simulation).ack
    end
  end

  def send(segments)
    segments.each do |segment|
      rand = Random.rand
      segment.update_attributes!(sent: rand > @simulation.loss_probability)
    end
  end

  def get_method
    @simulation.method.camelize.constantize
  end

end