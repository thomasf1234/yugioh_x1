FactoryGirl.define do
  factory :udp_packet, class: Communications::UDPPacket do
    protocol_id { [Zlib.adler32('yugioh'.encode('ASCII-8BIT'))].pack('N') }
    sequence_no 83
    ack 67
    previous_acks [53, 52, 50, 49, 48, 47, 46, 41, 39, 37, 35]
    content_bytesize 13
    content { 'payload data'.encode('ASCII-8BIT') + 0.chr('ASCII-8BIT') }
    addr ["AF_INET", 33230, '127.0.0.1', '127.0.0.1']

    initialize_with { new(protocol_id, sequence_no, ack, previous_acks, content_bytesize, content, addr) }
  end
end
