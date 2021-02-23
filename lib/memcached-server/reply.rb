module MemcachedServer

    class Reply

        STORED = "STORED\n".freeze
        NOT_STORED = "NOT_STORED\n".freeze
        EXISTS = "EXISTS\n".freeze
        NOT_FOUND = "NOT_FOUND\n".freeze

        GET = "VALUE %s %d %d\n%s\n".freeze
        GETS = "VALUE %s %d %d %d\n%s\n".freeze

        END_ = "END\n".freeze

    end

end
