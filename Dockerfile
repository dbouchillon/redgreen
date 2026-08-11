FROM python:3.11-slim

ARG HOST_IP=127.0.0.1
ARG DAYS=7
WORKDIR /app

# Copy app files
COPY server.py config.json /app/

# Install openssl and generate a self-signed cert including optional HOST_IP as an IP SAN
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && mkdir -p /app/certs \
    && cat > /app/certs/openssl.cnf <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = v3_req

[ dn ]
CN = localhost

[ v3_req ]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ alt_names ]
DNS.1 = localhost
DNS.2 = localhost.localdomain
IP.1 = 127.0.0.1
IP.2 = ${HOST_IP}
EOF

# Do not generate cert at build time so users may mount their own signed certs at runtime.
# The entrypoint will generate a self-signed cert if none are provided.

RUN mkdir -p /app/certs

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8443

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["python3", "server.py"]
