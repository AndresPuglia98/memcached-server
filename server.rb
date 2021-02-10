require 'socket'

class Server

    attr_reader :hostname
    attr_reader :port

    def initialize(hostname, port)
        @hostname = hostname
        @port = port
        @connection = TCPServer.new(hostname, port)
    end

    def run
        loop do
            client = @connection.accept    # Wait for a client to connect
            client.puts 'Hello!'
            client.close
        end
    end

end