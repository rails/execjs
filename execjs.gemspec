Gem::Specification.new do |s|
  s.name      = "execjs"
  s.version   = "0.0.0"
  s.date      = "2011-02-06"

  s.homepage    = "https://github.com/sstephenson/execjs"
  s.summary     = "Run JavaScript from Ruby"
  s.description = <<-EOS
    ExecJS lets you run JavaScript code from Ruby.
  EOS

  s.files = [
    "lib/execjs",
    "lib/execjs/external_runtime.rb",
    "lib/execjs/runners",
    "lib/execjs/runners/basic.js",
    "lib/execjs/runners/node.js",
    "lib/execjs/runtimes.rb",
    "lib/execjs/v8_runtime.rb",
    "lib/execjs.rb"
  ]

  s.add_development_dependency "therubyracer"

  s.authors           = ["Sam Stephenson"]
  s.email             = "sstephenson@gmail.com"
  s.rubyforge_project = "execjs"
end
