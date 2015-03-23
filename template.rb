# Gems
# ==================================================
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Segment.io as an analytics solution (https://github.com/segmentio/analytics-ruby)
gem "analytics-ruby"
# For encrypted password
gem "bcrypt-ruby"

# For authorization (https://github.com/ryanb/cancan)
gem "cancancan"

gem "devise"

case ask("Choose Front end framework Engine:", :limited_to => %w[bootstrap foundation])
when "bootstrap"
  # HAML templating language (http://haml.info)
  gem 'bootstrap-sass'
when "foundation"
  # A lightweight templating engine (http://slim-lang.com)
  gem "foundation-rails"
end

# Simple form builder (https://github.com/plataformatec/simple_form)
gem "simple_form", git: "https://github.com/plataformatec/simple_form"
# To generate UUIDs, useful for various things
gem "uuidtools"

gem_group :development do
  # Rspec for tests (https://github.com/rspec/rspec-rails)
  gem "rspec-rails"
  gem "rails_layout"
end


gem_group :production do
  # For Rails 4 deployment on Heroku
  gem "rails_12factor"
end

    dev_email_text = <<-TEXT
  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
TEXT

inject_into_file 'config/environments/development.rb', dev_email_text, :after => "config.assets.debug = true"

run "bundle install"



# Initialize CanCan
# ==================================================
run "rails g cancan:ability"

# Initialize Devise
# ==================================================
run "rails generate devise:install"

run "rails generate devise User"

run "rake db:migrate"





# Bootstrap: install from https://github.com/twbs/bootstrap
# Note: This is 3.0.0
# ==================================================
if yes?("setup bootstrap?")
  run "rails generate layout:install bootstrap3"
  run "rails generate layout:devise bootstrap3"
  run "rails generate simple_form:install --bootstrap"
end

if yes?("setup Foundation?")
  run "rails generate layout:install foundation5"
  run "rails generate layout:devise foundation5"
  run "rails generate simple_form:install --foundation"
end


# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run "cat << EOF >> .gitignore
/.bundle
/db/*.sqlite3
/db/*.sqlite3-journal
/log/*.log
/tmp
database.yml
doc/
*.swp
*~
.project
.idea
.secret
.DS_Store
EOF"


# Git: Initialize
# ==================================================
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

if yes?("Initialize GitHub repository?")
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say "Repository already exists:"
    say "#{git_uri}"
  else
    username = ask "What is your GitHub username?"
    run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
    git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
    git push: %Q{ origin master }
  end
end
