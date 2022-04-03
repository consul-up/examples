# connect
# This stanza configures connect, the name
# for the service mesh features of Consul.
connect {
  enabled = true
}

# ports
# Configures which ports Consul listens on.
# You need to configure its gRPC port to listen on 8502
# because this is required for the service mesh functionality.
ports {
  grpc = 8502
}

# server
# Configures this agent to run as a server (as opposed to a client).
server = true

# bootstrap_expect
# Sets the number of servers expected to be in this cluster.
# Since you only have one server, this is set to 1.
# The servers will wait until this many servers
# have joined the cluster before they start up.
bootstrap_expect = 1

# ui_config
# Configures Consul's UI.
# Set enabled to true to enable the UI.
ui_config {
  enabled = true
}

# client_addr
# The address Consul binds to for its HTTP API.
# The UI is exposed over the HTTP API so to access
# the UI from outside the VM, set this to 0.0.0.0 so it
# binds to all interfaces.
client_addr = "0.0.0.0"

# bind_addr
# The address Consul binds to for internal cluster
# communication. Usually this should be set to
# 0.0.0.0 but in Vagrant, setting this to 127.0.0.1
# prevents issues if the IP changes.
bind_addr = "127.0.0.1"
