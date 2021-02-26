#!/usr/bin/envy ruby

require_relative '../lib/memcached-server.rb'

hostname = ARGV[0]
port = ARGV[1]

server = MemcachedServer::Server.new(hostname, port)
puts ('Server running on port %d' % server.port)

run = Thread.new {server.run()}

run.join()
