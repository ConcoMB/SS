class NegativeAcknowledgement < RetransmissionMethod
  def ack
  	@packet.segments.each {|s| s.update_attributes!(ack: true)}
    @packet.unsent_segments.reduce(0) do |time, segment|
      rand = Random.rand
      if rand > @simulation.loss_probability
      	#segment.ack = false
      else
      	segment.increment(:losts)
      end
      segment.save!
      time + Simulation.transmission_time(Simulation::SEGMENT_HEADER_SIZE)
    end
  end
end