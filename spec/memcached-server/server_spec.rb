require_relative '../../lib/memcached-server.rb'
include MemcachedServer

RSpec.describe Server do

    before(:all) do

        @server = Server.new('localhost', 2000)

        @valid_commmands = {

            valid_get: "get a b c\n",
            valid_gets: "gets a b c\n",
            valid_set: "set a 0 3600 3\n",
            valid_add: "add a 0 3600 3\n",
            valid_replace: "replace a 0 3600 3\n",
            valid_append: "append a 3\n",
            valid_prepend: "prepend a 3\n",
            valid_cas: "cas a 0 3600 3 1\n",
            valid_end: "END\n"

        }

    end

    describe "#validate_command" do

        context "when success" do
            let(:valid_results) { @valid_commmands.each_value.map { | value | @server.validate_command(value) } }

            it "returns a valid command match" do

                for result in valid_results do
                    expect(result).to be_truthy
                end

            end
        end

        context "when failure" do
            let(:invalid_command) { "gats a b c" }
            let(:invalid_result) { @server.validate_command(invalid_command) }

            it "returns nil" do
                expect(invalid_result).to be nil
            end
        end
    end

end