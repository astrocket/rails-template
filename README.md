# rails-template

## Description
Simple rails template for general project.

## Requirements
* Rails 6.0.x
* Ruby 2.6.x

## Installation

To generate a Rails application using this template, pass the `-m` option to `rails new`, like this:

```bash
$ rails new project -T -d postgresql \
    -m https://raw.githubusercontent.com/astrocket/rails-template/master/template.rb
```

## What's included?

* Kubernetes & Docker for production deploy
* React / Stimulus setting for client javascript
* ActiveJob + Sidekiq + Redis setting for async jobs 
* ActiveAdmin + ArcticAdmin for application admin
* Foreman setting for integrative dev setup
* Rspec + FactoryBot setting for test code
* Guard + LiveReload setting for hot reloading
* Slack Message Notification for Exception
* [Tailwind CSS](https://github.com/justalever/kickoff_tailwind) with simple [theme](https://www.tailwindtoolbox.com/templates/app-landing-page)

## Foreman start task

Procfile based applications

with `rails hot`

It runs

* rails
* webpacker
* guard
* sidekiq

## Stimulus.js (productive)

With [stimulus.js]([https://stimulusjs.org](https://stimulusjs.org/)) you can keep your client-side code style as basic style `html + css + js` stack and still get the advantages of modern Javascript open sources through npm.

###  generator

Stimulus specific generator task.

with `rails g stimulus posts index`

It generates

* `app/javascript/posts/index_controller.js` with sample html markup containing stimulus path helper.

## React.js

With [react.js](https://reactjs.org/) you can build modern single page application. (This template implements react.js with hooks.)

In order to integrate react.js and rails.

Template contains

* react layout : `react.html.erb`
* routing for react : `/:path => 'react#index'`
* routing for rails : `/api`, `/app`
* some examples with routing over rails pages <-> react pages
* example functional component with fetching api from client to server.

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