module MemcachedServer

    class Item
        
        attr_accessor :key
        attr_accessor :flags
        attr_accessor :exptime
        attr_accessor :bytes
        attr_accessor :data_block
        attr_accessor :cas_id

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

        def get_cas_id()
            @lock.synchronize do
                @@last_cas_id += 1
                next_id = @@last_cas_id.dup()
                return next_id
            end
        end

        def update_cas_id()
            @cas_id = get_cas_id()
        end

        def get_exptime(exptime)
            return nil if exptime == 0
            return Time.now().getutc() if exptime < 0
            return Time.now().getutc() + exptime
        end

        def expired?()
            return true if (!@exptime.nil?()) && (Time.now().getutc() > @exptime)
            return false
        end

    end
    
end
