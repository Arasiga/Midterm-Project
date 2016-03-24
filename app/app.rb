require_relative '../config/environment.rb'
require_relative './code_eval.rb'

require 'thin'
require 'sinatra/base'
require 'em-websocket'
require 'json'

def socket_send(client, type, text)
  client[:sock].send(JSON.generate({type: type, text: text}))
  puts "Sending to #{client[:uname].to_s}:"
  puts JSON.generate({type: type, text: text})
end

def get_client_from_socket(client_list, socket)
  client_list.detect {|elem| elem[:sock] == socket}
end

EventMachine.run do
  # our WebSockets server logic will go here
  # EventMachine.add_periodic_timer 2 do
  #   puts 'Ping!'
  # end

  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      client = {sock: ws, uname: nil}
      @clients << client
      puts "new client connected"
      socket_send(client, "text", "Connected to #{handshake.path}.")
    end

    ws.onclose do
      client = get_client_from_socket(@clients, ws)
      socket_send(client, "text", "Closed")
      puts "closing"
      @clients.delete(client)
    end

    ws.onmessage do |msg|
      msg = JSON.parse(msg)
      client = get_client_from_socket(@clients, ws)
      puts "Received Message from #{client[:uname].to_s}"
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
            socket_send(cli, "codeOutputReceive", evaluation) 
        end
      when "text", "codeInputReceive"
        if client[:uname] == nil
          ws.close
          puts "need username"
          @clients.delete(client)          
        else
          puts "sending message:"
          text_prefix = msg["type"] == "text" ? "#{client[:uname]}:  " : ""
          text = text_prefix + msg["text"]
          @clients.each do |cli|
            socket_send( cli, "#{msg["type"]}", text) if cli != client
          end
        end
      when "username"   
        name_desired = msg["text"]
        puts "got uname"
        if @clients.detect {|cli| cli[:uname] == name_desired} == nil
          client[:uname] = msg["text"]
        else 
          socket_send(client, "command_username", "")
        end
      end
    end
  end

  Sinatra::Application.run! :port => 3000
end