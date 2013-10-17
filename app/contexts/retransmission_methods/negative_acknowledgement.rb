def NegativeAcknowledgement
  def self.ack
    segments.each do |segment|
      rand = Random.rand
      segment.update_attributes!(ack: rand > @simulation.loss_probability)
    end
  end
end