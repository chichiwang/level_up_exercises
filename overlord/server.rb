require 'sinatra/base'
require 'sinatra-websocket'

class Server < Sinatra::Base
  set :public_folder, proc { File.join(root, "client", "public") }
  set :sockets, []

  get '/' do
    if request.websocket?
      request.websocket do |ws|
        ws.onopen do
          ws.send("Hello World!")
          settings.sockets << ws
          puts "socket opened"
        end
        ws.onmessage do |msg|
          # EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        end
        ws.onclose do
          warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end
    else
      send_file File.join(settings.public_folder, 'index.html')
    end
  end
end
