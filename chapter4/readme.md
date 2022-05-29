## Chapter 4

### Example 4-1: _frontend-deployment.yaml_

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
      annotations:
    spec:
      containers:
        - name: frontend
          image: ghcr.io/consul-up/birdwatcher-frontend:1.0.0
          env:
            - name: BIND_ADDR
              value: "0.0.0.0:6060"
            - name: BACKEND_URL
              value: "http://backend"
          ports:
            - containerPort: 6060
```

### Example 4-2: _frontend-service.yaml_

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 6060
      targetPort: 6060
```

### Example 4-3: _backend-deployment.yaml_

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
    spec:
      containers:
        - name: backend
          image: ghcr.io/consul-up/birdwatcher-backend:1.0.0
          env:
            - name: BIND_ADDR
              value: "0.0.0.0:7000"
          ports:
            - containerPort: 7000
```

### Example 4-4: _backend-service.yaml_

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 7000
```

### Example 4-5: _frontend.service_

```ini
[Unit]
Description="Frontend service"

# The service requires the VM's network
# to be configured, e.g., an IP address has been assigned.
Requires=network-online.target
After=network-online.target

[Service]
# ExecStart is the command to run.
ExecStart=/usr/local/bin/frontend

# Restart configures the restart policy. In this case, we
# want to restart the service if it fails.
Restart=on-failure

# Environment sets environment variables.
# We will set the frontend service to listen
# on port 6060.
Environment=BIND_ADDR=0.0.0.0:6060

# We set BACKEND_URL to http://localhost:7000 because
# that's the port we'll run our backend service on.
Environment=BACKEND_URL=http://localhost:7000

# The Install section configures this service to start
# automatically if the VM reboots.
[Install]
WantedBy=multi-user.target
```

### Example 4-6: _backend.service_

```ini
[Unit]
Description="Backend service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/backend
Restart=on-failure

# We will set the backend service to listen
# on port 7000.
Environment=BIND_ADDR=0.0.0.0:7000

[Install]
WantedBy=multi-user.target
```

### Example 4-7: _frontend.hcl_

```hcl
service {
  name = "frontend"

  # frontend runs on port 6060.
  port = 6060

  # The "connect" stanza configures service mesh
  # features.
  connect {
    sidecar_service {
      # frontend's proxy will listen on port 21000.
      port = 21000

      proxy {
        # The "upstreams" stanza configures
        # which ports the sidecar proxy will expose
        # and what services they'll route to.
        upstreams = [
          {
            # Here you're configuring the sidecar proxy to
            # proxy port 6001 to the backend service.
            destination_name = "backend"
            local_bind_port  = 6001
          }
        ]
      }
    }
  }
}
```

### Example 4-8: _backend.hcl_

```hcl
service {
  name = "backend"
  # backend runs on port 7000.
  port = 7000

  meta {
    version = "v1"
  }

  # The backend service doesn't call
  # any other services so it doesn't
  # need an "upstreams" stanza.
  #
  # The connect stanza is still required to
  # indicate that it needs a sidecar proxy.
  connect {
    sidecar_service {
      # backend's proxy will listen on port 22000.
      port = 22000
    }
  }
}
```

### Example 4-9: _frontend-sidecar-proxy.service_

```ini
[Unit]
Description="Frontend sidecar proxy service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for frontend \
  -admin-bind 127.0.0.1:19000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Example 4-10: _backend-sidecar-proxy.service_

```ini
[Unit]
Description="Backend sidecar proxy service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for backend \
  -admin-bind 127.0.0.1:19001
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
