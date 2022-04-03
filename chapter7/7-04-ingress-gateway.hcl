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
