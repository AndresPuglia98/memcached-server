# require 'concurrent'
require_relative 'reply.rb'
require_relative 'item.rb'


class Memcache

    attr_reader :data_store

    def initialize()
       @data_store = Hash.new()
    end
    
    def get(key)
        return @data_store[key]
    end

    def gets(key)
        
    end

    def set(key, flags, exptime, bytes, data_block)
        item = Item.new(key, flags, exptime, bytes, data_block)
        @data_store.store(key, item)
        return Reply::STORED
    end

    def add(key, flags, exptime, bytes, noreply, data_block)
        
    end

    def replace(key, flags, exptime, bytes, noreply, data_block)
        
    end

    def append(key, flags, exptime, bytes, noreply, data_block)
        
    end

    def prepend(key, flags, exptime, bytes, noreply, data_block)
        
    end

    def cas(key, flags, exptime, bytes, cas_unique, noreply, data_block)
        
    end

end
