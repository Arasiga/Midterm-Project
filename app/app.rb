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

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      begin
        rawcookie = handshake.headers['Cookie'].partition('rack.session=').last
        decoded_cookie = Marshal.load(Base64.decode64(Rack::Utils.unescape(rawcookie.split('--').first)))  
        if (!decoded_cookie["user_id"] || !decoded_cookie["pad"])
          auth_error(ws)
        else
          user = User.find(decoded_cookie["user_id"])
          if (!user)
            auth_error(ws)
          else
            if (user_connected?(user))
              socket_send(ws, "alreadyConnected", "Already connected")
              ws.close
            else
              client = {sock: ws, user: user, pad: decoded_cookie["pad"]}
              @clients << client
              puts "new client connected"
              socket_send(client[:sock], "text", "Connected to the pad for: #{Project.find_by(id: client[:pad]).name}.")
              padclients = @clients.map {|cli| cli if cli[:pad] == client[:pad]}
              padclientNames = padclients.map {|cli| cli[:user].username}
              padclients.each do |cli|
                socket_send( cli[:sock], "text", "#{client[:user].username.to_s} has joined the pad") if cli != client && cli[:pad] == client[:pad]
                socket_send(cli[:sock], "userList", padclientNames)
              end
            end
          end
        end
      rescue
        ws.close
      end
    end

    ws.onclose do
      # binding.pry
      client = get_client_from_param(@clients, :sock, ws)
      if (client)
        # binding.pry
        socket_send(client[:sock], "text", "Closed")
        puts "closing"
        @clients.delete(client)
        padclients = @clients.map {|cli| cli if cli[:pad] == client[:pad]}
        padclientNames = padclients.map {|cli| cli[:user].username}
        padclients.each do |cli|
            socket_send( cli[:sock], "text", "#{client[:user].username.to_s} has left the chat") 
            socket_send(cli[:sock], "userList", padclientNames)
        end        
      end
    end

    ws.onmessage do |msg|
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
        evaluation = nil
        begin
          evaluation = safe_eval(msg["text"])
        rescue
          evaluation = "Syntax Error:"
        end
        @clients.each do |cli|
            socket_send(cli[:sock], "codeOutputReceive", evaluation) if cli[:pad] == client[:pad]
        end
      when "text", "codeInputReceive"       
        puts "sending message:"
        text_prefix = msg["type"] == "text" ? "#{client[:user].username.to_s}:  " : ""
        text = text_prefix + msg["text"]
        @clients.each do |cli|
          socket_send( cli[:sock], "#{msg["type"]}", text) if cli != client && cli[:pad] == client[:pad]
        end
      when "sendCurrCode"
        # binding.pry
        other_client =  @clients.detect {|cli| cli != client && cli[:pad] == client[:pad]}
        if other_client
          socket_send(other_client[:sock], "sendCurrCode", "")
        end
      end
    end
  end

  Sinatra::Application.run! :port => 3000
end