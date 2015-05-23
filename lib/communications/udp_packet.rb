require 'zlib'

module Communications
  class UDPPacket
    attr_accessor :sent_time, :received_ack_time
    attr_reader :protocol_id, :sequence_no, :ack, :previous_acks, :content_bytesize, :content, :addr

    class << self
      def new_from(raw_packet)
        new(*decode(raw_packet))
      end

      private
      def decode(raw_packet)
        protocol_id = raw_packet[0][0..3]
        sequence_no = raw_packet[0][4..5].unpack('n').first
        ack = raw_packet[0][6..7].unpack('n').first
        previous_acks = extract_acks(ack, raw_packet[0][8..11].unpack('B*').first)
        content_bytesize = raw_packet[0][12..13].unpack('n').first
        content = raw_packet[0][14..(13+content_bytesize)]
        addr = raw_packet[1]

        [protocol_id, sequence_no, ack, previous_acks, content_bytesize, content, addr]
      end

      #returns the acks from ack_bitfield
      def extract_acks(ack, ack_bitfield)
        acks = []

        for i in (0..(ack_bitfield.length-1))
          if ack_bitfield[i] == '1'
            acks << ack - (i + 1)
          end
        end
        acks
      end
    end

    def initialize(protocol_id, sequence_no, ack, previous_acks, content_bytesize, content, addr=nil)
      @protocol_id = protocol_id
      @sequence_no = sequence_no
      @ack = ack
      @previous_acks = previous_acks
      @content = content
      @content_bytesize = content_bytesize
      @addr = addr
    end

    def raw_payload
      @protocol_id +
      [@sequence_no].pack('n') +
      [@ack].pack('n') +
      [ack_bitfield].pack('N') +
      [@content_bytesize].pack('n') +
      @content.encode('ASCII-8BIT')
    end

    def rtt
      received_ack_time.nil? ? nil : (received_ack_time - sent_time)
    end

    private
    def ack_bitfield
      (1..32).to_a.collect do |i|
        ([@ack - i] & @previous_acks).empty? ? 0 : 1
      end.join.to_i(2)
    end
  end
end
