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

speaker = Thread.new {
  loop do
      command = STDIN.gets()
      socket.puts(command)
      break if $_.match(MemcachedServer::Reply::END_) # $_ : the last input line of string by gets or readline. Thread and scope local.
      sleep(0.1)
  end
}

listener.join()
speaker.join()

socket.close()
