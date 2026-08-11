#!/bin/bash
set -euo pipefail

# Usage: ./create_ca.sh [CA_NAME] [DAYS]
# Defaults: CA_NAME=ca, DAYS=3650

CA_NAME=${1:-ca}
DAYS=${2:-3650}

mkdir -p certs

echo "Creating CA: ${CA_NAME} (valid ${DAYS} days) -> certs/${CA_NAME}.key, certs/${CA_NAME}.crt"

openssl genrsa -out "certs/${CA_NAME}.key" 4096
openssl req -x509 -new -nodes -key "certs/${CA_NAME}.key" -sha256 -days "${DAYS}" -out "certs/${CA_NAME}.crt" -subj "/CN=${CA_NAME}"

echo "Created CA key and cert."
