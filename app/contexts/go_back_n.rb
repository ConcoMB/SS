class GoBackN < RetransmissionMethod
  def ack
    segments = self.consecutive_segments
    rand = Random.rand
    last = segments.order('number ASC').last
    return 0 if last.nil?
    if rand > @simulation.loss_probability
      segments.each { |segment| segment.update_attributes!(ack: true) }
    else
      last.increment(:losts)
    end
    last.increment(:transmitted, Simulation::SEGMENT_HEADER_SIZE)
    last.save!
    Simulation.transmission_time(Simulation::SEGMENT_HEADER_SIZE)
  end

  protected
    def consecutive_segments
      puts "PACKET? #{@packet.sent?}"
      missing_segment = @packet.unsent_segments.order('number ASC').first
      return @packet.unacked_segments if missing_segment.nil?
      puts "MISSING SEGMENT #{missing_segment.number}"
      @packet.unacked_segments.where("number < ?", missing_segment.number)
    end
end