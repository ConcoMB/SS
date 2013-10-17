class Simulation < ActiveRecord::Base
  validates :name, :method, :loss_probability, :length_avg, :length_dev, presence: true

  def self.available_methods
    ['SELECTIVE_REPEAT', 'GO_BACK_N', 'NEGATIVE_ACKNOWLEDGEMENT']
  end

  validates :method, inclusion: { in: self.available_methods }

  def unsent_segments
    segments.where(sent: false)
  end

  def unacked_segments
    segments.where(sent: true, ack: false)
  end
end
