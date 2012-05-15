source :rubygems

gemspec

group :test do
  gem 'johnson',      :platform => :mri_18
  gem 'json'
  # see https://github.com/nu7hatch/mustang/issues/18
  gem 'mustang',      :platform => :ruby,
    :git => "https://github.com/nu7hatch/mustang.git", :ref => "2a3bcfbd9fd0f34e9b004fcd92188f326b40ec2a"
  gem 'therubyracer', :platform => :mri
  gem 'therubyrhino', :platform => :jruby
end
