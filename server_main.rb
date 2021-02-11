require_relative 'server.rb'

hostname = ARGV[0]
port = ARGV[1]

server = Server.new(hostname, port)
puts ('Server running on port %d' % server.port)

server.run()