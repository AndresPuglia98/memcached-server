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
      command = "set #{key} #{flags} #{exptime} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    def add(key, flags, exptime, bytes, data_block)
      command = "add #{key} #{flags} #{exptime} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    def replace(key, flags, exptime, bytes, data_block)
      command = "replace #{key} #{flags} #{exptime} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    def append(key, bytes, data_block)
      command = "append #{key} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    def prepend(key, bytes, data_block)
      command = "prepend #{key} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    def cas(key, flags, exptime, bytes, cas_id, data_block)
      command = "cas #{key} #{flags} #{exptime} #{bytes} #{cas_id}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    def get(keys)
      @server.puts("get #{keys}")

      n = keys.split(' ').length()
      retrieved = {}

      n.times do

        loop do
          
          case @server.gets()
          when ReplyFormat::GET
            key = $~[:key]
            flags = $~[:flags].to_i()
            bytes = $~[:bytes].to_i()
            data_block = @server.read(bytes + 1).chomp()

            item = Item.new(key, flags, 0, bytes, data_block)
            retrieved[key.to_sym] = item

          when ReplyFormat::END_
            break

          else
            puts "Error\nServer: #{$_}"
            break

          end

        end

      end

      return retrieved
    end

    def gets(keys)
      @server.puts("gets #{keys}")

      n = keys.split(' ').length()
      retrieved = {}

      n.times do

        loop do

          case @server.gets()
          when ReplyFormat::GETS
            key = $~[:key]
            flags = $~[:flags].to_i()
            bytes = $~[:bytes].to_i()
            cas_id = $~[:cas_id].to_i()
            data_block = @server.read(bytes + 1).chomp()

            item = Item.new(key, flags, 0, bytes, data_block)
            item.cas_id = cas_id
            retrieved[key.to_sym] = item

          when ReplyFormat::END_
            break

          else
            puts "Error\nServer: #{$_}"
            break

          end

        end

      end

      return retrieved
    end

    def end()
      @server.puts('END')
      return @server.gets()
    end

    
  end

end
