# redgreen (Docker)

Build and run the HTTPS server in Docker. The image no longer bakes a certificate at build time — the container's entrypoint will:

- use mounted certs if you bind `certs/` into `/app/certs` (it looks for `cert.pem`+`key.pem` or `server.crt`+`server.key`),
- otherwise generate a self-signed cert at container start using `HOST_IP` and `DAYS` environment variables.

Build the image (you can still provide a default HOST_IP/DAYS build-arg if you like, but certs are generated at runtime):

```bash
docker build -t redgreen .
```

Run with your own signed certs (mount local `certs/` produced by the scripts):

```bash
docker run -d --name redgreen -p 8443:8443 -v "$PWD/certs":/app/certs redgreen
```

Let the container generate a self-signed cert at startup (set `HOST_IP` and `DAYS`):

```bash
docker run -d --name redgreen -p 8443:8443 -e HOST_IP=192.168.0.238 -e DAYS=2 redgreen
```

Quick test (ignore cert verification):

```bash
curl -k https://localhost:8443/red
curl -k https://192.168.0.238:8443/green
```

Generate a private CA and a server cert locally (the repo includes scripts):

```bash
bash scripts/create_ca.sh ca 3650
bash scripts/create_server_cert.sh localhost 2 "localhost" "127.0.0.1,192.168.0.238" certs/ca.key certs/ca.crt certs/server
# This produces certs/server.crt and certs/server.key — mount the whole certs/ directory into the container as shown above.
```

Run the server locally (non-Docker) with custom cert paths:

```bash
CERT_FILE=certs/server.crt KEY_FILE=certs/server.key PORT=8443 python3 server.py
```

