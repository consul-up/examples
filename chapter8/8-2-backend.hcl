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
