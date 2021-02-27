require_relative './item.rb'
require_relative './constants.rb'

module MemcachedServer

    # The class used to process Memcache commands and store the Memcache server data
    class Memcache

        # The Hash map used to store the Memcache server data
        #
        # @return [Hash]
        attr_reader :storage

        def initialize()

            @storage = Hash.new()

        end

        # Deletes @storage items if they are expired 
        def purge_keys()

            @storage.delete_if { | key, item | item.expired? }

        end

        # Retrieves the items corresponding to the given keys from @storage
        # 
        # @param keys [[String]] Array that contains the keys of the items to retrieve
        # @return [[MemcachedServer::Item]] Array of the retrieved MemcachedServer::Item instances
        def get(keys)

            purge_keys()

            items = @storage.values_at(*keys)
            return items

        end

        # Stores a MemcachedServer::Item, with the attributes recieved by param, in @storage 
        # Depends on #store_item method
        # 
        # @param key [String] The key of the item to store
        # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
        # @param exptime [Integer] The exptime of the Item to store
        # @param bytes [Integer] The byte size of <data_block>
        # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
        # @return [String] The reply that describes the result of the operation
        def set(key, flags, exptime, bytes, data_block)

            store_item(key, flags, exptime, bytes, data_block)
            return Reply::STORED

        end

        # Stores a MemcachedServer::Item, with the attributes recieved by param, in @storage only if it isn't already stored
        # Depends on #store_item method
        # 
        # @param key [String] The key of the item to store
        # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
        # @param exptime [Integer] The exptime of the Item to store
        # @param bytes [Integer] The byte size of <data_block>
        # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
        # @return [String] The reply that describes the result of the operation
        def add(key, flags, exptime, bytes, data_block)

            purge_keys()
            
            return Reply::NOT_STORED if @storage.key?(key)
            
            store_item(key, flags, exptime, bytes, data_block)
            return Reply::STORED

        end

        # Replaces a MemcachedServer::Item stored in @storage, with a new one with the attributes recieved by param
        # Depends on #store_item method
        # 
        # @param key [String] The key of the item to store
        # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
        # @param exptime [Integer] The exptime of the Item to store
        # @param bytes [Integer] The byte size of <data_block>
        # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
        # @return [String] The reply that describes the result of the operation
        def replace(key, flags, exptime, bytes, data_block)
            
            return Reply::NOT_STORED unless @storage.key?(key)

            store_item(key, flags, exptime, bytes, data_block)
            return Reply::STORED

        end
        
        # Appends <new_data> to a MemcachedServer::Item data_block that is stored in @storage with an associated <key>
        # 
        # @param key [String] The key of the item to store
        # @param bytes [Integer] The byte size of <new_data>
        # @param new_data [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
        # @return [String] The reply that describes the result of the operation
        def append(key, bytes, new_data)

            purge_keys()

            return Reply::NOT_STORED unless @storage.key?(key)

            item = @storage[key]
            item.lock.synchronize do

                item.data_block.concat(new_data)
                item.bytes += bytes

            end

            item.update_cas_id()
            return Reply::STORED

        end

        # Prepends <new_data> to a MemcachedServer::Item data_block that is stored in @storage with an associated <key>
        # 
        # @param key [String] The key of the item to store
        # @param bytes [Integer] The byte size of <new_data>
        # @param new_data [String] Is a chunk of arbitrary 8-bit data of length <bytes>
        # @return [String] The reply that describes the result of the operation
        def prepend(key, bytes, new_data)

            purge_keys()

            return Reply::NOT_STORED unless @storage.key?(key)

            item = @storage[key]
            item.lock.synchronize do 

                item.data_block.prepend(new_data)
                item.bytes += bytes

            end

            item.update_cas_id()
            return Reply::STORED

        end

        # Check and set operation that stores a MemcachedServer::Item only if no one else has updated since it was last fetched
        # Depends on #store_item method
        # 
        # @param key [String] The key of the item to store
        # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
        # @param exptime [Integer] The exptime of the Item to store
        # @param bytes [Integer] The byte size of <data_block>
        # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes>
        # @param cas_id [Integer] Is a unique integer value
        # @return [String] The reply that describes the result of the operation
        def cas(key, flags, exptime, bytes, cas_id, data_block)

            purge_keys()

            return Reply::NOT_FOUND unless @storage.key?(key)

            item = @storage[key]
            item.lock.synchronize do

                return Reply::EXISTS if cas_id != item.cas_id

            end
        
            store_item(key, flags, exptime, bytes, data_block)
            return Reply::STORED

        end

        # Stores a MemcachedServer::Item, with the attributes recieved by param, in @storage
        # Before storing the MemcachedServer::Item it updates it's cas_id
        # 
        # @param key [String] The key of the item to store
        # @param flags [Integer] Is an arbitrary unsigned integer (written out in decimal)
        # @param exptime [Integer] The exptime of the Item to store
        # @param bytes [Integer] The byte size of <data_block>
        # @param data_block [String] Is a chunk of arbitrary 8-bit data of length <bytes> 
        # @return [String] The reply that describes the result of the operation
        def store_item(key, flags, exptime, bytes, data_block)

            item = Item.new(key, flags, exptime, bytes, data_block)
            item.update_cas_id()
            item.lock.synchronize do
                
                @storage.store(key, item) unless item.expired?()

            end

        end

    end

end
