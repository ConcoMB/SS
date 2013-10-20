def GoBackN < RetransmissionMethod
  def ack
    segments = self.consecutive_segments
    rand = Random.rand
    last = segments.order('number ASC').last
    if rand > @simulation.loss_probability
      segments.each {|segment|segment.update_attributes!(ack: true) }
    else
      last.increment(:losts)
    end
    last.increment(:transmitted, @simulation.segment_header_size)
    last.save!
  end

  private
    def consecutive_segments
      missing_segment = @simulation.unsent_segments.order('number ASC').first.number
      @simulation.unacked_segments.where("number < ?", missing_segment)
    end
end