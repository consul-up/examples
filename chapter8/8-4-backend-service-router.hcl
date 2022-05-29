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
