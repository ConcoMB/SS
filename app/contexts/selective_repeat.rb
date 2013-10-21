class SelectiveRepeat < RetransmissionMethod
 
  def ack
    @packet.unacked_segments.reduce(0) do |time, segment|
      rand = Random.rand
      rand > @simulation.loss_probability ? segment.ack = true : segment.increment(:losts)
      segment.increment(:transmitted, Simulation::SEGMENT_HEADER_SIZE)
      segment.save!
      time + Simulation.transmission_time(Simulation::SEGMENT_HEADER_SIZE)
    end
  end

end