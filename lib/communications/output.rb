require 'socket'
require 'json'

module Communications
  class Output
    def broadcast(hash)
      @socket = UDPSocket.new
      @socket.send(hash.to_json, 0, '127.0.0.1', 33333)
      @socket.close
    end
  end
end
