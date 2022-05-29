## Chapter 7

### Example 7-1: _prometheus.yml_

```yaml
global:
  scrape_interval: 10s

scrape_configs:
- job_name: consul
  metrics_path: /metrics
  consul_sd_configs:
  - server: 'localhost:8500'
  relabel_configs:
  - source_labels:
    - __meta_consul_tagged_address_lan
    - __meta_consul_service_metadata_prometheus_port
    regex: '(.*);(.*)'
    replacement: '${1}:${2}'
    target_label: '__address__'
    action: 'replace'
```

### Example 7-2: _frontend.hcl_

```hcl
service {
  name = "frontend"
  port = 6060

  meta {
    prometheus_port = "20200"
  }

  connect {
    sidecar_service {
      port = 21000
      proxy {
        upstreams = [
          {
            destination_name = "backend"
            local_bind_port  = 6001
          }
        ]
        config {
          envoy_prometheus_bind_addr = "0.0.0.0:20200"
        }
      }
    }
  }
}
```

### Example 7-3: _backend.hcl_

```hcl
service {
  name = "backend"
  port = 7000

  meta {
    version = "v1"
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
}
```

### Example 7-4: _ingress-gateway.hcl_

```hcl
service {
  name   = "ingress-gateway"
  kind   = "ingress-gateway"
  port   = 20000

  meta {
    prometheus_port = "20202"
  }

  checks = [
    {
      name     = "ingress-gateway listening"
      tcp      = "localhost:20000"
      interval = "30s"
    }
  ]
  proxy {
    config {
      envoy_prometheus_bind_addr = "0.0.0.0:20202"
    }
  }
}
```

### Example 7-5: _rps.promql_

```promql
sum(
  rate(
    envoy_http_downstream_rq_completed{
      consul_source_service="frontend",
      envoy_http_conn_manager_prefix="public_listener"
    }[$__rate_interval]
  )
)
```

### Example 7-6: _error-percentage.promql_

```promql
sum(
  rate(
    envoy_http_downstream_rq_xx{
      consul_source_service="$Service",
      envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080",
      envoy_response_code_class="5"
    }[$__rate_interval]
  )
) /
sum(
  rate(
    envoy_http_downstream_rq_completed{
      consul_source_service="$Service",
      envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
    }[$__rate_interval]
  )
)
```

### Example 7-7: _latency-50.promql_

```promql
histogram_quantile(
  0.5,
  sum(
    rate(
      envoy_http_downstream_rq_time_bucket{
        consul_source_service="$Service",
        envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
      }[$__rate_interval]
    )
  ) by (le)
)
```

### Example 7-8: _latency-99.promql_

```promql
histogram_quantile(
  0.99,
  sum(
    rate(
      envoy_http_downstream_rq_time_bucket{
        consul_source_service="$Service",
        envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
      }[$__rate_interval]
    )
  ) by (le)
)
```

### Example 7-9: _jaeger.yaml_

```yaml
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
spec:
  query:
    serviceType: LoadBalancer
  ingress:
    enabled: false
```

### Example 7-10: _frontend-deployment.yaml_

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
        consul.hashicorp.com/connect-inject: "true"
    spec:
      containers:
        - name: frontend
          image: ghcr.io/consul-up/birdwatcher-frontend:1.0.0
          env:
            - name: BIND_ADDR
              value: "0.0.0.0:6060"
            - name: BACKEND_URL
              value: "http://backend"
            - name: TRACING_URL
              value: "http://jaeger-collector.default:9411"
          ports:
            - containerPort: 6060
```

### Example 7-11: _backend-deployment.yaml_

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
```

### Example 7-12: _frontend.service_

```ini
[Unit]
Description="Frontend service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/frontend
Restart=on-failure
Environment=BIND_ADDR=127.0.0.1:6060
Environment=BACKEND_URL=http://localhost:6001
Environment=TRACING_URL="http://localhost:9411"

[Install]
WantedBy=multi-user.target
```

### Example 7-13: _backend.service_

```ini
[Unit]
Description="Backend service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/backend
Restart=on-failure
Environment=BIND_ADDR=0.0.0.0:7000
Environment=TRACING_URL="http://localhost:9411"

[Install]
WantedBy=multi-user.target
```

### Example 7-14: _proxy-defaults.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ProxyDefaults
metadata:
  name: global
  namespace: consul
spec:
  config:
    protocol: http
    envoy_tracing_json: |
      {
        "http":{
          "name":"envoy.tracers.zipkin",
          "typedConfig":{
            "@type":"type.googleapis.com/envoy.config.trace.v3.ZipkinConfig",
            "collector_cluster":"jaeger_collector",
            "collector_endpoint_version":"HTTP_JSON",
            "collector_endpoint":"/api/v2/spans",
            "shared_span_context":false
          }
        }
      }
    envoy_extra_static_clusters_json: |
      {
        "connect_timeout":"3.000s",
        "dns_lookup_family":"V4_ONLY",
        "lb_policy":"ROUND_ROBIN",
        "load_assignment":{
          "cluster_name":"jaeger_collector",
          "endpoints":[
            {
              "lb_endpoints":[
                {
                  "endpoint":{
                    "address":{
                      "socket_address":{
                        "address":"jaeger-collector.default",
                        "port_value":9411,
                        "protocol":"TCP"
                      }
                    }
                  }
                }
              ]
            }
          ]
        },
        "name":"jaeger_collector",
        "type":"STRICT_DNS"
      }
```

### Example 7-15: _proxy-defaults.hcl_

```hcl
Kind = "proxy-defaults"
Name = "global"
Config {
  protocol           = "http"
  envoy_tracing_json = <<EOF
{
  "http":{
    "name":"envoy.tracers.zipkin",
    "typedConfig":{
      "@type":"type.googleapis.com/envoy.config.trace.v3.ZipkinConfig",
      "collector_cluster":"jaeger_collector",
      "collector_endpoint_version":"HTTP_JSON",
      "collector_endpoint":"/api/v2/spans",
      "shared_span_context":false
    }
  }
}
EOF

  envoy_extra_static_clusters_json = <<EOF
{
  "connect_timeout":"3.000s",
  "dns_lookup_family":"V4_ONLY",
  "lb_policy":"ROUND_ROBIN",
  "load_assignment":{
    "cluster_name":"jaeger_collector",
    "endpoints":[
      {
        "lb_endpoints":[
          {
            "endpoint":{
              "address":{
                "socket_address":{
                  "address":"localhost",
                  "port_value":9411,
                  "protocol":"TCP"
                }
              }
            }
          }
        ]
      }
    ]
  },
  "name":"jaeger_collector",
  "type":"STRICT_DNS"
}
EOF
}
```
