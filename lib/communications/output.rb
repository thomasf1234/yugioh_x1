require 'socket'
require 'zlib'

#for connect,
#  1) client sends connect request, retries in case packet is lost
#  2) server sends uniq hash,

#  3) client constructs something only the client would know and sends it back
#detecting disconnect - nothing for x time

module Communications
  class Output
    def initialize
      @sequence_no = 0
      @sent = []
      @received = []
      @socket = UDPSocket.new
      @socket.bind('0.0.0.0', 33334)
      @protocol_id = [Zlib.adler32('yugioh'.encode('ASCII-8BIT'))].pack('N')
    end
    #http://spin.atomicobject.com/2013/09/30/socket-connection-timeout-ruby/
    #http://packetlife.net/blog/2010/jun/7/understanding-tcp-sequence-acknowledgment-numbers/
    #http://stackoverflow.com/questions/9853516/set-socket-timeout-in-ruby-via-so-rcvtimeo-socket-option
    def connect(ip='127.0.0.1', port=33333, timeout=5)
      time = Time.now

      send(@protocol_id + [@sequence_no].pack('n'))
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

    def send(payload)
      @sequence_no += 1
      packet = UDPPacket.new(@protocol_id, @sequence_no, @ack, @ack_bitfield, payload)
      payload = @protocol_id + [@sequence_no].pack('n') + [@ack].pack('n') + [@ack_bitfield].pack('N') + payload.encode('ASCII-8BIT')

      @rtt[@sequence_no] = {send_time: Time.now, duration: nil}
      @socket.send(payload, 0, '127.0.0.1', 33333)
    end

    def receive_nonblock
      payloads = []

      begin
        while true do
          raw_payload, addr = UDPPacket.new_from(@socket.recvfrom_nonblock(1024))

          if correct_protocol?(raw_payload)
            decoded_payload = decode(raw_payload)
            #raise SocketError.new("ack does not match sequence_no") if
            payloads << decoded_payload[:payload]
            @acks << decoded_payload[:ack] && @acks.shift if @acks.count > 5000
            @rtt[@sequence_no][:duration] = Time.now - @rtt[@sequence_no][:send_time]
          end
        end
      rescue IO::WaitReadable
      end
      payloads
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
