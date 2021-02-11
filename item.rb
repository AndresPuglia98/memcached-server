class Item

    attr_accessor :key
    attr_accessor :flags
    attr_accessor :exptime
    attr_accessor :bytes
    attr_accessor :cas_unique
    attr_accessor :data_block

    def initialize(key, flags, exptime, bytes, data_block)
        @key = key
        @flags = flags
        @bytes = bytes
        @exptime = exptime
        @data_block = data_block
    end

    def to_s()
        return "Item key: #{@key}"
    end
end