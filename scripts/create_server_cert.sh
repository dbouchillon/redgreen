#!/bin/bash
set -euo pipefail

# Usage:
# ./create_server_cert.sh <CN> <DAYS> <DNS_CSV> <IP_CSV> [CA_KEY] [CA_CERT] [OUT_PREFIX]
# Example:
# ./create_server_cert.sh localhost 825 "localhost,example.com" "127.0.0.1,192.168.0.238"

CN=${1:-localhost}
DAYS=${2:-825}
DNS_CSV=${3:-localhost}
IP_CSV=${4:-127.0.0.1}
CA_KEY=${5:-certs/ca.key}
CA_CERT=${6:-certs/ca.crt}
OUT_PREFIX=${7:-certs/server}

mkdir -p certs

CONF_FILE="certs/${CN}_openssl.cnf"

cat > "${CONF_FILE}" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = v3_req

[ dn ]
CN = ${CN}

[ v3_req ]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ alt_names ]
EOF

# append DNS entries
i=1
IFS=',' read -r -a dns_array <<< "$DNS_CSV"
for d in "${dns_array[@]}"; do
  echo "DNS.$i = $d" >> "${CONF_FILE}"
  i=$((i+1))
done

# append IP entries
i=1
IFS=',' read -r -a ip_array <<< "$IP_CSV"
for ip in "${ip_array[@]}"; do
  echo "IP.$i = $ip" >> "${CONF_FILE}"
  i=$((i+1))
done

echo "Using OpenSSL config: ${CONF_FILE}"

echo "Generating server key: ${OUT_PREFIX}.key"
openssl genrsa -out "${OUT_PREFIX}.key" 2048

echo "Creating CSR"
openssl req -new -key "${OUT_PREFIX}.key" -out "${OUT_PREFIX}.csr" -config "${CONF_FILE}" -subj "/CN=${CN}"

echo "Signing CSR with CA (${CA_CERT}) -> ${OUT_PREFIX}.crt"
openssl x509 -req -in "${OUT_PREFIX}.csr" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${OUT_PREFIX}.crt" -days "${DAYS}" -sha256 -extfile "${CONF_FILE}" -extensions v3_req

echo "Server certificate created: ${OUT_PREFIX}.crt"
