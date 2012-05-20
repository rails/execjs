source :rubygems

gemspec

group :test do
  gem 'json'
  # see https://github.com/jbarnette/johnson/issues/21
  gem 'johnson',      :platform => :mri_18
  # disabled for rbx, because of https://github.com/cowboyd/therubyracer/issues/157
  gem 'therubyracer', :platform => :mri
  gem 'therubyrhino', ">=1.73.3", :platform => :jruby
end
