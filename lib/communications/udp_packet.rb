require 'zlib'

module Communications
  class UDPPacket
    attr_accessor :sent_time, :received_time, :received_ack_time
    attr_reader :protocol_id, :sequence_no, :ack, :previous_acks, :content_bytesize, :content, :addr, :flags

    module Flags
      INITIAL = :initial
      TERMINATE = :terminate
      SYN = :syn
      ACK = :ack
      ALL = [INITIAL, TERMINATE, SYN, ACK, 0, 0, 0, 0]
    end

    class << self
      def new_from(raw_packet)
        new(*decode(raw_packet))
      end

      private
      def decode(raw_packet)
        protocol_id = raw_packet[0][0..3]
        flags = extract(raw_packet[0][4]) { |i| Flags::ALL[i] }
        sequence_no = raw_packet[0][5..6].unpack('n').first
        ack = raw_packet[0][7..8].unpack('n').first
        previous_acks = extract(raw_packet[0][9..12]) { |i| ack - (i + 1) }
        content_bytesize = raw_packet[0][13..14].unpack('n').first
        content = raw_packet[0][15..(14+content_bytesize)]
        addr = raw_packet[1]

        [protocol_id, sequence_no, ack, previous_acks, content_bytesize, content, addr, flags]
      end

      def extract(bitfield)
        binary_string = bitfield.unpack('B*').first
        array = []

        for i in (0..(binary_string.length-1))
          if binary_string[i] == '1'
            array << yield(i)
          end
        end
        array
      end
    end

    def initialize(protocol_id, sequence_no, ack, previous_acks, content_bytesize, content, addr=nil, flags=[])
      @protocol_id = protocol_id
      @flags = Set.new(flags)
      (@sequence_no = sequence_no) && @flags << Flags::SYN
      (@ack = ack) && @flags << Flags::ACK
      (@previous_acks = previous_acks) && @flags << Flags::ACK
      @content = content
      @content_bytesize = content_bytesize
      @addr = addr
    end

    def raw_payload
      @protocol_id +
      flag_bitfield +
      [@sequence_no].pack('n') +
      [@ack].pack('n') +
      ack_bitfield +
      [@content_bytesize].pack('n') +
      @content.encode('ASCII-8BIT')
    end

    def flag_bitfield
      [Flags::ALL.collect do |flag|
        (@flags & [flag]).empty? ? 0 : 1
      end.join.to_i(2)].pack('C')
    end

    def acks
      previous_acks << ack
    end

    def contains_acks?
      acks != [0]
    end

    def rtt
      received_ack_time.nil? ? nil : (received_ack_time - sent_time)
    end

    private
    def ack_bitfield
      [(1..32).to_a.collect do |i|
        ([@ack - i] & @previous_acks).empty? ? 0 : 1
      end.join.to_i(2)].pack('N')
    end
  end
end
