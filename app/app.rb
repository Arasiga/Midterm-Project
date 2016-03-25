require_relative '../config/environment.rb'

require 'thin'
require 'sinatra/base'
require 'em-websocket'
require 'json'

def socket_send(ws, type, text)
  ws.send(JSON.generate({type: type, text: text}))
  puts JSON.generate({type: type, text: text})
end

EventMachine.run do
  # our WebSockets server logic will go here
  # EventMachine.add_periodic_timer 2 do
  #   puts 'Ping!'
  # end

  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '9001') do |ws|
    ws.onopen do |handshake|
      @clients << {sock: ws, uname: nil}
      puts "new client connected"
      socket_send(ws, "text", "Connected to #{handshake.path}.")
    end

    ws.onclose do
      socket_send(ws, "text", "Closed")
      puts "closing"
      @clients.delete(@clients.detect {|elem| elem[:sock] == ws})
    end

    ws.onmessage do |msg|
      msg = JSON.parse(msg)
      puts "Received Message"
      puts msg.inspect
      client = @clients.detect {|elem| elem[:sock] == ws}
      case msg["type"]
      when "text"
        if client[:uname] == nil
          ws.close
          puts "need username"
        else
          puts "sending message"
          @clients.each do |cli|
          socket_send( cli[:sock], "text", "#{client[:uname]}:  " + msg["text"]) if cli != client
          end
        end
      when "username"   
        name_desired = msg["text"]
        puts "got uname"
        if @clients.detect {|cli| cli[:uname] == name_desired} == nil
          client[:uname] = msg["text"]
        else 
          socket_send(client[:sock], "command_username", "")
        end
      end
    end
  end

  Sinatra::Application.run! :port => 9000
end