## Chapter 9

### Example 9-1: _backend-service-resolver.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceResolver
metadata:
  name: backend
spec:
  subsets:
    v1:
      filter: 'Service.Meta.version == v1'
    v2:
      filter: 'Service.Meta.version == v2'
```

### Example 9-2: _backend-service-resolver.hcl_

```hcl
Kind          = "service-resolver"
Name          = "backend"
Subsets = {
  v1 = {
    Filter = "Service.Meta.version == v1"
  }
  v2 = {
    Filter = "Service.Meta.version == v2"
  }
}
```

### Example 9-3: _backend-service-splitter.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceSplitter
metadata:
  name: backend
spec:
  splits:
    - weight: 100
      serviceSubset: v1
    - weight: 0
      serviceSubset: v2
```

### Example 9-4: _backend-service-splitter.hcl_

```hcl
Kind = "service-splitter"
Name = "backend"
Splits = [
  {
    Weight        = 100
    ServiceSubset = "v1"
  },
  {
    Weight        = 0
    ServiceSubset = "v2"
  }
]
```

### Example 9-5: _backend-v2-deployment.yaml_

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-v2
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v2
  template:
    metadata:
      labels:
        app: backend
        version: v2
      annotations:
        consul.hashicorp.com/connect-inject: "true"
        consul.hashicorp.com/service-meta-version: "v2"
    spec:
      containers:
        - name: backend
          image: ghcr.io/consul-up/birdwatcher-backend:1.0.0
          env:
            - name: BIND_ADDR
              value: "0.0.0.0:7000"
            - name: TRACING_URL
              value: "http://jaeger-collector.default:9411"
            - name: VERSION
              value: "v2"
          ports:
            - containerPort: 7000
          readinessProbe:
            httpGet:
              port: 7000
              path: /healthz
            periodSeconds: 5
```

### Example 9-6: _backend-v2.hcl_

```hcl
service {
  name = "backend"
  id = "backend-v2"
  port = 7001

  meta {
    version = "v2"
    prometheus_port = "20203"
  }

  connect {
    sidecar_service {
      port = 22001
      proxy {
        config {
          envoy_prometheus_bind_addr = "0.0.0.0:20203"
        }
      }
    }
  }

  checks = [
    {
      name = "Health endpoint"
      http = "http://localhost:7001/healthz"
      interval = "10s"
      timeout = "1s"
    }
  ]
}
```

### Example 9-7: _backend-v2.service_

```ini
[Unit]
Description="Backend service v2"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/backend
Restart=on-failure

Environment=BIND_ADDR=0.0.0.0:7001
Environment=TRACING_URL="http://localhost:9411"
Environment=VERSION=v2

[Install]
WantedBy=multi-user.target
```

### Example 9-8: _backend-v2-sidecar-proxy.service_

```ini
[Unit]
Description="Backend v2 sidecar proxy service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for backend-v2 \
  -admin-bind 127.0.0.1:19003
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Example 9-9: _backend-service-router.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceRouter
metadata:
  name: backend
spec:
  routes:
    - match:
        http:
          queryParam:
              - name: canary
                exact: "true"
      destination:
        serviceSubset: v2
```

### Example 9-10: _backend-service-router.hcl_

```hcl
Kind   = "service-router"
Name   = "backend"
Routes = [
  {
    Match = {
      HTTP = {
        QueryParam = [
          {
            Name = "canary"
            Exact = "true"
          }
        ]
      }
    }
    Destination = {
      ServiceSubset = "v2"
    }
  }
]
```
