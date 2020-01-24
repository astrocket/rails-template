template "docker/rails/Dockerfile.tt"
copy_file "docker/rails/run.sh", "docker/rails/run.sh", force: true
template "docker/sidekiq/Dockerfile.tt"
copy_file "docker/sidekiq/run.sh", "docker/sidekiq/run.sh", force: true
template "docker/nginx/Dockerfile.tt"
template "docker/nginx/nginx.conf.tt"
template 'docker-compose.yml'