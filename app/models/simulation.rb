class Simulation < ActiveRecord::Base
  has_many :packets
  validates :name, :method, :loss_probability, :length_avg, :length_dev, :total_packets, presence: true
  SEGMENT_SIZE = 50
  BANDWIDTH = 100
  SEGMENT_HEADER_SIZE = 20

  class << self
    def available_methods
      ['SELECTIVE_REPEAT', 'GO_BACK_N', 'NEGATIVE_ACKNOWLEDGEMENT']
    end

    def technologies
      { cable: 0.05, wireless: 0.1, satellite: 0.15 }
    end

    def demand
      { domestic: { avg: 50, dev: 5 }, corporation: { avg: 150, dev: 20 }, server: { avg: 300, dev: 50 } } 
    end

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
    gaussian(self.length_avg, self.length_dev)
  end

  def random_arrival_time
    #Random.rand(0..self.lambda)
    poisson(self.lambda)
  end

  def self.transmission_time(size)
    (size.to_f / Simulation::BANDWIDTH).ceil
  end

  def complete?
    self.packets.find_all{|p| p.sent?}.size == self.packets.size
  end

  private
    def gaussian(mean, stddev)
      theta = 2 * Math::PI * Random.rand
      rho = Math.sqrt(-2 * Math.log(1 - Random.rand))
      scale = stddev * rho
      x = mean + scale * Math.cos(theta)
      y = mean + scale * Math.sin(theta)
      return x
    end

    def poisson(lambda) 
      l = Math::E**(-lambda)
      k = 0
      p = 1
      while p > l
        k += 1
        u = Random.rand
        p *= u
      end
      k -1
    end
end
