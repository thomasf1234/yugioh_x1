require 'socket'
require 'json'

module Communications
  class Input
    def initialize
      BasicSocket.do_not_reverse_lookup = true
      @socket = UDPSocket.new
      @socket.bind('0.0.0.0', 33333)
      @protocol_id = [Zlib.adler32('yugioh')].pack('L')
    end

    #def gets
    #  if @sequence_no.nil?
    #    payload = receive_packet['payload']
    #    @sequence_no = payload['sequence_no']
    #  else
    #    while true do
    #      payload = receive_packet['payload'] # if this number is too low it will drop the larger packets and never give them to you
    #
    #      if payload['sequence_no'] > @sequence_no
    #        @sequence_no = payload['sequence_no']
    #        break
    #      end
    #    end
    #  end
    #
    #  payload
    #end

    def receive_nonblock
      payloads = []
      begin
        while true do
          raw_payload = @socket.recvfrom_nonblock(1024)
          payloads << raw_payload[0][4..-1] if raw_payload[0][0..3] == @protocol_id
        end
      rescue IO::WaitReadable
      end
      payloads
    end

    def close
      @socket.close
    end
  end
end
