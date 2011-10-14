source 'http://rubygems.org'

gem 'rails', '3.1.1'

# Database Adapter
gem 'mysql2', '0.3.7',                    :platforms => [:ruby]
gem 'sqlite3',                            :platforms => [:mswin, :mingw]
# gem 'mongrel', '>= 1.2.0.pre2', :platforms => [:mswin, :mingw]  # Mongrel no longer supported, development stopped
# http://unicornless.com/systems-administration/run-thin-as-windows-service
gem 'thin', '~> 1.2.11',                  :platforms => [:mswin, :mingw]
gem 'eventmachine', '~> 1.0.0.beta.4.1',  :platforms => [:mswin, :mingw]


# Gems used by project
gem 'carrierwave'                  # File Uploads

gem 'contour', '~> 0.5.0'          # Basic Layout and Assets
gem 'devise',  '~> 1.4.4'          # User Authorization
gem 'omniauth',   '0.2.6'          # User Multi-Authentication
gem 'kaminari'                     # Pagination
gem 'systemu', '~> 2.2.0'          # Running Ocra system command
gem 'ocra', :platforms => [:mingw]
gem 'rubytorrent-allspice'         # RubyTorrent library

# For announce portion of application.
gem 'ruby-tracker', :git => 'git://github.com/shaggyone/ruby-tracker.git'
gem 'bencode', :git => 'git://github.com/shaggyone/ruby-bencode.git'
gem 'bencoded-record', :git => 'git://github.com/shaggyone/bencoded-record.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'    # Compiles CSS
  gem 'coffee-rails', '~> 3.1.1'    # Compiles JavaScript
  gem 'uglifier',     '>= 1.0.3'    # Minimizes and obscures JS and CSS
end

gem 'jquery-rails'                  # JavaScript Engine

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console', :platforms => [:mswin, :mingw]
  gem 'turn', '0.8.2'
end