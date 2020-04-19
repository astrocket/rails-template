## Start dev

```bash
bundle && yarn && rails hot
```

## Deploy

### Build docker image

from local
```bash
docker build --build-arg rails_env=production -t $DOCKER_ACC/$DOCKER_REPO:$IMG_TAG .
```

from remote (you have to pass the master_key as an build-arg)
```bash
docker build --build-arg rails_env=production --build-arg master_key=$MASTER_KEY -t $DOCKER_ACC/$DOCKER_REPO:$IMG_TAG .
```

[push to docker hub](http://blog.shippable.com/build-a-docker-image-and-push-it-to-docker-hub) (after login)
```bash
docker push $DOCKER_ACC/$DOCKER_REPO:$IMG_TAG
```

build & push image using [lib/tasks/deploy.rake](lib/tasks/deploy.rake)

```bash
rails deploy:production:push
```

### Set credentials

open credential and paste db, redis urls

```bash
EDITOR="nano" rails credentials:edit

# like this
production:
  database_url: DATABASE_URL
  redis_url: REDIS_URL
```

### Kubernetes

[k8s/README.md](k8s/README.md)