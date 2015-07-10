require 'securerandom'
require 'json'

require_relative 'bomb'

class BombSocket
  def initialize
    @clients = []
    @bomb = new_bomb
  end

  def register_client(ws)
    client = { id: random_id, socket: ws }
    ws.onopen { open(client) }
    ws.onmessage { |msg| message(client, msg) }
    ws.onclose { close(client) }
  end

  private

  def close(client)
    warn('Socket closed: ' + client[:id])
    @clients.delete_if { |entry| entry[:id] == client[:id] }
  end

  def message(_client, message)
    msg = JSON.parse(message)
    command = msg["command"]
    params = msg["params"]
    @bomb.send(command, *params)
    push_all_properties
  end

  def new_bomb
    Bomb.new
  end

  def open(client)
    client[:socket].send(JSON.pretty_generate(@bomb.properties))
    @clients << client
    puts "Socket opened: " + client[:id]
  end

  def random_id
    time = Time.new
    prefix = time.sec.to_s + time.min.to_s + time.hour.to_s
    suffix = time.usec.to_s
    prefix + SecureRandom.hex + suffix
  end

  def push_all_properties
    props = JSON.pretty_generate(@bomb.properties)
    @clients.each do |client|
      client[:socket].send(props)
    end
  end
end
