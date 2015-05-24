require 'socket'
require 'zlib'

#for connect,
#  1) client sends connect request, retries in case packet is lost
#  2) server sends uniq hash,

#  3) client constructs something only the client would know and sends it back
#detecting disconnect - nothing for x time

module Communications
  class Session
    def initialize(port=33333, ip='0.0.0.0')
      @sequence_no = 0
      @sent_packets = UDPPacketBuffer.new
      @received_packets = UDPPacketBuffer.new
      @socket = UDPSocket.new
      @socket.bind(ip, port)
      @protocol_id = [Zlib.adler32('yugioh'.encode('ASCII-8BIT'))].pack('N')
    end
    #http://spin.atomicobject.com/2013/09/30/socket-connection-timeout-ruby/
    #http://packetlife.net/blog/2010/jun/7/understanding-tcp-sequence-acknowledgment-numbers/
    #http://stackoverflow.com/questions/9853516/set-socket-timeout-in-ruby-via-so-rcvtimeo-socket-option
    def connect(ip='127.0.0.1', port=33333, timeout=5)
      time = Time.now

      send('')
      until Time.now - time > timeout do
        @packet = receive_nonblock.select do |packet|
          [packet[1][3], packet[1][1]] == [ip, port] &&
          packet[0][0..3] == @protocol_id
        end.first
      end

      if @packet.nil?
        false
      else
        @addr = [ip, port]
        true
      end
    end

    def send(ascii8bit_content)
      @sequence_no += 1

      if @received_packets.all.empty?
        packet = UDPPacket.new(@protocol_id, @sequence_no, 0, [], ascii8bit_content.bytesize, ascii8bit_content)
      else
        packet = UDPPacket.new(@protocol_id,
                               @sequence_no,
                               @received_packets.last_received.first.sequence_no,
                               @received_packets.last_received(33).take(32).collect(&:sequence_no),
                               ascii8bit_content.bytesize,
                               ascii8bit_content)
      end
      packet.sent_time = Time.now
      @sent_packets << packet

      @socket.send(packet.raw_payload, 0, '127.0.0.1', 33333)
    end

    def receive_nonblock
      begin
        while true do
          raw_packet = @socket.recvfrom_nonblock(1024)

          if correct_protocol?(raw_packet[0])
            packet = UDPPacket.new_from(raw_packet)

            if packet.contains_acks?
              packet.acks do |ack|
                sent_packet = @sent_packets.find(ack)
                sent_packet.received_ack_time = Time.now if sent_packet.received_ack_time.nil?
              end
            end

            @received_packets << packet
          end
        end
      rescue IO::WaitReadable
      end
    end

    def sent
      @sent_packets
    end

    def received
      @received_packets
    end

    def close
      @socket.close
    end

    private
    def correct_protocol?(payload)
      payload[0..3] == @protocol_id
    end
  end
end
