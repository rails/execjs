$:.unshift File.expand_path('../lib', __FILE__)
require 'execjs/version'

Gem::Specification.new do |s|
  s.name    = "execjs"
  s.version = ExecJS::VERSION

  s.homepage    = "https://github.com/rails/execjs"
  s.summary     = "Run JavaScript code from Ruby"
  s.description = "ExecJS lets you run JavaScript code from Ruby."

  s.files = Dir["README.md", "LICENSE", "lib/**/*"]

  s.add_development_dependency "rake"

  s.licenses = ['MIT']

  s.authors = ["Sam Stephenson", "Josh Peek"]
  s.email   = ["sstephenson@gmail.com", "josh@joshpeek.com"]

  case RUBY_ENGINE
    when 'jruby'
      s.required_ruby_version = '>= 1.7.16'
    else
      s.required_ruby_version = '>= 2.0.0'
  end
end
