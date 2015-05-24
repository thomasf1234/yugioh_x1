require 'spec_helper'

module Communications
  describe UDPPacket do
    let(:protocol_id) { [Zlib.adler32('yugioh'.encode('ASCII-8BIT'))].pack('N') }
    let(:content) { 'payload data'.encode('ASCII-8BIT') + 0.chr('ASCII-8BIT') }
    let(:attributes) do
      {
          protocol_id: protocol_id,
          sequence_no: 83,
          ack: 67,
          flags: Set.new([:syn, :ack]),
          previous_acks: [53, 52, 50, 49, 48, 47, 46, 41, 39, 37, 35],
          content_bytesize: 13,
          content: content,
          addr: ["AF_INET", 33230, '127.0.0.1', '127.0.0.1']
      }
    end
    let(:raw_payload) do
      [
          #protocol_id (bytes 1..4, val = yugioh adler checksum)
          '00001001010000100000001010010110' +

          #flags - connection_request, SYN, ACK, (byte 5)
          '00110000' +

          #sequence_no - (bytes 6..7, val = 83)
          '0000000001010011' +

          #ack - (bytes 8..9, val = 67)
          '0000000001000011' +

          #ack_bitfield (bytes 9..12, val = last 32 acks)
          '00000000000001101111100001010101' +

          #content length in bytes - (bytes 14..15, val = 13)
          '0000000000001101' +

          #content in ASCII-8BIT - (bytes 16..28)
          [
              '01110000', #'p'
              '01100001', #'a'
              '01111001', #'y'
              '01101100', #'l'
              '01101111', #'o'
              '01100001', #'a'
              '01100100', #'d'
              '00100000', #' '
              '01100100', #'d'
              '01100001', #'a'
              '01110100', #'t'
              '01100001', #'a'
              '00000000', #NULL character for content termination
          ].join
      ].pack('B*')
    end

    describe '#initialize' do
      let(:udp_packet) do
        UDPPacket.new(attributes[:protocol_id],
                      attributes[:sequence_no],
                      attributes[:ack],
                      attributes[:previous_acks],
                      attributes[:content_bytesize],
                      attributes[:content],
                      attributes[:addr])
      end

      it 'assigns the correct attributes' do
        attributes.each do |attr, value|
          expect(udp_packet.send(attr)).to eq(value)
        end

        expect(udp_packet.raw_payload).to eq(raw_payload)
      end
    end

    describe '.new_from' do
      let(:udp_packet) { UDPPacket.new_from(raw_packet) }
      let(:raw_packet) { [raw_payload, attributes[:addr]] }

      it 'extract useful information from the packet payload' do
        attributes.each do |attr, value|
          expect(udp_packet.send(attr)).to eq(value)
        end

        expect(udp_packet.raw_payload).to eq(raw_payload)
      end
    end

    describe '#acks' do
      let(:udp_packet) { FactoryGirl.build(:udp_packet, {ack: 23, previous_acks: [1,7,35]}) }

      it 'returns all the acks retrieved from the packet' do
        expect(udp_packet.acks).to match_array([1,7,23,35])
      end
    end

    describe '#contains_acks?' do
      context 'has at least one ack' do
        let(:udp_packet) { FactoryGirl.build(:udp_packet, {ack: 2, previous_acks: []}) }

        it 'returns all the acks retrieved from the packet' do
          expect(udp_packet.contains_acks?).to eq(true)
        end
      end

      context 'the 48 bits designated to ack and ack_bitfield are not set' do
        let(:udp_packet) { FactoryGirl.build(:udp_packet, {ack: 0, previous_acks: []}) }

        it 'returns all the acks retrieved from the packet' do
          expect(udp_packet.contains_acks?).to eq(false)
        end
      end
    end

    describe '#rtt' do
      let(:udp_packet) { FactoryGirl.build(:udp_packet) }

      context 'we received an ack for this packet' do
        before :each do
          udp_packet.sent_time = Time.parse('2015-05-23 18:26:01.011', "%Y-%m-%d %H:%M:%S.%3N")
          udp_packet.received_ack_time = Time.parse('2015-05-23 18:26:01.047', "%Y-%m-%d %H:%M:%S.%3N")
        end

        it 'returns the duration for this packets trip' do
          expect(udp_packet.rtt).to eq(0.036)
        end
      end

      context 'we have not received an ack for this packet yet' do
        before :each do
          udp_packet.sent_time = Time.parse('2015-05-23 18:26:01.011', "%Y-%m-%d %H:%M:%S.%3N")
        end

        it 'returns the duration for this packets trip' do
          expect(udp_packet.rtt).to eq(nil)
        end
      end
    end
  end
end
