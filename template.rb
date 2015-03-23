# Gems
# ==================================================

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

  # Guard for automatically launching your specs when files are modified. (https://github.com/guard/guard-rspec)
  gem "guard-rspec"
end

gem_group :test do
  gem "rspec-rails"
  # Capybara for integration testing (https://github.com/jnicklas/capybara)
  gem "capybara"
  gem "capybara-webkit"
  gem "launchy"
  # FactoryGirl instead of Rails fixtures (https://github.com/thoughtbot/factory_girl)
  gem "factory_girl_rails"
  gem "database_cleaner"
end

gem_group :production do
  # For Rails 4 deployment on Heroku
  gem "rails_12factor"
end


# Setting up foreman to deal with environment variables and services
# https://github.com/ddollar/foreman
# ==================================================
# Use Procfile for foreman
run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"
run "echo PORT=3000 >> .env"
run "echo '.env' >> .gitignore"
# We need this with foreman to see log output immediately
run "echo 'STDOUT.sync = true' >> config/environments/development.rb"
run "echo 'config.action_mailer.default_url_options = { host: \'localhost\', port: 3000 }' >> config/environments/development.rb"

run "bundle install"




# Initialize CanCan
# ==================================================
run "rails g cancan:ability"

# Initialize Devise
# ==================================================
run "rails generate devise:install"

run "rails generate devise User"






# Bootstrap: install from https://github.com/twbs/bootstrap
# Note: This is 3.0.0
# ==================================================
if yes?("setup bootstrap?")
  run "rails generate layout:install bootstrap3"
  run "rails generate layout:devise bootstrap3"
end

if yes?("setup Foundation?")
  run "rails generate layout:install foundation5"
  run "rails generate layout:devise foundation5"
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
