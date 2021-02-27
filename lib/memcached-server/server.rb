require 'socket'
require_relative './memcache.rb'
require_relative './constants.rb'

module MemcachedServer
    
    class Server

        attr_reader :hostname
        attr_reader :port
        attr_reader :mc

        def initialize(hostname, port)
            @hostname = hostname
            @port = port
            @connection = TCPServer.new(hostname, port)
            @mc = Memcache.new()
        end

        # Starts the server
        def run()
            begin
                loop do
                    Thread.start(@connection.accept()) do | connection |
                        puts("New connection: #{connection.to_s}.")

                        close = false
                        while command = connection.gets()
                            puts("Command: #{command} | Connection: #{connection.to_s}")

                            valid_command = validate_command(command)
                            if valid_command
                                close = run_command(connection, valid_command)
                            else 
                                connection.puts(Error::CLIENT_ERROR % [" Undefined command. Please check the command syntax and try again."])
                            end

                            break if close
                        end
                        connection.puts(Reply::END_)
                        connection.close()
                        puts ("Connection closed to: #{connection}.")
                    end
                end
            rescue => exception
                error = Error::SERVER_ERROR % exception.message
                connection.puts(error)
            end
        end

        # Runs a valid memcache command
        # Depends on MemcachedServer::Memcache method names.
        # In some cases, to make .send method work the MemcachedServer::Memcache 
        # corresponding method must be equal to valid_command[:name] 
        # 
        # @param connection [TCPSocket] Client's socket
        # @param valid_command [MatchData] It encapsulates all the results of a valid command pattern match
        # @return [Boolean] false if valid_command[:name] != END else true
        def run_command(connection, valid_command)
            name = valid_command[:name]

            case name
            when 'set', 'add', 'replace'
                key = valid_command[:key]
                flags = valid_command[:flags]
                exptime = valid_command[:exptime].to_i
                bytes = valid_command[:bytes].to_i
                noreply = !valid_command[:noreply].nil?
                data = self.read_bytes(connection, bytes)

                reply = @mc.send(name.to_sym, key, flags, exptime, bytes, data)
                connection.puts(reply) unless noreply
                return false

            when 'append', 'prepend'
                key = valid_command[:key]
                bytes = valid_command[:bytes].to_i
                data = self.read_bytes(connection, bytes)

                reply = @mc.send(name.to_sym, key, bytes, data)
                connection.puts(reply) unless noreply
                return false

            when 'cas'
                key = valid_command[:key]
                flags = valid_command[:flags]
                exptime = valid_command[:exptime].to_i
                bytes = valid_command[:bytes].to_i
                noreply = !valid_command[:noreply].nil?
                data = self.read_bytes(connection, bytes)
                cas_id = valid_command[:cas_id].to_i()

                reply = @mc.cas(key, flags, exptime, bytes, cas_id, data)
                connection.puts(reply) unless noreply
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
        
        def read_bytes(connection, bytes)
            return connection.read(bytes + 1).chomp()
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

    end

end
