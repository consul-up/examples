## Chapter 8

### Example 8-1: _backend-deployment.yaml_

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
      annotations:
        consul.hashicorp.com/connect-inject: "true"
        consul.hashicorp.com/service-meta-version: "v1"
    spec:
      containers:
        - name: backend
          image: ghcr.io/consul-up/birdwatcher-backend:1.0.0
          env:
            - name: BIND_ADDR
              value: "0.0.0.0:7000"
            - name: TRACING_URL
              value: "http://jaeger-collector.default:9411"
          ports:
            - containerPort: 7000
          readinessProbe:
            httpGet:
              port: 9999
              path: /healthz
            periodSeconds: 5
```

### Example 8-2: _backend.hcl_

```hcl
service {
  name = "backend"
  port = 7000

  meta {
    version         = "v1"
    prometheus_port = "20201"
  }

  connect {
    sidecar_service {
      port = 22000
      proxy {
        config {
          envoy_prometheus_bind_addr = "0.0.0.0:20201"
        }
      }
    }
  }

  checks = [
    {
      name     = "Health endpoint"
      http     = "http://localhost:9999/healthz"
      interval = "10s"
      timeout  = "1s"
    }
  ]
}
```

### Example 8-3: _backend-service-router.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceRouter
metadata:
  name: backend
spec:
  routes:
    - destination:
        numRetries: 5
        retryOnStatusCodes: [503]
```

### Example 8-4: _backend-service-router.hcl_

```hcl
Kind = "service-router"
Name = "backend"
Routes = [
  {
    Destination = {
      NumRetries = 5
      RetryOnStatusCodes = [503]
    }
  }
]
```

### Example 8-5: _backend-service-router.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceRouter
metadata:
  name: backend
spec:
  routes:
    - destination:
        requestTimeout: "1s"
```

### Example 8-6: _backend-service-router.hcl_

```hcl
Kind   = "service-router"
Name   = "backend"
Routes = [
  {
    Destination = {
      RequestTimeout = "1s"
    }
  }
]
```
