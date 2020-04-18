template "k8s/README.md.tt"
template "k8s/demo.yaml.tt"

template "k8s/ingress.yaml.tt"
template "k8s/service.yaml.tt"
template "k8s/web.yaml.tt"
template "k8s/sidekiq.yaml.tt"
template "k8s/migration.yaml.tt"

template "k8s/project/application-nginx-conf.yaml.tt", "k8s/project/#{k8s_name}-nginx-conf.yaml"
template "k8s/cluster/lets_encrypt_issuer.yaml.tt"
copy_file "k8s/cluster/load_balancer.yaml", "k8s/cluster/load_balancer.yaml", force: true
copy_file "k8s/sidekiq_quite.sh"