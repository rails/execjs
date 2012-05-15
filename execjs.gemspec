$:.unshift File.expand_path('../lib', __FILE__)
require 'execjs/version'

Gem::Specification.new do |s|
  s.name    = "execjs"
  s.version = ExecJS::VERSION

  s.homepage    = "https://github.com/sstephenson/execjs"
  s.summary     = "Run JavaScript code from Ruby"
  s.description = "ExecJS lets you run JavaScript code from Ruby."

  s.files = Dir["README.md", "LICENSE", "lib/**/*"]

  s.add_dependency "multi_json", "~>1.0"
  s.add_development_dependency "rake"

  # mri_18  
  if (!defined?(RUBY_ENGINE) || RUBY_ENGINE == "ruby") && RUBY_VERSION < "1.9"
    # see https://github.com/jbarnette/johnson/issues/21
    s.add_development_dependency "johnson"
  end

  # mri
  if (!defined?(RUBY_ENGINE) || RUBY_ENGINE == "ruby")
    # disabled for rbx, because of https://github.com/cowboyd/therubyracer/issues/157
    s.add_development_dependency "therubyracer"
  end

  # jruby
  if (defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby")
    s.add_development_dependency "therubyrhino", ">=1.73.3"
  else
    s.add_development_dependency "mustang"
  end

  s.authors = ["Sam Stephenson", "Josh Peek"]
  s.email   = ["sstephenson@gmail.com", "josh@joshpeek.com"]
end
