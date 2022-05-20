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
