## Chapter 5

### Example 5-1: _values.yaml_

```yaml
global:
  name: consul
  metrics:
    enabled: true
  image: hashicorp/consul:1.11.5
  imageEnvoy: envoyproxy/envoy:v1.20.2

server:
  replicas: 1

connectInject:
  enabled: true

controller:
  enabled: true

prometheus:
  enabled: true

ui:
  service:
    type: LoadBalancer
    port:
      http: 8500

ingressGateways:
  enabled: true
  defaults:
    affinity: null
  gateways:
    - name: ingress-gateway
      service:
        type: LoadBalancer
        ports:
          - port: 8080
      replicas: 1
```

### Example 5-2: _ingress-gateway.hcl_

```hcl
service {
  name   = "ingress-gateway"
  kind   = "ingress-gateway"
  port   = 20000
  checks = [
    {
      name     = "ingress-gateway listening"
      tcp      = "localhost:20000"
      interval = "10s"
    }
  ]
}
```

### Example 5-3: _ingress-gateway.service_

```ini
[Unit]
Description="Consul ingress gateway"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul connect envoy \
    -gateway=ingress \
    -service ingress-gateway \
    -admin-bind 127.0.0.1:19002 \
    -address 127.0.0.1:20000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Example 5-4: _ingress-gateway.yaml_

```yaml
# ingress-gateway.yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: IngressGateway
metadata:
  name: my-gateway
spec:
  listeners: []
```

### Example 5-5: _ingress-gateway.hcl_

```hcl
# ingress-gateway.hcl
Kind = "ingress-gateway"
Name = "my-gateway"
Listeners = []
```

### Example 5-6: _ingress-gateway.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: IngressGateway
metadata:
  name: ingress-gateway
  namespace: consul
spec:
  listeners:
    - port: 8080
      protocol: http
      services:
        - name: frontend
          hosts: ["localhost"]
```

### Example 5-7: _proxy-defaults.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ProxyDefaults
metadata:
  name: global
  namespace: consul
spec:
  config:
    protocol: http
```

### Example 5-8: _ingress-gateway.hcl_

```hcl
Kind = "ingress-gateway"
Name = "ingress-gateway"
Listeners = [
  {
    Port = 8080
    Protocol = "http"
    Services = [
      {
        Name = "frontend"
        Hosts = ["localhost"]
      }
    ]
  }
]
```

### Example 5-9: _proxy-defaults.hcl_

```hcl
Kind = "proxy-defaults"
Name = "global"
Config {
  protocol = "http"
}
```
