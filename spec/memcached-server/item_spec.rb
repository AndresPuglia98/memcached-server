require_relative '../../lib/memcached-server.rb'

describe MemcachedServer::Item do
    before(:each) do
        @item_a = MemcachedServer::Item.new("a", 0, 0, 5, "value")
        @item_b = MemcachedServer::Item.new("b", 0, -1, 5, "value")
    end

    it "checks if an item is expired" do
        item_c = MemcachedServer::Item.new("c", 0, 600, 5, "value")
        
        expect(@item_a.expired?).to be false
        expect(@item_b.expired?).to be true
        expect(item_c.expired?).to be false
    end
    
end
