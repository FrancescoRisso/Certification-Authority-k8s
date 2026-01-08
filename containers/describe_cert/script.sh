#!/bin/sh

cd /certificate/


IS_FIRST_PRINT=true


print_title () {
	local title=$1

	if [ "$IS_FIRST_TITLE" = false ]; then
		echo " "
		IS_FIRST_PRINT=false
	fi;

	echo "$title"
	echo " "
}

print_footer() {
	echo " "
	echo "-----------------------------------------------------------------------------------------"
}


if [[ -z "${CERT_ID}" ]]; then
	echo "ABORTING: no certificate ID provided (env variable CERT_ID)"
	exit 1
fi

if [ ! -d "${CERT_ID}" ]; then
	echo "ABORTING: no certificate has ID ${CERT_ID}"
	exit 1
fi

cd ${CERT_ID}

if [[ ! -z "${PRIV_KEY}" ]]; then
	print_title "Private key:"
	cat key.key
	print_footer
fi

if [[ ! -z "${CERT}" ]]; then
	print_title "Certificate:"
	cat certificate.crt
	print_footer
fi

if [[ ! -z "${CERT_DESCR}" ]]; then
	print_title "Description used to create the certificate:"
	cat description.ext
	print_footer
fi
