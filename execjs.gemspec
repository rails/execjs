Gem::Specification.new do |s|
  s.name    = "execjs"
  s.version = "0.1.1"
  s.date    = "2011-03-30"

  s.homepage    = "https://github.com/sstephenson/execjs"
  s.summary     = "Run JavaScript code from Ruby"
  s.description = <<-EOS
    ExecJS lets you run JavaScript code from Ruby.
  EOS

  s.files = [
    "lib/execjs/support",
    "lib/execjs/support/basic_runner.js",
    "lib/execjs/support/jscript_runner.js",
    "lib/execjs/support/json2.js",
    "lib/execjs/support/node_runner.js",
    "lib/execjs/support/which.bat",
    "lib/execjs/external_runtime.rb",
    "lib/execjs/ruby_racer_runtime.rb",
    "lib/execjs/ruby_rhino_runtime.rb",
    "lib/execjs/runtimes.rb",
    "lib/execjs.rb",
    "LICENSE",
    "README.md"
  ]

  s.add_development_dependency "therubyracer"
  s.add_development_dependency "therubyrhino"

  s.authors           = ["Sam Stephenson", "Josh Peek"]
  s.email             = ["sstephenson@gmail.com", "josh@joshpeek.com"]
  s.rubyforge_project = "execjs"
end
