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

## Production deploy process

### Create New Kubernetes cluster from DigitalOcean

https://cloud.digitalocean.com/kubernetes
Make sure to remember your cluster's name to connect later

### Install Kubectl

The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. ([link](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
```bash
brew install kubectl
# kubectl version
```

### Connect your cluster

Use the name of your cluster instead of example-cluster-01 in the following command.

> doctl is a DigitalOcean's own cli tool ([link](https://github.com/digitalocean/doctl))

```bash
brew install doctl
doctl auth init
```
Generate API Token & Paste it ([link](https://cloud.digitalocean.com/account/api/tokens))
```bash
DigitalOcean access token: your_DO_token
```
Connect
```bash
doctl kubernetes cluster kubeconfig save example-cluster-01
# kubectl config current-context
```

### Persistent Volume Claim

To persist certain kind of data(database, log, queue) from being destroyed while creating new containers we need special space to be reserved. PVC does that for you in kubernetes architecture.
We need to connect Postgres, Rails.logger, Redis with this volume later.

Create postgresql

```bash
kubectl create secret generic pg-password --from-literal=password=mysecretpass
kubectl create secret generic pg-username --from-literal=username=postgres

kubectl create -f k8s/postgres.yml
```



### Ingress (Nginx)



### Monitoring

### Deploy

Create sample app
```bash
rails new digitalocean-kubernetes-rails -T -d postgresql
```

### Auto Scaling



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
makre sure :
`process * thread * rails < db connection`

[read](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#process-count-value)

## nginx-proxy's worker_processes

[read](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion/issues/141)

By default nginx-proxy's worker_processes are limited to only 1 process & 1024 connections
If you are considering to scale up, it's recommended to allocate more processes to the proxy.

```bash
// Go to your Nginx-Proxy directory
$ cd docker-compose-letsencrypt-nginx-proxy-companion

// Create 'docker-compose.override.yml' file for custom compose option.
// see 'https://docs.docker.com/compose/extends' to understand override file.
$ nano docker-compose.override.yml

// Also add 'docker-compose.override.yml' to '.gitignore'
$ echo "docker-compose.override.yml" >> .gitignore

// Paste the below to 'docker-compose.override.yml'
version: '3'
services:
  nginx-web:
    command: /bin/bash -c "ln -sf /dev/null /var/log/nginx/access.log &&sed -i 's/worker_processes  1;/worker_processes  3;/' /etc/nginx/nginx.conf && sed -i 's/worker_connections  1024;/worker_connections  98304;/' /etc/nginx/nginx.conf && nginx -g \"daemon off;\""

// rebuild your proxy container
$ docker-compose up -d --build nginx-web
```

## Scale Containers
[read](https://pspdfkit.com/blog/2018/how-to-use-docker-compose-to-run-multiple-instances-of-a-service-in-development/)

```bash
$ docker-compose up -d --scale rails=5
```

## Limit CPU/Memory usage per Container

By default container can access to all cpus and memories.

you can limit resources per container with options.

However docker-compose 3 format does not support resource limit out of box.

If you want to enable resource limit options, you have two choices.
1. Use docker swarm.
2. Use `--compatibility` option which translates 3.0 syntax to 2.0 syntax before dockerize

Github histories about this issue
- https://github.com/docker/compose/issues/4513
- https://github.com/docker/compose/pull/5684
- https://github.com/readthedocs/readthedocs.org/pull/6295

for option 2. => [read](https://nickjanetakis.com/blog/docker-tip-78-using-compatibility-mode-to-set-memory-and-cpu-limits)



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

# Docker CMDs

## To monitor container's resource usage.

```bash
$ docker stats
```
Metric percentage of each cpu usage is `per cpu` not `per container`

Which means your container will not die when it approaches 100%.

it only dies when container can use only 1 cpu OR container's resouce cpu is limited

## To see your live container log

```bash
$ docker ps
$ docker logs -f --tail 5 processid
```

## Check images / containers

```bash
$ docker images -a
$ docker container ls -a
```

## Remove all abandonded images

```bash
$ docker rmi -f $(docker images -a | grep "none" | awk '{print $3}')
$ docker rmi $(docker images -f "dangling=true" -q)
```
## Remove all exited and scientist named containers

```bash
$ docker container rm $(docker container ls -aq --filter status=exited)
```

## Prune (be careful)

```bash
$ docker container prune
$ docker image prune
$ docker network prune
$ docker volume prune
```

## Stop and delete specific container

```bash
$ docker stop processid
$ docker rm processid
```

## TODO

## References
- Linked above
- [Tailwind CSS Integration](https://github.com/justalever/kickoff_tailwind)
- [Design Theme](https://www.tailwindtoolbox.com/templates/app-landing-page)