# Chapter 3

## Figures

### Figure 3-1: _values.yaml_

```yaml
# Settings under "global" pertain to all components
# of the Consul installation.
global:
  # The name of your installation. This should always
  # be set to consul.
  name: consul
  # Enable metrics so you can observe what's happening
  # in your installation.
  metrics:
    enabled: true
  # Consul image.
  image: hashicorp/consul:1.11.5
  # Envoy image.
  imageEnvoy: envoyproxy/envoy:v1.20.2

# Settings under "server" configure Consul servers.
server:
  # replicas sets the number of servers.
  # In production, this should be 3 or 5, however
  # for testing, this should be set to 1.
  replicas: 1

# Enable Consul's service mesh functionality.
connectInject:
  enabled: true

# Settings under "controller" configure Consul's controller
# that manages custom resources.
# Custom resources are covered in later chapters.
controller:
  enabled: true

# Install Prometheus, a metrics database.
prometheus:
  enabled: true

# Settings under "ui" configure the Consul UI.
ui:
  service:
    # Use a load balancer service in
    # front of the Consul UI so we can access it using
    # minikube tunnel.
    type: LoadBalancer
    # Use port 8500 for the UI.
    port:
      http: 8500

```

### Figure 3-2: _Vagrantfile_

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "consul-up/vm"

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 8500, host: 8500
  config.vm.network "forwarded_port", guest: 6060, host: 6060
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 9090, host: 9090
  config.vm.network "forwarded_port", guest: 16686, host: 16686
end
```

### Figure 3-3: _server.hcl_

```hcl
# connect
# This stanza configures connect, the name
# for the service mesh features of Consul.
connect {
  enabled = true
}

# ports
# Configures which ports Consul listens on.
# You need to configure its gRPC port to listen on 8502
# because this is required for the service mesh functionality.
ports {
  grpc = 8502
}

# server
# Configures this agent to run as a server (as opposed to a client).
server = true

# bootstrap_expect
# Sets the number of servers expected to be in this cluster.
# Since you only have one server, this is set to 1.
# The servers will wait until this many servers
# have joined the cluster before they start up.
bootstrap_expect = 1

# ui_config
# Configures Consul's UI.
# Set enabled to true to enable the UI.
ui_config {
  enabled = true
}

# client_addr
# The address Consul binds to for its HTTP API.
# The UI is exposed over the HTTP API so to access
# the UI from outside the VM, set this to 0.0.0.0 so it
# binds to all interfaces.
client_addr = "0.0.0.0"

# bind_addr
# The address Consul binds to for internal cluster
# communication. Usually this should be set to
# 0.0.0.0 but in Vagrant, setting this to 127.0.0.1
# prevents issues if the IP changes.
bind_addr = "127.0.0.1"
```

## Commands

```bash
kubectl version --client
```

```bash
export DOMAIN="https://storage.googleapis.com"
curl -LO \
  "$DOMAIN/minikube/releases/v1.25.2/minikube-darwin-amd64"
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
rm minikube-darwin-amd64
```

```bash
export DOMAIN="https://storage.googleapis.com"
curl -LO \
  "$DOMAIN/minikube/releases/v1.25.2/minikube-darwin-arm64"
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
rm minikube-darwin-arm64
```