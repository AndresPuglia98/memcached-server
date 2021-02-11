require 'socket'

hostname = ARGV[0]
port = ARGV[1]

socket = TCPSocket.new(hostname, port)

listener = Thread.new {
  while line = socket.gets()  # Read lines from socket
    puts (line)
  end
}

speaker = Thread.new {
  loop do
      print("> ")
      socket.puts(STDIN.gets())
      sleep(0.1)
  end
}

listener.join()
speaker.join()

socket.close()              # close socket when done