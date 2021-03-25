require 'socket'
require_relative './memcache.rb'
require_relative './constants.rb'

module MemcachedServer
    
    # Class that wraps up a Memcached server
    class Server

        # The server hostname or IP address
        #
        # @return [String, ipaddress]
        attr_reader :hostname

        # The server port
        #
        # @return [port]
        attr_reader :port

        # The Memcache object that implements the logic of the Memcache protocol
        #
        # @return [MemcachedServer::Memcache]
        attr_reader :mc

        def initialize(hostname, port)

            @hostname = hostname
            @port = port
            @connection = TCPServer.new(hostname, port)
            @mc = Memcache.new()
            
        end

        # Starts the server
        def run() 
            loop do
                begin
                    Thread.start(@connection.accept()) do | connection |

                        puts("New connection: #{connection.to_s}.")

                        close = false
                        
                        begin

                            while command = connection.gets()

                                puts("Command: #{command} | Connection: #{connection.to_s}")

                                valid_command = validate_command(command)
                                if valid_command
                                    close = run_command(connection, valid_command)
                                else
                                    connection.puts(Error::ERROR)
                                end

                                break if close

                            end

                        rescue => exception
                            puts(exception.message)
                        end

                        connection.puts(Reply::END_)
                        connection.close()
                        puts("Connection closed to: #{connection}.")
                        
                    end
                rescue Interrupt
                    puts('Shutting down Memcached server...')
                    break
                end
            end
        end

        # Runs a valid memcache command.
        # Depends on MemcachedServer::Memcache method names.
        # In some cases, when the #send method is used, the corresponding
        # MemcachedServer::Memcache method must be equal to valid_command[:name] 
        # 
        # @param connection [TCPSocket] Client's socket
        # @param valid_command [MatchData] It encapsulates all the results of a valid command pattern match
        # @return [Boolean] false if valid_command[:name] != END else true
        def run_command(connection, valid_command)

            name = valid_command[:name]

            case name
            when 'set', 'add', 'replace'

                key = valid_command[:key]
                flags = valid_command[:flags].to_i
                exptime = valid_command[:exptime].to_i
                bytes = valid_command[:bytes].to_i
                noreply = !valid_command[:noreply].nil?
                data = self.read_bytes(connection, bytes)

                reply = @mc.send(name.to_sym, key, flags, exptime, bytes, data) unless data.nil?()
                connection.puts(reply) unless noreply || reply.nil?()

                return false

            when 'append', 'prepend'

                key = valid_command[:key]
                bytes = valid_command[:bytes].to_i
                data = self.read_bytes(connection, bytes)

                reply = @mc.send(name.to_sym, key, bytes, data) unless data.nil?()
                connection.puts(reply) unless noreply || reply.nil?()

                return false

            when 'cas'

                key = valid_command[:key]
                flags = valid_command[:flags].to_i
                exptime = valid_command[:exptime].to_i
                bytes = valid_command[:bytes].to_i
                noreply = !valid_command[:noreply].nil?
                data = self.read_bytes(connection, bytes)
                cas_id = valid_command[:cas_id].to_i()

                reply = @mc.cas(key, flags, exptime, bytes, cas_id, data) unless data.nil?()
                connection.puts(reply) unless noreply || reply.nil?()

                return false
                
            when 'get'

                keys = valid_command[:keys].split(' ')
                items = @mc.get(keys)

                for item in items
                    connection.puts(Reply::GET % [item.key, item.flags, item.bytes, item.data_block]) if item
                    connection.puts(Reply::END_)
                end

                return false

            when 'gets'

                keys = valid_command[:keys].split(' ')
                items = @mc.get(keys)

                for item in items
                    connection.puts(Reply::GETS % [item.key, item.flags, item.bytes, item.cas_id, item.data_block]) if item
                    connection.puts(Reply::END_)
                end

                return false

            else
                # END command stops run
                return true
                
            end
        end
        
        # Reads <bytes> bytes from <connection>
        # 
        # @param connection [TCPSocket] Client's socket
        # @param bytes [Integer] The number of bytes to read
        # @return [String, nil] The message read
        def read_bytes(connection, bytes)

            data_chunk = connection.read(bytes + 1).chomp()

            if data_chunk.bytesize() != bytes
                connection.puts(Error::CLIENT_ERROR % [" bad data chunk"])
                return nil
            end

            return data_chunk
        end

        # Validates a command.
        # If the command isn't valid it returns nil.
        # 
        # @param command [String] A command to validate
        # @return [MatchData, nil] It encapsulates all the results of a valid command pattern match
        def validate_command(command)

            valid_formats = CommandFormat.constants.map{| key | CommandFormat.const_get(key)}

            valid_formats.each do | form |

                valid_command = command.match(form)
                return valid_command unless valid_command.nil?
                
            end

            return nil
        end

        # Accepts a connection.
        # Used for testing only.
        # @return [TCPSocket] An accepted TCPSocket for the incoming connection.
        def accept()
            return @connection.accept()
        end

    end

end
