source "https://rubygems.org"

gemspec

gem 'sqlite3', '~> 1.3.4', :platform => :ruby
gem 'jruby-openssl', :platform => :jruby
gem 'activerecord-jdbcsqlite3-adapter', :platform => :jruby
gem 'rubysl', :platform => :rbx

# Hinting at development dependencies
# Prevents bundler from taking a long-time to resolve
group :development, :test do
  gem 'mime-types', '~> 1.16'
  gem 'builder', '~> 3.1.4'
end
