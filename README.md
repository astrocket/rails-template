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
* Nginx Proxy server configuration with Let's encrypt SSL Certificate
* Webpacker and Stimulus setting for client javascript
* ActiveJob + Sidekiq + Redis setting for async jobs 
* ActiveAdmin + ArcticAdmin for application admin
* Foreman setting for integrative dev setup
* Rspec + FactoryBot setting for test code
* Guard + LiveReload setting for hot reloading
* Slack Message Notification for Exception

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

After installing [docker](https://docs.docker.com/install/) & [docker-compose](https://docs.docker.com/compose/install/) in your host machine.

Set up a seperate [Nginx-Proxy docker container](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion) in your host machine.
```bash
git clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion.git
cd docker-compose-letsencrypt-nginx-proxy-companion
mv .env.sample .env
./start.sh
```

Clone your repository to host machine and build docker-compose.
```bash
git clone http://github.com/username/your_own_rails_repository
docker-compose build
docker-compose up -d
```

Scale your rails application to 5 replicas. [scale docker containers](https://pspdfkit.com/blog/2018/how-to-use-docker-compose-to-run-multiple-instances-of-a-service-in-development/)
```bash
docker-compose up -d --scale app=5
```

## Automated deploy task

After pushing repository to git and providing deployment information in `lib/tasks/deploy.rake` file.
You can automate above process.

```bash
rails deploy:production
```

## Testing

[rspec-rails](https://github.com/rspec/rspec-rails)
[factory-bot](https://github.com/thoughtbot/factory_bot/wiki)

> Run test specs

```bash
bundle exec rspec
```

---

## Docker CMDs

To see your live container log

```bash
docker ps
docker logs -f --tail 5 processid
```

Check images / containers

```bash
docker images -a
docker container ls -a
```

Remove all abandonded images

```bash
docker rmi -f $(docker images -a | grep "none" | awk '{print $3}')
docker rmi $(docker images -f "dangling=true" -q)
```
Destry all exited containers remove scientist name containers

```bash
docker container rm $(docker container ls -aq --filter status=exited)
```

Prune (be careful)

```bash
docker container prune
docker image prune
docker network prune
docker volume prune
```

Stop and delete specific container

```bash
docker stop processid
docker rm processid
```

## TODO
- 