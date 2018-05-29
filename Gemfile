source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'bootsnap',                 '>= 1.1.0', require: false
gem 'oj',                       '~> 3.6.0'
gem 'pg',                       '~> 1.0.0'
gem 'puma',                     '~> 3.11'
gem 'rails',                    '~> 5.2.0'
gem 'sass-rails',               '~> 5.0'
gem 'sequel',                   '~> 5.8.0'
gem 'sequel-rails',             '~> 1.0.1'
gem 'uglifier',                 '>= 1.3.0'

group :development, :test do
  gem 'byebug',                 '~> 10.0.2', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen',                 '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen',  '~> 2.0.0'
  gem 'web-console',            '>= 3.3.0'
end

group :test do
  gem 'capybara',               '>= 2.15', '< 4.0'
  gem 'chromedriver-helper'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'rubocop',                require: false
  gem 'selenium-webdriver'
end
