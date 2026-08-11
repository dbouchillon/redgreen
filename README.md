# redgreen (Docker)

Build and run the HTTPS server in Docker. The image generates a self-signed certificate during build. By default the certificate expires after 7 days, but you can override this with the `DAYS` build argument. You can also pass a host IP to include as an IP SAN during build.

Build (include host IP as SAN and override expiry):

```bash
# use HOST_IP to add an IP SAN and DAYS to set expiry days (default: 7)
docker build --build-arg HOST_IP=192.168.0.238 --build-arg DAYS=2 -t redgreen .
```

Run:

```bash
docker run -p 8443:8443 redgreen
```

Quick test (ignore cert verification):

```bash
curl -k https://localhost:8443/red
curl -k https://192.168.0.238:8443/green
```
