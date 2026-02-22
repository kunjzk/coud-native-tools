# Podman

### Architecturally

podman CLI -> libpod (in-process engine) -> conmon -> runc/crun -> kernel

## Benefits

### 1. Security

Docker

- daemon runs as root
- socket gives root-equivalent control
- anyone in `docker` group can: mount host filesystems, start privelged containers, escape via bind mounts, access host devices
- mounting docker socket into containers is dangerous
  Q: what actions constitute root-equivalent control?
  Q: who is in the docker group?

Podman

- rootless containers by default
- no root daemon/socket, each user manages their own containers
  Q: so with docker, who manages the containers? daemon/root? what does "manage" mean? root is the user runing the container process? why is that bad?

### 2. Ships with Linux distros

RHEL, Fedora, CentOS ship Podman by default. Docker is a third-party install. This matters in enterprise environments where companies
want vendor tooling that is natively supported by the platform, integrated with SELinux, part of the redhat ecosystem.

### 3. Systemd integration

Using `podman generate systemd` to generate a unit file,

- containers treated like system services
- restart on boot (post patching), systemctl manages them
  -- easier to run applications on Linux servers

Docker requires custom systemd wrapping or restart policies.

### 4. Pod support

With `podman pod create`, containers in a pod share network and IPC namespace (Q: what is IPC?)
Useful because podman pods help you simulate k8s locally.

### 5. Simpler product

Linux-native container engine vs developer UX platform. No need for docker desktop licensing with podman.

# Podman socket

Can be exposed when needed -- exists so that tools expecting Docker can talk to Podman. Exposes both a rootless and rootful socket.
`podman system service` exists to start a rest API service that listens for traffic over the socket.

### Other things to clarify

- ghostunnel
