# Gems
# ==================================================

# Segment.io as an analytics solution (https://github.com/segmentio/analytics-ruby)
gem "analytics-ruby"
# For encrypted password
gem "bcrypt-ruby"
run "sed '/sass-rails/d' Gemfile -i"
# For authorization (https://github.com/ryanb/cancan)
gem "cancancan"
gem "sass-rails"
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
  gem 'better_errors'
  gem 'web-console'
  gem 'byebug'
  gem 'rubocop', require: false
end


gem_group :production do
  # For Rails 4 deployment on Heroku
  gem "rails_12factor"
  gem 'pg'
end

    dev_email_text = <<-TEXT
  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
TEXT

inject_into_file 'config/environments/development.rb', dev_email_text, :after => "config.assets.debug = true"

run "bundle install"


# Initialize CanCan
# ==================================================

# Initialize Devise
# ==================================================
run "rails generate devise:install"

run "rails generate devise User"
inject_into_file 'config/routes.rb', "  root to: 'visitors#new'\n", :after => "routes.draw do\n"
run "rake db:migrate"



copy_from_repo '.rubocop.yml'

# Bootstrap: install from https://github.com/twbs/bootstrap
# Note: This is 3.0.0
# ==================================================
if yes?("setup bootstrap?")
  run "rails generate  simple_form:install --bootstrap"
  run "rails generate  layout:install bootstrap3"
  run "rails generate  layout:devise bootstrap3"
 elsif yes?("setup Foundation?")
  run "rails generate  simple_form:install --foundation"
  run "rails generate  layout:install foundation5"
  run "rails generate  layout:devise foundation5"
end
run "rails g cancan:ability"

# Setting up foreman to deal with environment variables and services
# https://github.com/ddollar/foreman
# ==================================================
# Use Procfile for foreman
run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"
run "echo PORT=3000 >> .env"
run "echo '.env' >> .gitignore"
# We need this with foreman to see log output immediately
run "echo 'STDOUT.sync = true' >> config/environments/development.rb"


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


def copy_from_repo(filename, opts = {})
repo = 'https://raw.github.com/RailsApps/rails-composer/master/files/'
repo = opts[:repo] unless opts[:repo].nil?
if (!opts[:prefs].nil?) && (!prefs.has_value? opts[:prefs])
return
end
source_filename = filename
destination_filename = filename
unless opts[:prefs].nil?
if filename.include? opts[:prefs]
destination_filename = filename.gsub(/\-#{opts[:prefs]}/, '')
end
end
if (prefer :templates, 'haml') && (filename.include? 'views')
remove_file destination_filename
destination_filename = destination_filename.gsub(/.erb/, '.haml')
end
if (prefer :templates, 'slim') && (filename.include? 'views')
remove_file destination_filename
destination_filename = destination_filename.gsub(/.erb/, '.slim')
end
begin
remove_file destination_filename
if (prefer :templates, 'haml') && (filename.include? 'views')
create_file destination_filename, html_to_haml(repo + source_filename)
elsif (prefer :templates, 'slim') && (filename.include? 'views')
create_file destination_filename, html_to_slim(repo + source_filename)
else
get repo + source_filename, destination_filename
end
rescue OpenURI::HTTPError
say_wizard "Unable to obtain #{source_filename} from the repo #{repo}"
end
end
