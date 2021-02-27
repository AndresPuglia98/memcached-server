# Memcached server
A Ruby Memcached server (TCP/IP socket) that complies with the specified protocol.

About Memcached:

> Free & open source, high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.

## Dependencies
* rake ~> 13.0.1

* rspec ~> 3.10.1

## Setup
### Install gem with 
```
gem install memcached-server
```
### Run a Memcached server instance
```
memcached-server <hostname or IP address> <port>
```
### Run a Memcache client instance
```
memcached-client <hostname or IP address> <port>
```

## Usage
### Storage commands

First, the client sends a command line which looks like this:

```<command name> <key> <flags> <exptime> <bytes> [noreply]\r\n```

```cas <key> <flags> <exptime> <bytes> <cas unique> [noreply]\r\n```


* ```<command name>``` is "set", "add", "replace", "append" or "prepend"

* "set" means "store this data".

* "add" means "store this data, but only if the server *doesn't* already
  hold data for this key".

* "replace" means "store this data, but only if the server *does*
  already hold data for this key".

* "append" means "add this data to an existing key after existing data".

* "prepend" means "add this data to an existing key before existing data".

* The append and prepend commands do not accept flags or exptime.
  They update existing data portions, and ignore new flag and exptime
  settings.

* "cas" is a check and set operation which means "store this data but
  only if no one else has updated since I last fetched it."

* ```<key>``` is the key under which the client asks to store the data

* ```<flags>``` is an arbitrary unsigned integer (written out in
  decimal) that the server stores along with the data and sends back
  when the item is retrieved. Clients may use this as a bit field to
  store data-specific information; this field is opaque to the server.
  
* ```<exptime>``` is expiration time. If it's 0, the item never expires. If it's non-zero  (either Unix time or offset in seconds from
  current time), it is guaranteed that clients will not be able to
  retrieve this item after the expiration time arrives (measured by
  server time). If a negative value is given the item is immediately
  expired.

* ```<bytes>``` is the number of bytes in the data block to follow, *not*
  including the delimiting \r\n. <bytes> may be zero (in which case
  it's followed by an empty data block).

* ```<cas unique>``` is a unique integer value of an existing entry.
  Clients should use the value returned from the "gets" command
  when issuing "cas" updates.

* "noreply" optional parameter instructs the server to not send the
  reply.  NOTE: if the request line is malformed, the server can't
  parse "noreply" option reliably.  In this case it may send the error
  to the client, and not reading it on the client side will break
  things.  Client should construct only valid requests.

After this line, the client sends the data block:

```<data block>\r\n```

* ```<data block>``` is a chunk of arbitrary 8-bit data of length ```<bytes>```
  from the previous line.

After sending the command line and the data block the client awaits
the reply, which may be:

* "STORED\r\n", to indicate success.

* "NOT_STORED\r\n" to indicate the data was not stored, but not
because of an error. This normally means that the
condition for an "add" or a "replace" command wasn't met.

* "EXISTS\r\n" to indicate that the item you are trying to store with
a "cas" command has been modified since you last fetched it.

* "NOT_FOUND\r\n" to indicate that the item you are trying to store
with a "cas" command did not exist.


### Retrieval commands:

The retrieval commands "get" and "gets" operate like this:

```get <key>*\r\n```

```gets <key>*\r\n```

* ```<key>``` means one or more key strings separated by whitespace.

After this command, the client expects zero or more items, each of
which is received as a text line followed by a data block. After all
the items have been transmitted, the server sends the string

"END\r\n"

to indicate the end of response.

Each item sent by the server looks like this:

```VALUE <key> <flags> <bytes> [<cas unique>]\r\n```

```<data block>\r\n```

* ```<key>``` is the key for the item being sent

* ```<flags>``` is the flags value set by the storage command

* ```<bytes>``` is the length of the data block to follow, *not* including
  its delimiting \r\n

* ```<cas unique>``` is a unique unsigned integer that uniquely identifies
  this specific item.

* ```<data block>``` is the data for this item.

If some of the keys appearing in a retrieval request are not sent back
by the server in the item list this means that the server does not
hold items with such keys (because they were never stored, or stored
but deleted to make space for more items, or expired, or explicitly
deleted by a client).

## Tests
Run all tests with 
```
rake
```

### JMeter tests
JMeter tests showed that the server can support up to aprox. 1900 new connections in 1 second, and aprox. 2000 new connections with a frecuency of 10 connections per second.
