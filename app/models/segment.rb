class Segment < ActiveRecord::Base

  belongs_to :packet

  after_initialize :init

  def init
    self.ack ||= false
    self.sent ||= false
    self.losts ||= 0
    self.transmitted ||= 0
  end
     
end
