module MemcachedServer

    class CommandFormat
        # \w - A word character ([a-zA-Z0-9_])
        # \d - A digit character ([0-9])

        # Storage commands
        SET = /^(?<name>set) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/
        ADD = /^(?<name>add) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/
        REPLACE = /^(?<name>replace) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/

        APPEND = /^(?<name>append) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/
        PREPEND = /^(?<name>prepend) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/

        CAS = /^(?<name>cas) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+) (?<cas_id>\d+)(?<noreply>noreply)?\n/

        # Retrieval commands
        GET = /^(?<name>get) (?<keys>(\w|\p{Space})+)\n/
        GETS = /^(?<name>gets) (?<keys>(\w|\p{Space})+)\n/

        # End command
        END_ = /^(?<name>END)\n$/
    end

    class Reply

        STORED = "STORED\n".freeze
        NOT_STORED = "NOT_STORED\n".freeze
        EXISTS = "EXISTS\n".freeze
        NOT_FOUND = "NOT_FOUND\n".freeze

        GET = "VALUE %s %d %d\n%s\n".freeze
        GETS = "VALUE %s %d %d %d\n%s\n".freeze

        END_ = "END\n".freeze

    end

    class ReplyFormat

        GET = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+)/
        GETS = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+) (?<cas_id>\d+)/

        END_ = /END/
        
    end

    class Error

        ERROR = "ERROR\r\n".freeze
        CLIENT_ERROR = "CLIENT_ERROR%s\r\n".freeze
        SERVER_ERROR = "SERVER_ERROR%s\r\n".freeze
        
    end

end