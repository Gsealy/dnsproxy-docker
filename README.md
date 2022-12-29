## Docker build

```shell

docker buildx build --platform linux/amd64 --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')  --build-arg TARGETPLATFORM=linux/amd64 -t "gsealy/dnsproxy:0.0.1" -f Dockerfile .
```

## Using docker compose

### Edit `docker-compose.yml`

```yaml
services:
  dnsproxy:
    container_name: dnsproxy
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    image: gsealy/dnsproxy:0.0.1
    privileged: true
    restart: unless-stopped
    network_mode: "bridge"
    sysctls:
      - "net.ipv4.ip_forward=1"
```

```shell
docker compose up -d --force-recreate
```

## Credit

1. https://github.com/vmstan/dnsproxy/blob/main/Dockerfile
2. https://github.com/AdguardTeam/dnsproxy
3. https://github.com/ookangzheng/dnsproxy-docker
