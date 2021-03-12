require_relative '../../lib/memcached-server.rb'
include MemcachedServer

RSpec.describe Item do

    describe "#expired?" do

        context "when expired" do
            let(:expired_item) { Item.new("a", 0, -1, 5, "value") }

            it "returns true" do
                expect(expired_item.expired?).to be true
            end
        end

        context "when not expired" do
            let(:not_expired_item) { Item.new("a", 0, 600, 5, "value") }

            it "returns false" do
                expect(not_expired_item.expired?).to be false
            end
        end

        context "when never expires" do
            let(:never_expired_item) { Item.new("b", 0, 0, 5, "value") }

            it "returns false" do
                expect(never_expired_item.expired?).to be false
            end
        end
        
    end
    
end
