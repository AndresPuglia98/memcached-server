require 'socket'
require_relative 'reply.rb'

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
      socket.write(command)
      break if $_.match(Reply::END_)
      sleep(0.1)
  end
}

listener.join()
speaker.join()

socket.close()              # close socket when done