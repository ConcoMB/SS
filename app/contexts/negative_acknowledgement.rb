class NegativeAcknowledgement < RetransmissionMethod
  def ack
    @simulation.unsent_segments.each do |segment|
      # TODO
    end
  end
end