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
