require 'spec_helper'

module Communications
  describe UDPPacketBuffer do
   let(:buffer) { UDPPacketBuffer.new(4) }
   let(:packets) do
     (1..7).to_a.collect { |i| FactoryGirl.build(:udp_packet, sequence_no: i) }
   end

    describe '#<<' do
      context 'buffer is not full' do
        it 'adds the packet to the buffer ordered by sequence_no ascending' do
          expect(buffer.all).to eq([])
          buffer << packets[1]
          expect(buffer.all).to eq([packets[1]])

          buffer << packets[0]
          expect(buffer.all).to eq([packets[0], packets[1]])

          buffer << packets[3]
          expect(buffer.all).to eq([packets[0], packets[1], packets[3]])
        end
      end

      context 'buffer is full' do
        before :each do
          buffer << packets[2]
          buffer << packets[3]
          buffer << packets[4]
          buffer << packets[6]
        end

        context 'we receive a packet with a sequence_no earlier than the earliest packet in the buffer' do
          before :each do
            buffer << packets[0]
          end

          it 'is an old packet so it is no longer useful and is not added to the buffer' do
            expect(buffer.all).to eq([packets[2], packets[3], packets[4], packets[6]])
          end
        end

        context 'we receive a packet with a sequence_no later than the earliest packet in the buffer' do
          before :each do
            buffer << packets[5]
          end

          it 'we remove the earliest packet and add our packet,then order the buffer by sequence_no' do
            expect(buffer.all).to eq([packets[3], packets[4], packets[5], packets[6]])
          end
        end
      end
    end

    describe '#full?' do
      context 'buffer is full' do
        before :each do
          packets[0..3].each { |packet| buffer << packet }
        end

        it 'returns true' do
          expect(buffer.full?).to eq(true)
        end
      end

      context 'buffer is not full' do
        before :each do
          packets[0..2].each { |packet| buffer << packet }
        end

        it 'returns false' do
          expect(buffer.full?).to eq(false)
        end
      end
    end

   describe '#flush' do
     before :each do
       packets[0..2].each { |packet| buffer << packet }
     end

     it 'empties the buffer and returns the content' do
       expect(buffer.flush).to eq(packets[0..2])
       expect(buffer.all).to eq([])
     end
   end

    describe '#update' do
      before :each do
        packets[0..2].each { |packet| buffer << packet }
      end

      context 'sequence_no passed corresponds to a packet within the buffer' do
        it 'updates the packet attributess for the sequence no passed' do
          expect(buffer.update(2, {sent_time: 'some time', received_ack_time: 'another time'})).to eq(true)
          expect(buffer.find(2).sent_time).to eq('some time')
          expect(buffer.find(2).received_ack_time).to eq('another time')

          [1, 3].each do |i|
            expect(buffer.find(i).sent_time).to_not eq('some time')
            expect(buffer.find(i).received_ack_time).to_not eq('another time')
          end
        end

        context 'no params passed' do
          before :each do
            packets[0].sent_time = 'old time'
          end

          it 'does nothing' do
            expect(buffer.update(1, {})).to eq(true)
            expect(buffer.find(1).sent_time).to eq('old time')
          end
        end
      end

      context 'sequence_no passed does not correspond to a packet within the buffer' do
        it 'raises error' do
          expect { buffer.update(20, {sent_time: 'some time', received_ack_time: 'another time'}) }.to raise_error
        end
      end

      context 'valid sequence_no but invalid attributes passed' do
        it 'raises error' do
          expect { buffer.update(2, {unknown_attr: 'some time'}) }.to raise_error
        end
      end
    end

    describe '#lost' do
      before :each do
        packets[0..5].each do |packet|
          packet.sent_time = Time.now - 40
          packet.received_ack_time = Time.now - 40

          buffer << packet
        end
      end

      context 'non lost' do
        it 'returns no packets' do
          expect(buffer.lost).to eq([])
        end
      end

      context 'are some lost - have not recieved an ack within 30 seconds' do
        before :each do
          packets[2].received_ack_time = nil
          packets[4].received_ack_time = nil
        end

        it 'returns the packet that we are treating as lost' do
          expect(buffer.lost).to eq([packets[2], packets[4]])
        end
      end
    end


  end
end
