require_relative '../../lib/memcached-server.rb'
include MemcachedServer

describe Server do

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

    it "validates a command" do
        valid_results = []
        invalid_command = "gats a b c"
        invalid_result = @server.validate_command(invalid_command)
        @valid_commmands.each_value { | value | valid_results.append(@server.validate_command(value)) }

        for r in valid_results do
            expect(r).to be_truthy
        end
        
        expect(invalid_result).to be nil
    end

end