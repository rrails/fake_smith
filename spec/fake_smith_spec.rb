require 'fake_smith'

class MyAgent < Smith::Agent
  def run
    receiver("ack_twice_queue", :auto_ack => false).subscribe(&method(:ack_twice))
    receiver("ack_once_queue", :auto_ack => false).subscribe(&method(:ack_once))
    receiver("auto_ack_and_ack_queue", :auto_ack => true).subscribe(&method(:auto_ack_and_ack))
  end

  def ack_twice(payload, receiver)
    receiver.ack
    receiver.ack
  end

  def ack_once(payload, receiver)
    receiver.ack
  end

  def auto_ack_and_ack(payload, receiver)
    receiver.ack
  end
end

describe FakeSmith do
  let(:receiver) { double(:receiver, :ack => true) }
  let(:message) { {} }
  let(:agent) { MyAgent.new }
  before(:each) do
    agent.run
  end

  describe 'acking messages twice' do
    it 'raises errors' do
      expect { FakeSmith.send_message("ack_twice_queue", message, receiver) }.to raise_error(FakeSmith::MessageAckedTwiceError)
    end

    it 'raises errors when acking once and auto_ack' do
      expect { FakeSmith.send_message("auto_ack_and_ack_queue", message, receiver) }.to raise_error(FakeSmith::MessageAckedTwiceError)
    end
  end

  describe 'acking' do
    it 'acks the passed in receiver' do
      expect(receiver).to receive(:ack)
      FakeSmith.send_message("ack_once_queue", message, receiver)
    end
  end
end
