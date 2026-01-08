#!/bin/sh

cd /certificate/

if [ ! -f ./key.pem ]; then
	echo "ABORTING: no CA to sing the certificate"
	exit 1
fi

if [[ -z "${CA_PASSWORD}" ]]; then
	echo "ABORTING: no CA main password (env variable CA_PASSWORD)"
	exit 1
fi

if [[ -z "${CERT_DURATION}" ]]; then
	echo "ABORTING: no expiration time for the certificate (env variable CERT_DURATION)"
	exit 1
fi

if [[ -z "${CERT_ID}" ]]; then
	echo "ABORTING: no identifier name for the certificate (env variable CERT_ID)"
	exit 1
fi

if [[ -z "${CERT_DESCRIPTION}" ]]; then
	echo "ABORTING: no description for the certificate (env variable CERT_DESCRIPTION)"
	exit 1
fi

if [ -d "${CERT_ID}" ]; then
	echo "ABORTING: a certificate with ID ${CERT_ID} already exists"
	exit 1
fi

country=${CERT_COUNTRY:-}
state_province=${CERT_STATE_PROVINCE:-}
locality=${CERT_LOCALITY:-}
org=${CERT_ORG:-}
unit=${CERT_ORG_UNIT:-}
name=${CERT_NAME:-}


# Create folder for the certificate
mkdir ${CERT_ID}
cd ${CERT_ID}


# Generate private key
openssl genrsa -out key.key 2048

# Generate certificate request
openssl \
	req \
	-new \
	-key key.key \
	-out request.csr \
	-subj "/C=${country}/ST=${state_province}/L=${locality}/O=${org}/OU=${unit}CN=${name}/"

# Save certificate description as file
echo ${CERT_DESCRIPTION} > description.ext

# Create certificate
openssl \
	x509 \
	-req \
	-in request.csr \
	-CA ../cert.pem \
	-CAkey ../jey.pem \
	-CAcreateserial \
	-out certificate.crt \
	-days ${CERT_DURATION} \
	-sha256 \
	-passout pass:${CA_PASSWORD} \
	-extfile description.ext

echo "Certificate created"
