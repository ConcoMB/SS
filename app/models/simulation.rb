class Simulation < ActiveRecord::Base
  has_many :packets
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

  def clear
    packets.destroy_all!
  end

  def feed_packets
    time = 0
    total_packets.times do |n|
      time += random_arrival_time
      self.packets << Packet.new(number: n, size: random_packet_size, arrival: time)
    end
  end

  def random_packet_size
    self.length_avg + Random.rand((0-self.length_dev)..self.length_dev)
  end

  def random_arrival_time
    Random.rand(0..self.lambda)
  end

  def complete?
    self.packets.where(sent: true).size == self.packets.size
  end
end
