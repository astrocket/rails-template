## Start dev

```bash
rails db:create
rails db:migrate
bundle && yarn && rails dev
```

## Deploy

[.circleci/config.yml](https://circleci.com/)

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