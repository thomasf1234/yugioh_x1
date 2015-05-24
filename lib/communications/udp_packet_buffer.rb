module Communications
  class UDPPacketBuffer
    LOST = 30
    MAX = 5000

    def initialize(max=MAX)
      @max = max
      @udp_packets = []
    end

    def all
      @udp_packets
    end

    def find(sequence_no)
      @udp_packets.detect { |packet| packet.sequence_no == sequence_no }
    end

    def update(sequence_no, params)
      udp_packet = @udp_packets.detect do |udp_packet|
        udp_packet.sequence_no == sequence_no
      end

      params.each do |attr, value|
        udp_packet.send("#{attr}=", value)
      end

      true
    end

    def flush
      copy = @udp_packets.dup
      @udp_packets.clear
      copy
    end

    def <<(udp_packet)
      if !full?
        @udp_packets << udp_packet
      elsif udp_packet.sequence_no > @udp_packets.first.sequence_no
        @udp_packets.delete_at(0) && @udp_packets << udp_packet
      end

      @udp_packets.sort_by!(&:sequence_no)
      self
    end

    def full?
      @udp_packets.count == @max
    end

    def lost
      @udp_packets.select do |udp_packet|
        udp_packet.received_ack_time.nil? && udp_packet.sent_time < Time.now - LOST
      end
    end

    #def lost
    #  borderline_packet = @udp_packets.reverse.detect do |udp_packet|
    #    udp_packet.received_time < Time.now - LOST
    #  end
    #
    #  missing_sequence_numbers = (1..borderline.sequence_no).to_a - @udp_packets.select do |udp_packet|
    #    udp_packet.sequence_no < reference_packet.sequence_no
    #  end
    #
    #  missing_sequence_numbers.collect {|sequence_no| Communications::UDPPacket.new(nil, sequence_no, nil, nil, nil, nil, {})}
    #end
  end
end
