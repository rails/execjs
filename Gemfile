source 'https://rubygems.org'

gemspec

group :test do
  gem 'duktape', platform: :mri
  if ENV['EXECJS_RUNTIME'] == 'MiniRacer'
     gem 'mini_racer', '0.1.0.beta.3', platform: :mri
  else
     gem 'therubyracer', platform: :mri
  end
  gem 'therubyrhino', '>=1.73.3', platform: :jruby
  gem 'minitest', require: false
end
