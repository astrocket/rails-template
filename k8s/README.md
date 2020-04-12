## Prepare Kubernetes Cluster

### Create New Kubernetes cluster from DigitalOcean

https://cloud.digitalocean.com/kubernetes

### Install Kubectl

The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. ([link](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
```bash
brew install kubectl
# kubectl version
```

### Connect your cluster

Use the name of your cluster instead of example-cluster-01 in the following command.

Generate API Token & Paste it ([link](https://cloud.digitalocean.com/account/api/tokens))
```bash
DigitalOcean access token: your_DO_token
```

Authenticate through doctl command (doctl is a DigitalOcean's own cli tool [link](https://github.com/digitalocean/doctl))
```bash
brew install doctl
doctl auth init
# paste your_DO_token
```

Add your cluster to local config (you can get your cluster's name from DO's dashboard)
```bash
doctl kubernetes cluster kubeconfig save example-cluster-01
# kubectl config current-context
```

## Ingress
Following ingress document is a summary of digital ocean's official document.
+ I modified LoadBalancer part to fix the issue from generating Let's Encrypt certification.
+ upgraded resource versions
[official doc](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes)
[cert-manager issue](https://github.com/jetstack/cert-manager/issues/2759)

### Prepare some fake Apps
> k8s/echo1.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: echo1
spec:
  ports:
    - port: 80
      targetPort: 5678
  selector:
    app: echo1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo1
spec:
  selector:
    matchLabels:
      app: echo1
  replicas: 2
  template:
    metadata:
      labels:
        app: echo1
    spec:
      containers:
        - name: echo1
          image: hashicorp/http-echo
          args:
            - "-text=echo1"
          ports:
            - containerPort: 5678
```

> k8s/echo2.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: echo2
spec:
  ports:
    - port: 80
      targetPort: 5678
  selector:
    app: echo2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo2
spec:
  selector:
    matchLabels:
      app: echo2
  replicas: 1
  template:
    metadata:
      labels:
        app: echo2
    spec:
      containers:
        - name: echo2
          image: hashicorp/http-echo
          args:
            - "-text=echo2"
          ports:
            - containerPort: 5678
```

```bash
kubectl apply -f k8s/echo1.yaml
kubectl apply -f k8s/echo2.yaml
```

### Install mandatory resources
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
```

### Install load balancer service
this step, kubernetes will automatically ask digital ocean's LoadBalancer.
If you don't have any LoadBalancer unit, it will be automatically created. (also starts charging you)

> k8s/load_balancer.yaml
```yaml
kind: Service
apiVersion: v1
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  externalTrafficPolicy: Cluster
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
```
```bash
kubectl apply -f k8s/load_balancer.yaml
```

### Confirm that the Ingress Controller Pods have started
```bash
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx
```

### Confirm that the DigitalOcean Load Balancer was successfully created
```bash
kubectl get svc --namespace=ingress-nginx
```

### Create ingress resource
> k8s/echo_ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: echo-ingress
spec:
  rules:
    - host: app.adcalendar.co
      http:
        paths:
          - backend:
              serviceName: echo1
              servicePort: 80
    - host: api.adcalendar.co
      http:
        paths:
          - backend:
              serviceName: echo2
              servicePort: 80
```
```bash
kubectl apply -f k8s/echo_ingress.yaml
```

### Install Cert-Manager
Certificates can be requested and configured by annotating Ingress Resources with the cert-manager.io/issuer annotation, appending a tls section to the Ingress spec, and configuring one or more Issuers or ClusterIssuers to specify your preferred certificate authority.

```bash
# install cert-manager and its Custom Resource Definitions (CRDs) like Issuers and ClusterIssuers.
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.yaml

# Verify installation
kubectl get pods --namespace cert-manager
```

### Create SSL Issuer

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: your_email_address_here
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          class: nginx
```

```bash
kubectl create -f k8s/prod_issuer.yaml
```

### Update echo_ingress.yaml to use this new Issuer

> k8s/echo_ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: echo-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - echo1.hjdo.net
    - echo2.hjdo.net
    secretName: echo-tls
  rules:
  - host: echo1.hjdo.net
    http:
      paths:
      - backend:
          serviceName: echo1
          servicePort: 80
  - host: echo2.hjdo.net
    http:
      paths:
      - backend:
          serviceName: echo2
          servicePort: 80
```

```bash
kubectl apply -f k8s/echo_ingress.yaml
```

### Check Let's Encrypt progress

```bash
kubectl describe certificate echo-tls
```


### Debugging cert-manager
https://cert-manager.io/docs/faq/acme/

### Auto Scaling
- TODO