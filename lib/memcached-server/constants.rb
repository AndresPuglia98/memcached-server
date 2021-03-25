module MemcachedServer

    module Settings
        ITEM_SIZE_MAX = (1024*1024).freeze # Max. byte size an item can have. Default is 1024*1024 (1MB)
    end

    module CommandFormat
        # \w - A word character ([a-zA-Z0-9_])
        # \d - A digit character ([0-9])

        # Storage commands format
        SET = /^(?<name>set) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        ADD = /^(?<name>add) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        REPLACE = /^(?<name>replace) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        APPEND = /^(?<name>append) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        PREPEND = /^(?<name>prepend) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        CAS = /^(?<name>cas) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+) (?<cas_id>\d+)(?<noreply>noreply)?\n/.freeze

        # Retrieval commands format
        GET = /^(?<name>get) (?<keys>(\w|\p{Space})+)\n/.freeze
        GETS = /^(?<name>gets) (?<keys>(\w|\p{Space})+)\n/.freeze

        # End command format
        END_ = /^(?<name>END)\n$/.freeze
    end

    module Reply

        # To indicate success.
        STORED = "STORED\n".freeze

        # To indicate the data was not stored, but not because of an error. 
        # This normally means that the condition for an "add" or a "replace" command wasn't met.
        NOT_STORED = "NOT_STORED\n".freeze
        
        # To indicate that the item you are trying to store with a "cas" command has been modified since you last fetched it.
        EXISTS = "EXISTS\n".freeze

        # To indicate that the item you are trying to store with a "cas" command did not exist.
        NOT_FOUND = "NOT_FOUND\n".freeze

        # Each item sent by the server looks like this
        GET = "VALUE %s %d %d\n%s\n".freeze
        GETS = "VALUE %s %d %d %d\n%s\n".freeze

        END_ = "END\n".freeze

    end

    module ReplyFormat

        # Each item sent by the server has this format
        GET = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+)/.freeze
        GETS = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+) (?<cas_id>\d+)/.freeze

        # To indicate the end of reply.
        END_ = /END/.freeze
        
    end

    module Error

        ERROR = "ERROR\r\n".freeze
        CLIENT_ERROR = "CLIENT_ERROR%s\r\n".freeze
        SERVER_ERROR = "SERVER_ERROR%s\r\n".freeze
        
    end

end
