#!/bin/sh

ls -la /

cd /certificate/

if [ -f ./CA_name.txt ]; then
	if [[ -z "${CA_OVERRIDE_IF_EXISTS}" ]]; then
		echo "ABORTING: attempting to override an existing CA"
		exit 1
	else
		echo "WARNING: overriding previous CA"
	fi
fi

if [[ -z "${CA_NAME}" ]]; then
	echo "ABORTING: no CA name (env variable CA_NAME)"
	exit 1
fi

if [[ -z "${CA_PASSWORD}" ]]; then
	echo "ABORTING: no CA main password (env variable CA_PASSWORD)"
	exit 1
fi

if [[ -z "${CERT_DURATION}" ]]; then
	echo "ABORTING: no expiration time for the root certificate (env variable CERT_DURATION)"
	exit 1
fi

country=${CA_COUNTRY:-}
state_province=${CA_STATE_PROVINCE:-}
locality=${CA_LOCALITY:-}
org=${CA_ORG:-}
unit=${CA_ORG_UNIT:-}
name=${CA_NAME}

echo $name > ./CA_name.txt

openssl \
	req -x509 \
	-newkey \
	rsa:4096 \
	-keyout key.pem \
	-out cert.pem \
	-sha256 \
	-days ${CERT_DURATION} \
	-passout pass:${CA_PASSWORD} \
	-subj "/C=${country}/ST=${state_province}/L=${locality}/O=${org}/OU=${unit}CN=${name}/"

echo "Certification authority created"
