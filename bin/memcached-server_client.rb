#!/usr/bin/envy ruby

require 'socket'
require_relative '../lib/memcached-server.rb'

hostname = ARGV[0]
port = ARGV[1]

socket = TCPSocket.new(hostname, port)

listener = Thread.new {
  while line = socket.gets()
    puts(line)
  end
}

event_handler = Thread.new {
  loop do
      command = STDIN.gets()
      socket.write(command)
      break if $_.match(MemcachedServer::Reply::END_)
      sleep(0.1)
  end
}

listener.join()
event_handler.join()

socket.close()
