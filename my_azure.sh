clear
bold=$(tput smso)
offbold=$(tput sgr0)
echo "#####################################################################################
      my_azure.sh by Robert Sherwin (robsherw@cisco.com)  ©2018 Cisco .:|:.:|:. 
Using openssl, this script will create a self-signed certificate for you to use in order to 
complete either the Mailbox Settings configuration for Mailbox Auto Remediation (MAR) 
for Cisco Email Security, or the certificate setup steps needed for Office 365 Threat 
Analyzer configuration.  
Please respond to the following prompts: 
#####################################################################################
"
if which openssl >/dev/null; then
    echo "openssl is installed!" & openssl version
else
    echo "You do not appear to have openssl installed." && exit
fi

echo "
Please enter a name for your cert: "
read my_cert

while [ -f $my_cert.key ];
do
	echo "File exists, please enter a name for your cert: " && read my_cert 
done

echo "
Thank you.  The files that will be generated for your cert are: "

crt=$my_cert.crt
key=$my_cert.key
pem=$my_cert.pem

echo $crt
echo $key
echo $pem
echo ""

while true; do
    read -p "Are you ready to proceed and generate these files for your configuration? $(tput smso)(y/n)$(tput sgr0) " yn
    case $yn in
        [Yy]* ) openssl req -x509 -sha256 -nodes -days 1825 -newkey rsa:2048 -keyout $key -out $crt
openssl rsa -in $key -out $key
cat $key $crt > $pem

echo ""
base64Thumbprint=`openssl x509 -outform der -in $crt | openssl dgst -binary -sha1 | openssl base64`
base64Value=`openssl x509 -outform der -in $crt | openssl base64 -A`
keyid=`python -c "import uuid; print(uuid.uuid4())"`
echo "
##########################################################################
Copy the following to Azure for your manifest:
##########################################################################
"
echo "\"keyCredentials\": [
{
\"customKeyIdentifier\": \"$base64Thumbprint\",
\"keyId\": \"$keyid\",
\"type\": \"AsymmetricX509Cert\",
\"usage\": \"Verify\",
\"value\": \"$base64Value\"
}
],"
echo "
##########################################################################
Complete the Azure configuration to get the $(tput smso)Client ID$(tput sgr0) and $(tput smso)Tenant ID$(tput sgr0).
##########################################################################
"
echo "This is the $(tput smso)Thumbprint$(tput sgr0) for the ESA configuration: $base64Thumbprint"
echo "This is the $(tput smso)Certificate Private Key$(tput sgr0) for the ESA configuration: $pem
"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you wish to review this certificate in detail? $(tput smso)(y/n)$(tput sgr0) " yn
    case $yn in
        [Yy]* ) openssl x509 -in $crt -text; echo "
Thank you!" && break;;
        [Nn]* ) echo "Thank you!" && exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
