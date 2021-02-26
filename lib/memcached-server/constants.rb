module MemcachedServer

    class CommandFormat
        # \w - A word character ([a-zA-Z0-9_])
        # \d - A digit character ([0-9])

        # Storage commands
        SET = /^(?<name>set) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        ADD = /^(?<name>add) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        REPLACE = /^(?<name>replace) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze

        APPEND = /^(?<name>append) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        PREPEND = /^(?<name>prepend) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze

        CAS = /^(?<name>cas) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+) (?<cas_id>\d+)(?<noreply>noreply)?\n/.freeze

        # Retrieval commands
        GET = /^(?<name>get) (?<keys>(\w|\p{Space})+)\n/.freeze
        GETS = /^(?<name>gets) (?<keys>(\w|\p{Space})+)\n/.freeze

        # End command
        END_ = /^(?<name>END)\n$/.freeze
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

        GET = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+)/.freeze
        GETS = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+) (?<cas_id>\d+)/.freeze

        END_ = /END/.freeze
        
    end

    class Error

        ERROR = "ERROR\r\n".freeze
        CLIENT_ERROR = "CLIENT_ERROR%s\r\n".freeze
        SERVER_ERROR = "SERVER_ERROR%s\r\n".freeze
        
    end

end
