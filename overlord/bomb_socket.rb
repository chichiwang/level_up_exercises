require 'securerandom'
require 'json'

# require_relative 'bomb'

class BombSocket
  def initialize
    @clients = []
    # @bomb = Bomb.new
  end

  def register_client(ws)
    client = { id: random_id, socket: ws }
    ws.onopen { open(client) }
    ws.onmessage { |msg| message(client, msg) }
    ws.onclose { close(client) }
  end

  private

  def random_id
    time = Time.new
    prefix = time.sec.to_s + time.min.to_s + time.hour.to_s
    suffix = time.usec.to_s
    prefix + SecureRandom.hex + suffix
  end

  def open(client)
    dummydata = { state: 'unconfigured' }
    client[:socket].send(JSON.pretty_generate(dummydata))
    @clients << client
    puts "Socket opened: " + client[:id]
  end

  def message(client, message)
  end

  def close(client)
    warn('Socket closed: ' + client[:id])
    @clients.delete_if { |entry| entry[:id] == client[:id] }
  end
end
