# How to Rails
### Create the app
```bash
$ rails new imageshare
$ cd imageshare
```
### Adding gems
Add the following to your Gemfile
```ruby
gem 'bootstrap-sass'
gem 'bcrypt', '~> 3.1.7'
gem 'devise'
gem 'paperclip'
gem 'pg'
```
### Creating databases
Edit your config/database.yml file to look like the following
```ruby
# SQLite version 3.x
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: postgresql
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: imageshare_dev

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: imageshare_test

production:
  <<: *default
  database: imageshare_prod
```
Then run the following commands
```bash
$ bundle install
$ rake db:create
```
### Creating the User model
We're not gonna bother with Devise for this, since it's too restrictive for our purposes
```bash
$ rails g model User first_name:string last_name:string email:string username:string password_digest:string dob:date
$ rake db:migrate
```