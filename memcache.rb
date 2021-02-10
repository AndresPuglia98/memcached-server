require 'concurrent'

class Memcache

    attr_reader :data_store

    def initialize
       @data_store Concurrent::Hash.new()
    end
    
end