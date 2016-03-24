require_relative '../config/environment.rb'
require_relative './code_eval.rb'

require 'thin'
require 'sinatra/base'
require 'em-websocket'
require 'json'

def socket_send(sock, type, text)
  sock.send(JSON.generate({type: type, text: text}))
  # puts "Sending to #{client[:uname].to_s}:"
  puts JSON.generate({type: type, text: text})
end

def get_client_from_param(client_list, param, obj)
  client_list.detect {|elem| elem[param] == obj}
end

def auth_error(sock)
  socket_send(sock, "authError", "")
  sock.close
end

def user_connected? (user)
  get_client_from_param(@clients, :user, user) != nil
end

EventMachine.run do
  # our WebSockets server logic will go here
  # EventMachine.add_periodic_timer 2 do
  #   puts 'Ping!'
  # end

  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      # binding.pry
      prefix, rawcookie = handshake.headers['Cookie'].split('=')
      decoded_cookie = Marshal.load(Base64.decode64(Rack::Utils.unescape(rawcookie.split('--').first)))  
      # binding.pry
      if (!decoded_cookie["user_id"])
        auth_error(ws)
      else
        user = User.find(decoded_cookie["user_id"])
        if (!user)
          auth_error(ws)
        else
          if (user_connected?(user))
            socket_send(ws, "text", "Already connected")
            ws.close
          else
            client = {sock: ws, user: user}
            @clients << client
            puts "new client connected"
            socket_send(client[:sock], "text", "Connected to #{handshake.path}.")
          end
        end
      end
    end

    ws.onclose do
      client = get_client_from_param(@clients, :sock, ws)
      if (client)
        socket_send(client[:sock], "text", "Closed")
        puts "closing"
        @clients.each do |cli|
            socket_send( cli[:sock], "#{client[:user].username.to_s} has left the chat", text) if cli != client
        end
        @clients.delete(client)
      end
    end

    ws.onmessage do |msg|
      # binding.pry
      msg = JSON.parse(msg)
      client = get_client_from_param(@clients, :sock, ws)
      if (!client)
        auth_error(ws)
        return
      end
      puts "Received Message from #{client[:user].username.to_s}"
      puts msg.inspect
      case msg["type"]
      when "codeRun"
        # binding.pry
        evaluation = nil
        begin
          evaluation = safe_eval(msg["text"])
        rescue
          evaluation = "Syntax Error:"
        end
        # puts eval(msg["text"])
        # binding.pry
        @clients.each do |cli|
            socket_send(cli[:sock], "codeOutputReceive", evaluation) 
        end
      when "text", "codeInputReceive"       
        puts "sending message:"
        text_prefix = msg["type"] == "text" ? "#{client[:user].username.to_s}:  " : ""
        text = text_prefix + msg["text"]
        @clients.each do |cli|
          socket_send( cli[:sock], "#{msg["type"]}", text) if cli != client
        end
      end
    end
  end

  Sinatra::Application.run! :port => 3000
end