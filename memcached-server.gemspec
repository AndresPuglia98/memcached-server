require 'rake'

Gem::Specification.new do |spec|
  
  spec.name          = 'memcached-server'
  spec.version       = '1.0.2'
  spec.authors       = ['José Andrés Puglia Laca']
  spec.email         = ['andrespuglia98@gmail.com']
  spec.summary       = 'A simple Memcached server implemented in Ruby.'
  spec.description   = 'A simple Memcached server (TCP/IP socket) that complies with the specified protocol. Implemented in Ruby.'
  spec.homepage      = 'https://github.com/AndresPuglia98/memcached-server'
  spec.license       = 'MIT'

  spec.files         = FileList['lib/memcached-server/**.rb', 'lib/**.rb'].to_a
  spec.executables   = ['memcached-server', 'memcached-client']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.10.1'
  spec.add_development_dependency 'rake', '~> 13.0.1'

end
