require 'sinatra/base'
require 'sinatra-websocket'

require_relative 'bomb_socket'

class Server < Sinatra::Base
  set :public_folder, proc { File.join(root, "client", "public") }
  set :sockets, BombSocket.new

  get '/' do
    if request.websocket?
      request.websocket do |ws|
        settings.sockets.register_client(ws)
      end
    else
      send_file File.join(settings.public_folder, 'index.html')
    end
  end
end
