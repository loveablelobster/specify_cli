require File.join([File.dirname(__FILE__),'lib','specify','version.rb'])

spec = Gem::Specification.new do |s|
  s.name = 'specify_cli'
  s.version = Specify::VERSION
  s.author = 'Martin Stein'
  s.licenses = ['MIT']
  s.email = 'loveablelobster@fastmail.fm'
  s.homepage = 'https://github.com/loveablelobster/specify_cli'
  s.platform = Gem::Platform::RUBY
  s.summary = Specify::SUMMARY
  s.description = Specify::DESCRIPTION
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','specify_cli.rdoc']
  s.rdoc_options << '--title' << 'specify_cli' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'specify_cli'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.17.1')
  s.add_runtime_dependency('mysql2','0.5.2')
  s.add_runtime_dependency('sequel','5.11.0')
end
