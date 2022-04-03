Kind = "service-intentions"
Name = "frontend"
Sources = [
  {
    Name = "ingress-gateway"
    Permissions = [
      {
        HTTP {
          PathPrefix = "/admin"
        }
        Action = "deny"
      },
      {
        HTTP {
          PathPrefix = "/"
        }
        Action = "allow"
      }
    ]
  }
]
