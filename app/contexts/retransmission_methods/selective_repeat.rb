def SelectiveRepeat << RetransmissionMethod
  def self.ack
    @simulation.unacked_segments.each do |segment|
      rand = Random.rand
      segment.update_attributes!(ack: rand > @simulation.loss_probability)
    end
  end
end