# rails-template

## Description
Simple rails template for general project.

## Requirements
* Rails 6.0.x
* PostgreSQL

## Installation

To generate a Rails application using this template, pass the `-m` option to `rails new`, like this:

```bash
rails new project -T -d postgresql \
    -m https://raw.githubusercontent.com/astrocket/rails-template/master/template.rb
```

*Remember that options must go after the name of the application.* The only database supported by this template is `postgresql`.

## What's included?

* Docker for production deploy
* Webpacker and Stimulus setting for client javascript
* ActiveJob + Sidekiq + Redis setting for async jobs 
* Foreman setting for integrative dev setup
* Rspec + FactoryBot setting for test code
* Guard + LiveReload setting for hot reloading

## Foreman start task

Procfile-based applications

with `rails hot`

It runs

* rails
* webpacker
* guard
* sidekiq

## Stimulus generator

Stimulus specific generator task.

with `rails g stimulus posts index`

It generates

* `app/javascript/posts/index_controller.js` with sample html markup containing stimulus path helper.

## Production deploy process

After installing docker & docker-compose.

```bash
docker-compose build
docker-compose up -d
```

To see your live application log

```bash
docker ps
docker exec -it processid bash
tail -f log/production.log
```

Automated deploy task

After pushing repository to git and providing deployment information in `lib/tasks/deploy.rake` file.
You can automate above process.

`rails deploy:production`

## Testing

[rspec-rails](https://github.com/rspec/rspec-rails)
[factory-bot](https://github.com/thoughtbot/factory_bot/wiki)

> Run test specs

```bash
bundle exec rspec
```
