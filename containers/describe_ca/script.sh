#!/bin/sh

cd /certificate/


IS_FIRST_PRINT=true


print_title () {
	local title=$1

	if [ "$IS_FIRST_TITLE" = false ]; then
		echo ""
		IS_FIRST_PRINT=false
	fi;

	echo "$title"
	echo ""
}

print_footer() {
	echo ""
	echo "-------------------------------------------------------"
}

print_common_instructions() {
	if [[ -z "${ROOT_CERT}" ]]; then
		echo " 0. Run this container with the ROOT_CERT env enabled to get the root certificate"
	fi

	echo " 1. Copy the root certificate to a file"
	echo " 2. Save the file with .pem extension"
}


if [ ! -f ./key.pem ]; then
	echo "ABORTING: no CA to describe"
	exit 1
fi

if [[ ! -z "${ROOT_CERT}" ]]; then
	print_title "CA certificate:"
	cat cert.pem
	print_footer
fi

if [[ ! -z "${CERTIFICATES}" ]]; then
	print_title "List of certs emitted by this CA:"
	find . -maxdepth 1 -type d | tail -n +2 | sed 's@^./@@g'
	print_footer
fi

if [[ ! -z "${INSTR_ANDROID}" ]]; then
	print_title "How to install the root certificate on Android:"
	
	echo "Warning: this was only tested on Samsung devices"
	echo ""
	
	print_common_instructions

	echo " 3. Open the Settings"
	echo " 4. Navigate to Security and privacy"
	echo " 5. Navigate to More security settings"
	echo " 6. Navigate to Install from device storage, under Credential storage"
	echo " 7. Select CA certificate"
	echo " 8. Select Install anyway"
	echo " 9. Select the .pem file from the file storage, and click Done"
	echo "10. Reboot the phone"
	
	print_footer
fi

if [[ ! -z "${INSTR_W11}" ]]; then
	print_title "How to install the root certificate on Windows 11:"
	
	print_common_instructions

	echo " 3. Open the Microsoft Management Console by using Win+R and typing mmc"
	echo " 4. Go to File > Add/Remove Snap-in"
	echo " 5. Select Certificates from the left column"
	echo " 6. Click Add"
	echo " 7. Select Computer Account, then click Next"
	echo " 8. Select Local Computer, then click Finish"
	echo " 9. Click OK"
	echo "10. Double-click Certificates (local computer) in the right column"
	echo "11. Double-click Trusted Root Certification Authority"
	echo "12. Right-click on Certificates"
	echo "13. Under All Tasks select Import..."
	echo "14. Click Next, then Browse"
	echo "15. Change the file extension to the bottom-right to All Files (*.*)"
	echo "16. Select the .pem file and click Open"
	echo "17. Click Next"
	echo "18. Select Place all certificates in the following store"
	echo "19. Check that the selected option is Trusted Root Certification Authorities store"
	echo "20. Click next, then Finish"
	
	print_footer
fi

