class Packet < ActiveRecord::Base

  belongs_to :simulation
  has_many :segments, dependent: :destroy
  after_create :init

  def init
    (size.to_f / Simulation::SEGMENT_SIZE).ceil.times { |i| segments << Segment.create(number: i) } if segments.empty?
  end

  def sent?
    segments.where(sent: true, ack: true).size == segments.size
  end

  def unsent_segments
    segments.where(sent: false)
  end

  def unacked_segments
    segments.where(sent: true, ack: false)
  end

  def sent_time
    segments.order(:sent_time).last.sent_time - arrival
  end

  class << self
    def sent
      sent_count = joins(:segments).where(segments: {ack:true, sent:true}).count(group: :packet_id)
      total_count = joins(:segments).count(group: :packet_id)
      pids = sent_count.select {|pid, count| count == total_count[pid]}.keys
      where(id: pids)
    end
  end

end
