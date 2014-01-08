Gem::Specification.new do |s|
  s.name      = 'methodize'
  s.version   = '0.3.1'
  s.platform  = Gem::Platform::RUBY
  s.authors   = ['Luis Cipriani', 'Marcelo Manzan', 'Luiz Rocha']
  s.email     = ['lfcipriani@gmail.com', 'manzan@gmail.com', 'lsdrocha@gmail.com']
  s.homepage  = 'http://talleye.com'
  s.summary   = 'Module to read from and write to the keys of a ruby Hash using methods'
  s.files     = Dir['README.md', 'lib/**/*.rb', 'test/**/*.rb']
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
end
