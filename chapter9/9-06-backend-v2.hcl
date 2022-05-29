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
