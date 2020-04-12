# rails-template

## Description
Simple rails template for general project.

## Requirements
* Rails 6.0.x
* PostgreSQL

## Installation

To generate a Rails application using this template, pass the `-m` option to `rails new`, like this:

```bash
$ rails new project -T -d postgresql \
    -m https://raw.githubusercontent.com/astrocket/rails-template/master/template.rb
```

*Remember that options must go after the name of the application.* The only database supported by this template is `postgresql`.

## What's included?

* Kubernetes & Docker for production deploy
* Nginx Proxy server configuration with Let's encrypt SSL Certificate
* React / Stimulus setting for client javascript
* ActiveJob + Sidekiq + Redis setting for async jobs 
* ActiveAdmin + ArcticAdmin for application admin
* Foreman setting for integrative dev setup
* Rspec + FactoryBot setting for test code
* Guard + LiveReload setting for hot reloading
* Slack Message Notification for Exception
* Tailwind CSS for styling

## Foreman start task

Procfile-based applications

with `rails hot`

It runs

* rails
* webpacker
* guard
* sidekiq

## Stimulus.js

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

- react layout : `react.html.erb`
- routing for react : `/:path => 'react#index'`
- routing for rails : `/api`, `/app`
- some examples with routing over rails pages <-> react pages
- example functional component with fetching api from client to server.

## Testing

[rspec-rails](https://github.com/rspec/rspec-rails)

[factory-bot](https://github.com/thoughtbot/factory_bot/wiki)

> Run test specs
```bash
bundle exec rspec
```

# Deploy

## Kubernetes, LoadBalancer, Let's Encrypt, Scaling
[k8s/README.md](k8s/README.md)
[deploy yaml](https://webcloudpower.com/helm-rails-static-files-path/)

## Databases

You can either

1. set up your own postgres / redis deployment Pod
2. use managed database from digital ocean and use Connection String

## Automated deploy task

After pushing repository to git and providing deployment information in `lib/tasks/deploy.rake` file.

You can automate deploying process.

```bash
$ rails deploy:production
```

# Tuning

## puma

default puma's process = 1

default puma's thread = 5

default rails container count = 1

default digital ocean's basic postgres database connection = 22 ~ 25

make sure :
`process * thread * rails < db connection`

[read](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#process-count-value)

## Ingress

To make your service scalable, you have to tune ingress-nginx as your needs.

https://kubernetes.github.io/ingress-nginx/

As you can read out from guide above, you have 3 ways to tune ingress-nginx.

**ConfigMap** : Global options for every ingress (like worker_process, worker_connection, proxy-body-size ..)

**Annotation** : Per ingress options (like ssl, proxy-body-size..)

**Custom Template** : Using file

If you configure the same option using Annotation and ConfigMap, Annotation will override ConfigMap. (ex. proxy-body-size)

https://github.com/nginxinc/kubernetes-ingress/tree/master/examples

> example of scalable websocket server architecture

```text
ws.example.com ->
LoadBalancer ->
Websocket supportive Nginx Ingress with SSL (with enough worker_connections) ->
Anycable Go server ->
Anycable RPC rails server
```

## Managing container logs through Logrotate
[read](https://sandro-keil.de/blog/logrotate-for-docker-container/)

```bash
$ sudo nano /etc/logrotate.d/docker-container

// paste below

/var/lib/docker/containers/*/*.log {
  rotate 7
  daily
  compress
  missingok
  delaycompress
  copytruncate
}
```


## TODO

## References
- Linked above
- [Tailwind CSS Integration](https://github.com/justalever/kickoff_tailwind)
- [Design Theme](https://www.tailwindtoolbox.com/templates/app-landing-page)