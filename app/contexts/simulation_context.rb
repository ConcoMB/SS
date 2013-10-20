class SimulateContext

  def initialize(simulation)
    @simulation = simulation
	end

	def handle
    @simulation.clear_packets
    @simulation.feed_packets
    time = 0
    while @simulation.complete?
      p = Simulation.next_packet
      time = Math.max(p.arrival, time)
      send_packet(packet)
    end
	end

  def send_packet(packet)
    until p.sent?
      send(p.unsent_segments)
      ack_time = get_method.new(@simulation).ack
    end
  end

  def send(segments)
    segments.each do |segment|
      transmission_time = @simulation.segment_size * @simulation.bandwidth
      @time += transmission_time

      rand = Random.rand
      if rand > @simulation.loss_probability
        segment.sent = true
        segment.sent_time = @time
      else
        segment.increment(:losts)
      end
      
      segment.increment(:transmitted, @simulation.segment_size)
      segment.save!
    end
  end

  def get_method
    @simulation.method.camelize.constantize
  end

end