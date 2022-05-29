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
