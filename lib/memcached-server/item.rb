module MemcachedServer

    # Class that wraps up a Memcached Item
    class Item

        # The key under which the client asks to store the data
        #
        # @return [String]
        attr_accessor :key

        # Is an arbitrary unsigned integer (written out in decimal)
        #
        # @return [Integer]
        attr_accessor :flags

        # The expiration time
        #
        # @return [Integer]
        attr_accessor :exptime

        # The bite size of <data_block>
        #
        # @return [Integer]
        attr_accessor :bytes

        # Is a chunk of arbitrary 8-bit data of length <bytes>
        #
        # @return [Hash]
        attr_accessor :data_block

        # A unique integer value
        #
        # @return [Integer]
        attr_accessor :cas_id

        # A simple semaphore that can be used to coordinate access to shared data from multiple concurrent threads.
        #
        # @return [Mutex]
        attr_accessor :lock

        @@last_cas_id = 0

        def initialize(key, flags, exptime, bytes, data_block)

            @key = key
            @flags = flags
            @exptime = get_exptime(exptime)
            @bytes = bytes
            @data_block = data_block

            @lock = Mutex.new()

        end

        # Gets the next cas_id value read from #last_cas_id class variable
        # 
        # @return [Integer] The next cas_id
        def get_cas_id()

            @lock.synchronize do

                @@last_cas_id += 1
                next_id = @@last_cas_id.dup()
                
                return next_id

            end
        end
        
        # Updates the MemcachedServer::Item #cas_id with the corresponding next value read from #last_cas_id class variable
        def update_cas_id()

            @cas_id = get_cas_id()

        end

        # Parses the exptime of the MemcachedServer::Item instance
        # 
        # @param exptime [Integer] The expiration time
        # @return [Time, nil] The expiration time
        def get_exptime(exptime)

            return nil if exptime == 0
            return Time.now().getutc() if exptime < 0
            return Time.now().getutc() + exptime

        end

        # Checks if a MemcachedServer::Item instance is expired
        # 
        # @return [Boolean] true if it's expired and otherwise false
        def expired?()

            return true if (!@exptime.nil?()) && (Time.now().getutc() > @exptime)
            return false

        end

    end
    
end
