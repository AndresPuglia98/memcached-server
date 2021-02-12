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
            Thread.start(@connection.accept()) do | client |
                
                while command = client.gets()
                    client.puts (command)
                    client.puts ('Hello!')
                end
                
                client.close()
            end
        end
    end

end
