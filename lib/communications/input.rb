require 'socket'
require 'json'

module Communications
  class Input
    def initialize
      BasicSocket.do_not_reverse_lookup = true
      @client = UDPSocket.new
    end

    def gets
      @client.bind('0.0.0.0', 33333)
      input, addr = @client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
      puts "From addr: '%s', msg: '%s'" % [addr.join(','), input]
      @client.close
      JSON.parse(input)
    end
  end
end