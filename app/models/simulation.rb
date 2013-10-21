class Simulation < ActiveRecord::Base
  has_many :packets
  validates :name, :method, :loss_probability, :length_avg, :length_dev, :total_packets, presence: true
  SEGMENT_SIZE = 50
  BANDWIDTH = 100
  SEGMENT_HEADER_SIZE = 20

  def self.available_methods
    ['SELECTIVE_REPEAT', 'GO_BACK_N', 'NEGATIVE_ACKNOWLEDGEMENT']
  end

  validates :method, inclusion: { in: self.available_methods }

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

  def next_packet
    packets.order(:number).detect { |p| !p.sent? }
  end

  def random_packet_size
    self.length_avg + Random.rand((0-self.length_dev)..self.length_dev)
  end

  def random_arrival_time
    Random.rand(0..self.lambda)
  end

  def self.transmission_time(size)
    (size.to_f / Simulation::BANDWIDTH).ceil
  end

  def complete?
    self.packets.find_all{|p| p.sent?}.size == self.packets.size
  end

end
