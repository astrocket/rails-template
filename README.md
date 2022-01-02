# rails-template

## Description
rails template for kubernetes deployment

[see generated sample](https://github.com/astrocket/rails-template-stimulus)

## Requirements
* Rails 7.x (w/tailwind)
* Ruby 3.x

## Installation

To generate a Rails application using this template, pass the `-m` option to `rails new`, like this:

```bash
$ rails new project -T -d postgresql --css tailwind \
    -m https://raw.githubusercontent.com/astrocket/rails-template/master/template.rb
```

## What's included?

* Kubernetes & Docker for production deploy
* Stimulus setting for client javascript
* ActiveJob + Sidekiq + Redis setting for async jobs 
* ActiveAdmin + ArcticAdmin for application admin
* Foreman setting for integrative dev setup
* Rspec + FactoryBot setting for test code
* TailwindCSS

## Foreman start task

Procfile based applications

with `foreman start`

It runs

* rails
* tailwind
* sidekiq

## Stimulus.js generator

Stimulus specific generator task.

with `rails g stimulus posts index`

It generates

* `app/javascript/posts/index_controller.js` with sample html markup containing stimulus path helper.

## Kubernetes & Docker

With [kubernetes](https://kubernetes.io/) you can manage multiple containers with simple `yaml` files.

Template contains

* deployment [guide](k8s/README.md.tt) for DigitalOcean's cluster from scratch
* Let's Encrypt issuer and Ingress configuration
* demo deployment yaml to instantly run sample hashicorp/http-echo + nginx app
* basic puma, nginx and sidekiq deployment setup

## Testing

[rspec-rails](https://github.com/rspec/rspec-rails)

[factory-bot](https://github.com/thoughtbot/factory_bot/wiki)

> Run test specs
```bash
bundle exec rspec
```