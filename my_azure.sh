#!/bin/bash
clear
echo "#####################################################################################
      my_azure.sh by Robert Sherwin (robsherw@cisco.com)  ©2019 Cisco .:|:.:|:.
Using openssl, this script will create a self-signed certificate for you to use in
order to complete the Mailbox Settings configuration for Cisco Email Security.
Please respond to the following prompts:
#####################################################################################
"
if which openssl >/dev/null; then
    echo "openssl check passed: openssl is installed!" & openssl version
else
    echo "You do not appear to have openssl installed." && exit
fi

echo "
Please enter a name for your certificate: "
read my_cert

while [ -f $my_cert.key ];
do
	echo "File exists, please enter a name for your certificate: " && read my_cert
done

echo "
Thank you.  The files that will be generated for your certificate are: "

crt=$my_cert.crt
key=$my_cert.key
pem=$my_cert.pem
txt=$my_cert.txt

echo $crt "---> CER file of your certificate (public key)"
echo $pem "---> PEM file of your certificate (private key)"
echo $key "---> Your self-signed RSA private .key output"
echo $txt "---> TXT file containing a recording of the needed values created from this script"
echo ""

while true; do
    read -p "Are you ready to proceed and generate these files for your configuration? (y/n) " yn
    case "$yn" in
        [Yy]* ) openssl req -x509 -sha256 -nodes -days 1825 -newkey rsa:2048 -keyout $key -out $crt
openssl rsa -in $key -out $key
cat $key $crt > $pem

echo ""
base64Thumbprint=`openssl x509 -outform der -in $crt | openssl dgst -binary -sha1 | openssl base64`
base64Value=`openssl x509 -outform der -in $crt | openssl base64 -A`
keyid=`python -c "import uuid; print(uuid.uuid4())"`
echo "
################################################################################
Next, log-in to Microsoft Azure and use the following for your App registration:
################################################################################

Complete the Azure App registration (Certificate & secrets) using this certificate (public key): $crt"| tee -a $txt
echo "Complete the Azure App registration (API permissions)
View & save your Client ID and Tenant ID$

########################################################
After successful Azure App registration, from Cisco ESA:
########################################################

Use the Client ID and Tenant ID copied from your Azure App registration
The Thumbprint to use for your ESA configuration: $base64Thumbprint" | tee -a $txt
echo "The Certificate Private Key to use for your ESA configuration: $pem
" | tee -a $txt; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you wish to review this certificate in detail? (y/n) " yn
    case $yn in
        [Yy]* ) openssl x509 -in $crt -text; echo "
Thank you! Be sure to keep up-to-date from https://docs.ces.cisco.com" && break;;
        [Nn]* ) echo "Thank you!  Be sure to keep up-to-date from https://docs.ces.cisco.com" && exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
