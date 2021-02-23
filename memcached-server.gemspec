Gem::Specification.new do |spec|
  spec.name          = 'memcached-server'
  spec.version       = '1.0.0'
  spec.authors       = ['José Andrés Puglia Laca']
  spec.email         = ['andrespuglia98@gmail.com']
  spec.summary       = 'A simple Memcached server implemented in Ruby.'
  spec.description   = 'A simple Memcached server (TCP/IP socket) that complies with the specified protocol. Implemented in Ruby.'
  spec.homepage      = 'https://github.com/AndresPuglia98/memcached-server'
  spec.license       = 'MIT'

  spec.files         = ['lib/memcached-server.rb']
  spec.executables   = ['bin/memcached-server_server', 'bin/memcached-server_client']
  spec.test_files    = ['tests/test_memcached-server.rb']
  spec.require_paths = ['lib']
end
