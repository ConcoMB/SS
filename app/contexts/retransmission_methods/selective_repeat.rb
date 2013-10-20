def SelectiveRepeat < RetransmissionMethod
  def ack
    @simulation.unacked_segments.each do |segment|
      rand = Random.rand
      if rand > @simulation.loss_probability
        segment.ack = true
      else
        segment.increment(:lost)
      end
      segment.increment(:transmitted, @simulation.segment_header_size)
      segment.save!
    end
  end
end