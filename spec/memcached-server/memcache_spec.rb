require_relative '../../lib/memcached-server.rb'
include MemcachedServer

describe Memcache do

    before(:each) do 

        @memcache = Memcache.new()
        @storage = @memcache.storage
        @item_a = Item.new("a", 0, 0, 5, "val_a")
        @item_b = Item.new("b", 0, 0, 5, "val_b")
        @item_c = Item.new("c", 0, 0, 5, "val_c")

    end

    it "should purge expired keys in storage" do

        expired_item = Item.new("key", 0, -1, 3, "val")
        item_to_expire = Item.new("kee", 0, 0.1, 3, "val")
        @storage.store(:key, expired_item)
        @storage.store(:kee, item_to_expire)

        sleep(0.1)
        @memcache.purge_keys()

        expect(@storage).to be_empty

    end

    it "should store some data but only if it wasn't updated since it was last fetched" do

        @item_a.update_cas_id()
        @storage.store("a", @item_a)

        reply_stored = @memcache.cas("a", 0, 0, 3, 1, "val")
        reply_exists = @memcache.cas("a", 0, 0, 3, 4, "val")
        reply_not_found = @memcache.cas("b", 0, 0, 3, 1, "val")

        expect(reply_stored).to eq Reply::STORED
        expect(reply_exists).to eq Reply::EXISTS
        expect(reply_not_found).to eq Reply::NOT_FOUND

    end

    it "should get the desired items if they are stored" do

        @storage.store(:a, @item_a)
        @storage.store(:b, @item_b)
        @storage.store(:c, @item_c)

        one_item = @memcache.get([:a])
        items = @memcache.get([:a, :b, :c])
        
        expect(one_item).to eq [@item_a]
        expect(items).to eq [@item_a, @item_b, @item_c]

    end

    it "should store an item with the given args and return a reply" do

        reply_stored = @memcache.set("a", 0, 0, 5, "val_a")

        expect(@storage["a"].key).to eq "a"
        expect(reply_stored).to eq Reply::STORED
        
    end

    it "should store an item only if it isn't already stored and return a reply" do

        @storage.store("a", @item_a)
        
        reply_stored = @memcache.add("b", 0, 0, 3, "val")
        reply_not_stored = @memcache.add("a", 0, 0, 3, "val")

        expect(@storage["a"].key).to eq "a"
        expect(@storage["b"].key).to eq "b"
        expect(reply_stored).to eq Reply::STORED
        expect(reply_not_stored).to eq Reply::NOT_STORED

    end

    it "should store an item only if it is already stored" do

        @storage.store("a", @item_a)
        
        reply_stored = @memcache.replace("a", 0, 0, 3, "val")
        reply_not_stored = @memcache.replace("b", 0, 0, 3, "val")

        expect(@storage["a"].data_block).to eq "val"
        expect(@storage["b"]).to be_nil
        expect(reply_stored).to eq Reply::STORED
        expect(reply_not_stored).to eq Reply::NOT_STORED

    end

    it "should add the extra data to an existing key after existing data" do

        @storage.store("a", @item_a)

        reply_stored = @memcache.append("a", 4, "_new")
        reply_not_stored = @memcache.append("b", 3, "val")

        expect(@storage["a"].data_block).to eq "val_a_new"
        expect(reply_stored).to eq Reply::STORED
        expect(reply_not_stored).to eq Reply::NOT_STORED

    end

    it "should add the extra data to an existing key before existing data" do

        @storage.store("a", @item_a)

        reply_stored = @memcache.prepend("a", 4, "new_")
        reply_not_stored = @memcache.prepend("b", 3, "val")

        expect(@storage["a"].data_block).to eq "new_val_a"
        expect(reply_stored).to eq Reply::STORED
        expect(reply_not_stored).to eq Reply::NOT_STORED

    end

    it "shoud store an item unless it is expired" do

        @memcache.store_item("a", 0, 600, 3, "val")
        @memcache.store_item("b", 0, 0, 3, "val")
        @memcache.store_item("c", 0, -1, 3, "val")

        expect(@storage.keys).to eq ["a", "b"]

    end

end
