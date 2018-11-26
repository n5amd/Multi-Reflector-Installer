#!/bin/bash
# This script will install, XLXD, YSFREFlector, and YSF2DMR
# for the purpose of having a tri mode transcoding server.
# This will also install the service's respective dashboards
# and configure apache.
# Because of the simplicity around installing AMBED, it will
# not be installed via this script. I dont know where
# you will install it and building logic around that will take
# time. When Version 1 gets released, it will have that feature,
# along with many more.
# This script is just a proof of concept and will be itterated over time.
# Stay tuned...

#Lets begin-------------------------------------------------------------------------------------------------
#Sanity checks
WHO=$(whoami)
#Have to be ROOT to run this script
if [ "$WHO" != "root" ]
then
  echo ""
  echo "You Must be root to run this script!!"
  exit 0
fi
#Has to be a Debian variant.
if [ ! -e "/etc/debian_version" ]
then
  echo ""
  echo "This script is only tested in Debian 9 and x64 cpu Arch. "
  exit 0
fi
#Gather variables.
XLXDREPO=https://github.com/LX3JL/xlxd.git
YSF2DMRREPO=https://github.com/juribeparada/MMDVM_CM.git
YSFREPO=https://github.com/g4klx/YSFClients.git
YSFDASHREPO=https://github.com/dg9vh/YSFReflector-Dashboard.git
LOCAL_IP=$(ip a | grep inet | grep "eth0\|en" | awk '{print $2}' | tr '/' ' ' | awk '{print $1}')
DIRDIR=$(pwd)
echo "------------------------------------------------------------------------------"
echo ""
echo "XLX uses 3 digits numbers for its reflectors. For example: 032, 723, 099"
read -p "What 3 digit XRF number will you be using?  " XRFDIGIT
XFRNUM=XLX$XRFDIGIT
echo "--------------------------------------"
read -p "What will the name of your YSF reflector be? 16 Characters MAX, this includes spaces. " YSFNAME
YSFNAMEC=$(expr length "$YSFNAME")
until [ $YSFNAMEC -le 16 ]
do
read -p "What will the name of your YSF reflector be? 16 Characters MAX, this includes spaces. " YSFNAME
YSFNAMEC=$(expr length "$YSFNAME")
done
echo "--------------------------------------"
echo ""
read -p "What is the description for the YSF Reflector? 14 Characters MAX, this includes spaces. " YSFDESC
YSFDESCC=$(expr length "$YSFDESC")
until [ $YSFDESCC -le 14 ]
do
read -p "What is the description for the YSF Reflector? 14 Characters MAX, this includes spaces. " YSFDESC
YSFDESCC=$(expr length "$YSFDESC")
done
echo "--------------------------------------"
read -p "What is the FQDN of the XLX Reflector dashboard? Example: xlx.domain.com  " XLXDOMAIN
echo ""
read -p "What is the FQDN of the YSF Reflector dashboard? Example: ysf.domain.com  " YSFDOMAIN
echo "------------------------------------------------------------------------------"
#Gather dependicies
echo ""
echo "Installing dependicies..........."
echo ""
#echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list #Required when SSL gets added, not yet though.
apt update
apt -y install git build-essential apache2 php libapache2-mod-php php7.0-mbstring screen wget python-certbot-apache -t stretch-backports
a2enmod php7.0
echo "------------------------------------------------------------------------------"
#Create the install directory and app directories
echo "Making directories...."
mkdir -p /root/reflector-install-files
mkdir -p /root/reflector-install-files/xlxd
mkdir -p /root/reflector-install-files/ysfreflector
mkdir -p /root/reflector-install-files/ysf2dmr
mkdir -p /root/reflector-install-files/ysfdash
mkdir -p /var/www/xlxd
mkdir -p /var/www/ysf
mkdir -p /ysfreflector
mkdir -p /ysf2dmr
echo "------------------------------------------------------------------------------"
#Install xlxd
#If the file is here already, then we dont need to compile on top of it. Remove the git clone directory and start over.
if [ -e /root/reflector-install-files/xlxd/xlxd/src/xlxd ]
then
   echo ""
   echo "It looks like you have already compiled XLX. If you want to install it again, delete the directory '/root/reflector-install-files' and run this script again. "
   exit 0
else
   echo "Downloading and compiling xlxd... "
   cd /root/reflector-install-files/xlxd
   git clone $XLXDREPO
   cd /root/reflector-install-files/xlxd/xlxd/src
   make clean
   make
   make install
fi
#Now the file should be there, if it compiled correctly.
if [ -e /root/reflector-install-files/xlxd/xlxd/src/xlxd ]
then
   echo "------------------------------------------------------------------------------"
   echo "It looks like everything compiled successfully. There is a 'xlxd' application file. "
else
   echo ""
   echo "UH OH!! I dont see the xlxd application file after attempting to compile. The output above is the only indication as to why it might have failed. Removing install files and directories. "
   # Removing install files and Directories
   rm -rf /root/reflector-install-files/
   exit 0
fi
#get DMR files
wget -O /xlxd/dmrid.dat http://xlxapi.rlx.lu/api/exportdmr.php
#Copy files over
cd /root/reflector-install-files/xlxd/
cp -R /root/reflector-install-files/xlxd/xlxd/dashboard/* /var/www/xlxd/
cp /root/reflector-install-files/xlxd/xlxd/scripts/xlxd /etc/init.d/xlxd
#Update up the startup script
sed -i "s/ARGUMENTS=\"XLX270 158.64.26.132\"/ARGUMENTS=\"$XRFDIGIT $LOCAL_IP 127.0.0.1\"/g" /etc/init.d/xlxd
update-rc.d xlxd defaults
echo "XLXD is finished installing and ready to be configured. Moving onto YSF....."
#If the file is here already, then we dont need to compile on top of it. Remove the git clone directory and start over.
if [ -e /root/reflector-install-files/ysfreflector/YSFClients/YSFReflector/YSFReflector ]
then
   echo ""
   echo "It looks like you have already compiled YSFReflector. If you want to install it again, delete the directory '/root/YSFReflector-install-files' and run this script again. "
   exit 0
else
   echo "------------------------------------------------------------------------------"
   echo "Downloading and compiling YSFReflector... "
   cd /root/reflector-install-files/ysfreflector
   git clone https://github.com/g4klx/YSFClients.git
   cd /root/reflector-install-files/ysfreflector/YSFClients/YSFReflector
   make clean all
fi
#Now the file should be there, if it compiled correctly.
if [ -e /root/reflector-install-files/ysfreflector/YSFClients/YSFReflector/YSFReflector ]
then
   echo "------------------------------------------------------------------------------"
   echo "It looks like everything compiled successfully. There is a 'YSFReflector' application file. "
else
   echo ""
   echo "UH OH!! I dont see the YSFReflector application file after attempting to compile. The output above is the only indication as to why it might have failed. Removing install files... "
   # Removing install files and Directories
   rm -rf /root/reflector-install-files
   exit 0
fi
echo "------------------------------------------------------------------------------"
#Copying over files.
echo ""
echo "Copying files over to the executable directory.... "
cp /root/reflector-install-files/ysfreflector/YSFClients/YSFReflector/YSFReflector /ysfreflector
cp /root/reflector-install-files/ysfreflector/YSFClients/YSFReflector/YSFReflector.ini /ysfreflector


#Updating the ini file
echo "------------------------------------------------------------------------------"
echo ""
echo "Updating ini file in /YSFReflector. "
sed -i "s/16[ ]*characters[ ]*max/$YSFNAME/g" /ysfreflector/YSFReflector.ini
sed -i "s/14[ ]*characters[ ]*max/$YSFDESC/g" /ysfreflector/YSFReflector.ini
sed -i "s/FilePath=./FilePath=\/var\/log\/YSFReflector\//g" /ysfreflector/YSFReflector.ini
echo "------------------------------------------------------------------------------"
echo "Creating mmdvm user and setting properties... "
#Creating mmdvm user that is apparently required for this to run.
groupadd mmdvm
useradd mmdvm -g mmdvm -s /sbin/nologin
mkdir -p /var/log/YSFReflector
chown mmdvm: /var/log/YSFReflector
echo "------------------------------------------------------------------------------"
echo "Installing YSF2DMR... "
if [ -e /root/reflector-install-files/ysf2dmr/MMDVM_CM/YSF2DMR/YSF2DMR ]
then
   echo ""
   echo "It looks like you have already compiled YSFReflector. If you want to install it again, delete the directory '/root/reflector-install-files' and run this script again. "
   exit 0
else
   echo ""
   echo "Downloading and compiling YSFReflector... "
   cd /root/reflector-install-files/ysf2dmr
   git clone $YSF2DMRREPO
   cd /root/reflector-install-files/ysf2dmr/MMDVM_CM/YSF2DMR/
   make
fi
#Now the file should be there, if it compiled correctly.
if [ -e /root/reflector-install-files/ysf2dmr/MMDVM_CM/YSF2DMR/YSF2DMR ]
then
   echo "------------------------------------------------------------------------------"
   echo "It looks like everything compiled successfully. There is a 'YSF2DMR' application file. "
else
   echo ""
   echo "UH OH!! I dont see the YSF2DMR application file after attempting to compile. The output above is the only indication as to why it might have failed. Removing install files and directories. "
   exit 0
fi
#Copying files over
cd /root/reflector-install-files/ysf2dmr/MMDVM_CM/YSF2DMR/
cp YSF2DMR /ysf2dmr/
cp YSF2DMR.ini /ysf2dmr/
cp DMRIds.dat /ysf2dmr/
cp XLXHosts.txt /ysf2dmr/

echo "------------------------------------------------------------------------------"
echo "Installing the YSF Dashboard... "
cd /root/reflector-install-files/ysfdash
git clone $YSFDASHREPO
cp -R /root/reflector-install-files/ysfdash/YSFReflector-Dashboard/* /var/www/ysf/

echo "------------------------------------------------------------------------------"
#Copy apache vhost directives
echo "Copying apache directives....."
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/apache.tbd/$XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
echo "------------------------------------------------------------------------------"
#Copy apache vhost files over for ysf
echo "Updating apache directives....."
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$YSFDOMAIN.conf
sed -i "s/apache.tbd/$YSFDOMAIN/g" /etc/apache2/sites-available/$YSFDOMAIN.conf
sed -i "s/ysf-xlxd/ysf/g" /etc/apache2/sites-available/$YSFDOMAIN.conf

echo "------------------------------------------------------------------------------"
echo "Enabling $XLXDOMAIN and $YSFDOMAIN... "
#Enable the sites
a2ensite $XLXDOMAIN
a2ensite $YSFDOMAIN
service apache2 restart

echo "------------------------------------------------------------------------------"
#Copy ysfservice
echo "Copying ysfrelfector to systemd... "
cp $DIRDIR/templates/ysfreflector.service /etc/systemd/system
systemctl daemon-reload
service xlxd start
service ysfreflector start
