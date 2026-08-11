#!/bin/bash
set -euo pipefail

CERT_DIR=/app/certs
mkdir -p "$CERT_DIR"

# If user provided server.crt/server.key, copy to cert.pem/key.pem used by server.py
if [ -f "$CERT_DIR/server.crt" ] && [ -f "$CERT_DIR/server.key" ]; then
  echo "Found server.crt/server.key — copying to cert.pem/key.pem"
  cp "$CERT_DIR/server.crt" "$CERT_DIR/cert.pem"
  cp "$CERT_DIR/server.key" "$CERT_DIR/key.pem"
fi

# If cert.pem/key.pem already exist, use them
if [ -f "$CERT_DIR/cert.pem" ] && [ -f "$CERT_DIR/key.pem" ]; then
  echo "Using provided cert.pem and key.pem"
else
  echo "No cert found — generating self-signed certificate"
  # Prepare openssl config if missing
  if [ ! -f "$CERT_DIR/openssl.cnf" ]; then
    cat > "$CERT_DIR/openssl.cnf" <<EOF
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
IP.2 = ${HOST_IP:-127.0.0.1}
EOF
  fi

  DAYS_VAL=${DAYS:-7}
  openssl req -x509 -nodes -newkey rsa:2048 -days "$DAYS_VAL" \
    -keyout "$CERT_DIR/key.pem" -out "$CERT_DIR/cert.pem" \
    -config "$CERT_DIR/openssl.cnf" -extensions v3_req -subj "/CN=localhost"
  echo "Generated self-signed cert: $CERT_DIR/cert.pem (valid $DAYS_VAL days)"
fi

exec "$@"
