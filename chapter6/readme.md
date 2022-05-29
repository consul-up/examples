## Chapter 6

### Example 6-1: _deny-all-service-intentions.yaml_

```yaml
# deny-all-service-intentions.yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceIntentions
metadata:
  name: deny-all
  namespace: consul
spec:
  destination:
    name: "*"
  sources:
    - name: "*"
      action: deny
```

### Example 6-2: _frontend-service-intentions.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceIntentions
metadata:
  name: frontend
spec:
  destination:
    name: frontend
  sources:
    - name: ingress-gateway
      action: allow
```

### Example 6-3: _backend-service-intentions.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceIntentions
metadata:
  name: backend
spec:
  destination:
    name: backend
  sources:
    - name: frontend
      action: allow
```

### Example 6-4: _deny-all-service-intentions.hcl_

```hcl
Kind    = "service-intentions"
Name    = "*"
Sources = [
  {
    Name   = "*"
    Action = "deny"
  }
]
```

### Example 6-5: _frontend-service-intentions.hcl_

```hcl
Kind    = "service-intentions"
Name    = "frontend"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  }
]
```

### Example 6-6: _backend-service-intentions.hcl_

```hcl
Kind    = "service-intentions"
Name    = "backend"
Sources = [
  {
    Name   = "frontend"
    Action = "allow"
  }
]
```

### Example 6-7: _frontend-service-intentions.yaml_

```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceIntentions
metadata:
  name: frontend
spec:
  destination:
    name: frontend
  sources:
    - name: ingress-gateway
      permissions:
        - http:
            pathPrefix: /admin
          action: deny
        - http:
            pathPrefix: /
          action: allow
```

### Example 6-8: _frontend-service-intentions.hcl_

```hcl
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
```
