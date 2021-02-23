require 'socket'
require_relative 'reply.rb'

module MemcachedServer
  
  class Client

    attr_reader :hostname
    attr_reader :port

    def initialize(hostname, port)
        @hostname = hostname
        @port = port
        @server = TCPSocket.new(hostname, port)
    end

    def set(key, flags, exptime, bytes, data_block)
      command = "set #{key} #{flags} #{exptime} #{bytes}\n#{data_block}"
      @server.write(command)

      return @server.gets()
    end

    def add(key, flags, exptime, bytes, data_block)
      command = "add #{key} #{flags} #{exptime} #{bytes}\n#{data_block}"
      @server.write(command)

      return @server.gets()
    end

    def replace(key, flags, exptime, bytes, data_block)
      command = "replace #{key} #{flags} #{exptime} #{bytes}\n#{data_block}"
      @server.write(command)

      return @server.gets()
    end

    def append(key, bytes, data_block)
      command = "append #{key} #{bytes}\n#{data_block}"
      @server.write(command)

      return @server.gets()
    end

    def prepend(key, bytes, data_block)
      command = "prepend #{key} #{bytes}\n#{data_block}"
      @server.write(command)

      return @server.gets()
    end

    def cas(key, flags, exptime, bytes, cas_id, data_block)
      command = "cas #{key} #{flags} #{exptime} #{bytes} #{cas_id}\n#{data_block}"
      @server.write(command)

      return @server.gets()
    end

    def get(keys)
      @server.write("get #{keys}")

      retrieved = {}
      loop do
        case @server.gets()

        when Reply::GET
          key = $~[:key]
          flags = $~[:flags].to_i()
          bytes = $~[:bytes].to_i()
          data_block = @server.recv(bytes + 1).chomp()

          item = Item.new(key, flags, 0, bytes, nil, data_block)
          retrieved[key.to_sym] = item

        when Reply::END_
          break

        else
          puts $_
          break
        end
        
      end

      return retrieved
    end

    def gets(keys)
      @server.write("gets #{keys}")

      retrieved = {}
      loop do
        case @server.gets()

        when Reply::GETS
          key = $~[:key]
          flags = $~[:flags].to_i()
          bytes = $~[:bytes].to_i()
          cas_id = $~[:cas_id].to_i()
          data_block = @server.recv(bytes + 1).chomp()

          item = Item.new(key, flags, 0, bytes, data_block)
          item.cas_id = cas_id
          retrieved[key.to_sym] = item

        when Reply::END_
          break

        else
          puts $_
          break
        end

      end

      return retrieved
    end

  end

end
