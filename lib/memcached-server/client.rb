require 'socket'
require_relative 'constants.rb'

module MemcachedServer
  
  # Class that communicates with a MemcachedServer::Server
  class Client

    # The client socket hostname or IP address
    #
    # @return [String, ipaddress]
    attr_reader :hostname
    
    # The client socket port
    #
    # @return [port]
    attr_reader :port

    def initialize(hostname, port)

        @hostname = hostname
        @port = port
        @server = TCPSocket.new(hostname, port)

    end

    # Sends the server a set command
    # 
    # @param key [String] The key of the item to store
    # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
    # @param exptime [Integer] The exptime of the Item to store
    # @param bytes [Integer] The byte size of <data_block>
    # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
    # @return [String] The reply that describes the result of the operation
    def set(key, flags, exptime, bytes, data_block)
      command = "set #{key} #{flags} #{exptime} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    # Sends the server an add command
    # 
    # @param key [String] The key of the item to store
    # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
    # @param exptime [Integer] The exptime of the Item to store
    # @param bytes [Integer] The byte size of <data_block>
    # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
    # @return [String] The reply that describes the result of the operation
    def add(key, flags, exptime, bytes, data_block)
      command = "add #{key} #{flags} #{exptime} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end


    # Sends the server a replace command
    # 
    # @param key [String] The key of the item to store
    # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
    # @param exptime [Integer] The exptime of the Item to store
    # @param bytes [Integer] The byte size of <data_block>
    # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
    # @return [String] The reply that describes the result of the operation
    def replace(key, flags, exptime, bytes, data_block)
      command = "replace #{key} #{flags} #{exptime} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    # Sends the server an append command
    # 
    # @param key [String] The key of the item to store
    # @param bytes [Integer] The byte size of <data_block>
    # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
    # @return [String] The reply that describes the result of the operation
    def append(key, bytes, data_block)
      command = "append #{key} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    # Sends the server a prepend command
    # 
    # @param key [String] The key of the item to store
    # @param bytes [Integer] The byte size of <data_block>
    # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
    # @return [String] The reply that describes the result of the operation
    def prepend(key, bytes, data_block)
      command = "prepend #{key} #{bytes}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    # Sends the server a cas command
    # 
    # @param key [String] The key of the item to store
    # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
    # @param exptime [Integer] The exptime of the Item to store
    # @param bytes [Integer] The byte size of <data_block>
    # @param cas_id [Integer] Is a unique integer value
    # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
    # @return [String] The reply that describes the result of the operation
    def cas(key, flags, exptime, bytes, cas_id, data_block)
      command = "cas #{key} #{flags} #{exptime} #{bytes} #{cas_id}\n#{data_block}\n"
      @server.puts(command)

      return @server.gets()
    end

    # Sends the server a get command
    # 
    # @param keys [[String]] The keys of the items to retrieve
    # @return [[MemcachedServer::Item]] Array of the retrieved MemcachedServer::Item instances
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

    # Sends the server a gets command
    # 
    # @param keys [[String]] The keys of the items to retrieve
    # @return [[MemcachedServer::Item]] Array of the retrieved MemcachedServer::Item instances
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

    # Sends the server an end command
    #  
    # @return [String] The reply that describes the result of the operation
    def end()
      @server.puts('END')
      return @server.gets()
    end

  end

end
