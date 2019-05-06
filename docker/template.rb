template "docker/app/Dockerfile.tt"
copy_file "docker/app/run.sh", "docker/app/run.sh", force: true
template "docker/sidekiq/Dockerfile.tt"
copy_file "docker/sidekiq/run.sh", "docker/sidekiq/run.sh", force: true
template "docker/web/Dockerfile.tt"
template "docker/web/nginx.conf.tt"