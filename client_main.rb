require 'socket'

hostname = ARGV[0]
port = ARGV[1]

socket = TCPSocket.new(hostname, port)

while line = socket.gets  # Read lines from socket
  puts line
end

socket.close              # close socket when done