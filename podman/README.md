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

Podman

- rootless containers by default
- no root daemon/socket, each user manages their own containers

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

# A level deeper

### What does root-equivalent control mean and look like?

Perform arbitrary privileged operations.
A user with docker socket access can run

```
docker run -v /:/host -it ubuntu chroot /host # mount the entire host "/" into the container, chroot into it and now control the host filesystem -- root on the machine
docker run --privileged -it ubuntu bash # grant access to all devices, disable namespace restrictions, modify kernel params
-v /var/run/docker.sock:/var/run/docker.sock # the container can now start new containers, mount the host, etc
docker run --device /dev/sda # read/write raw disk now
```

### What does it mean to have docker socket access?

1. dockerd is running -- `ps aux | grep dockerd`
2. docker socket exists -- `ls -l /var/run/docker.sock`
3. user in docker group -- `group`: if you see `username docker`

Then they can run priveleged commands. If they're not in the `docker` group, they'll get permission denied.

### Who is in the docker group?

Docker upon installation creates a Unix group called `docker`. Members can access docker socket and run docker commands without sudo.
Members can be added using `sudo usermod -aG docker $USER` --> usually add the user who installed docker, devs who need container access, CI users.

# A level deeper - why can Podman avoid a daemon?
