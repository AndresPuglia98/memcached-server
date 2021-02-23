require_relative './reply.rb'
require_relative './item.rb'

class Memcache

    attr_reader :storage

    def initialize()
       @storage = Hash.new()
    end

    def purge_keys()
        @storage.delete_if { | key, item | item.expired? }
    end

    def get(keys)
        purge_keys()
        items = @storage.values_at(*keys)
        return items
    end

    def set(key, flags, exptime, bytes, data_block)
        store_item(key, flags, exptime, bytes, data_block)
        return Reply::STORED
    end

    def add(key, flags, exptime, bytes, data_block)
        purge_keys()
        return Reply::NOT_STORED if @storage.key?(key)
        
        store_item(key, flags, exptime, bytes, data_block)
        return Reply::STORED
    end

    def replace(key, flags, exptime, bytes, data_block)
        return Reply::NOT_STORED unless @storage.key?(key)

        store_item(key, flags, exptime, bytes, data_block)
        return Reply::STORED
    end

    def append(key, bytes, new_data)
        purge_keys()
        return Reply::NOT_STORED unless @storage.key?(key)

        item = @storage[key]
        item.data_block.concat(new_data)
        item.bytes += bytes
        item.update_cas_id()
        return Reply::STORED
    end

    def prepend(key, bytes, new_data)
        purge_keys()
        return Reply::NOT_STORED unless @storage.key?(key)

        item = @storage[key]
        item.data_block.prepend(new_data)
        item.bytes += bytes
        item.update_cas_id()
        return Reply::STORED
    end

    def cas(key, flags, exptime, bytes, cas_id, data_block)
        purge_keys()
        return Reply::NOT_FOUND unless @storage.key?(key)

        item = @storage[key]
        item.mutex.synchronize do
            return Reply::EXISTS if cas_id != item.cas_id
    
            store_item(key, flags, exptime, bytes, data_block)
            return Reply::STORED
        end
    end

    def store_item(key, flags, exptime, bytes, data_block)
        item = Item.new(key, flags, exptime, bytes, data_block)
        item.update_cas_id()
        @storage.store(key, item) unless item.expired?
    end

end
