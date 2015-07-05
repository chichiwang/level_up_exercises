require_relative '../bomb_socket'

describe "BombSocket" do
  let(:bombsocket) { BombSocket.new }

  describe '#register_client' do
    it "should assign a block to the websocket #onopen method" do
      ws = spy('websocket')
      bombsocket.register_client(ws)
      expect(ws).to have_received(:onopen)
    end

    it "should assign a block to the websocket #onmessage method" do
      ws = spy('websocket')
      bombsocket.register_client(ws)
      expect(ws).to have_received(:onmessage)
    end

    it "should assign a block to the websocket #onclose method" do
      ws = spy('websocket')
      bombsocket.register_client(ws)
      expect(ws).to have_received(:onclose)
    end
  end
end
