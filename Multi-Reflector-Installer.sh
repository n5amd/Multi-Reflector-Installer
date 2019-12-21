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
WHO=$(whoami)
if [ "$WHO" != "root" ]
then
  echo ""
  echo "You Must be root to run this script!!"
  exit 0
fi
if [ ! -e "/etc/debian_version" ]
then
  echo ""
  echo "This script is only tested in Debian 9 and x64 cpu Arch. "
  exit 0
fi
DIRDIR=$(pwd)
XLXDREPO=https://github.com/LX3JL/xlxd.git
YSF2DMRREPO=https://github.com/juribeparada/MMDVM_CM.git
YSFREPO=https://github.com/g4klx/YSFClients.git
YSFDASHREPO=https://github.com/dg9vh/YSFReflector-Dashboard.git
XLXDMRIDURL=http://xlxapi.rlx.lu/api/exportdmr.php
LOCAL_IP=$(ip a | grep inet | grep "eth0\|en" | awk '{print $2}' | tr '/' ' ' | awk '{print $1}')
XLXINTDIR=/root/reflector-install-files/xlxd
YSFINTDIR=/root/reflector-install-files/ysfreflector
YSF2INTDIR=/root/reflector-install-files/ysf2dmr
YSFDASDIR=/root/reflector-install-files/ysfdash
XLXWEBDIR=/var/www/xlxd
YSFWEBDIR=/var/www/ysf
DEP="git build-essential apache2 php libapache2-mod-php php7.0-mbstring screen wget"
echo "------------------------------------------------------------------------------"
echo ""
echo "XLX uses 3 digits numbers for its reflectors. For example: 032, 723, 099"
read -p "What 3 digit XRF number will you be using?  " XRFDIGIT
XRFNUM=XLX$XRFDIGIT
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
echo ""
read -p "What E-Mail address can your users send questions to?  " EMAIL
echo ""
echo "--------------------------------------"
echo ""
read -p "What is the admins callsign?  " CALLSIGN
#Gather dependicies
echo ""
echo ""
echo "------------------------------------------------------------------------------"
echo "Installing dependicies..........."
echo "------------------------------------------------------------------------------"
apt update
apt -y install $DEP
a2enmod php7.0
echo "------------------------------------------------------------------------------"
#Create the install directory and app directories
mkdir -p $XLXINTDIR
mkdir -p $YSFINTDIR
mkdir -p $YSF2INTDIR
mkdir -p $YSFDASDIR
mkdir -p $XLXWEBDIR
mkdir -p $YSFWEBDIR
mkdir -p /ysfreflector
mkdir -p /ysf2dmr

#Install xlxd
#If the file is here already, then we dont need to compile on top of it. Remove the git clone directory and start over.
if [ -e $XLXINTDIR/src/xlxd ]
then
   echo ""
   echo "It looks like you have already compiled XLX. If you want to install it again, delete the directory '/root/reflector-install-files/' and run this script again. "
   exit 0
else
   echo "Downloading and compiling xlxd... "
   echo "------------------------------------------------------------------------------"
   cd $XLXINTDIR
   git clone $XLXDREPO
   cd $XLXINTDIR/xlxd/src
   make clean
   make
   make install
fi
#Now the file should be there, if it compiled correctly.
if [ -e $XLXINTDIR/xlxd/src/xlxd ]
then
   echo "--------------------------------------"
   echo "It looks like XLXD compiled successfully!! "
   echo "--------------------------------------"
else
   echo ""
   echo "UH OH!! I dont see the xlxd application file after attempting to compile. The output above is the only indication as to why it might have failed. Removing install files and directories. "
   # Removing install files and Directories
   rm -rf /root/reflector-install-files/
   exit 0
fi
echo "------------------------------------------------------------------------------"
echo "Getting DMRID.dat file...  "
echo "------------------------------------------------------------------------------"
wget -O /xlxd/dmrid.dat $XLXDMRIDURL
cd $XLXINTDIR/
cp -R $XLXINTDIR/xlxd/dashboard/* $XLXWEBDIR/
cp $XLXINTDIR/xlxd/scripts/xlxd /etc/init.d/xlxd
sed -i "s/XLX999 192.168.1.240 127.0.0.1/$XRFNUM $LOCAL_IP 127.0.0.1/g" /etc/init.d/xlxd
update-rc.d xlxd defaults
#Delaying startup on boot
mv /etc/rc3.d/S01xlxd /etc/rc3.d/S10xlxd
echo "Updating XLXD Config file... "
XLXCONFIG=/var/www/xlxd/pgs/config.inc.php
sed -i "s/your_email/$EMAIL/g" $XLXCONFIG
sed -i "s/LX1IQ/$CALLSIGN/g" $XLXCONFIG
sed -i "s/\/tmp\/callinghome.php/\/xlxd\/callinghome.php/g" $XLXCONFIG
sed -i "s/http:\/\/your_dashboard/http:\/\/$XLXDOMAIN/g" $XLXCONFIG
chown -R www-data:www-data /xlxd/
chown -R www-data:www-data /var/www/xlxd/
echo "--------------------------------------"
echo "XLXD is finished installing."
echo "--------------------------------------"
if [ -e $YSFINTDIR/YSFClients/YSFReflector/YSFReflector ]
then
   echo ""
   echo "It looks like you have already compiled YSFReflector. If you want to install it again, delete the directory '/root/YSFReflector-install-files' and run this script again. "
   exit 0
else
   echo "------------------------------------------------------------------------------"
   echo "Downloading and compiling YSFReflector... "
   echo "------------------------------------------------------------------------------"
   cd $YSFINTDIR
   git clone https://github.com/g4klx/YSFClients.git
   cd $YSFINTDIR/YSFClients/YSFReflector
   make clean all
fi
if [ -e $YSFINTDIR/YSFClients/YSFReflector/YSFReflector ]
then
   echo "--------------------------------------"
   echo "It looks like YSFReflector compiled successfully. "
   echo "--------------------------------------"
else
   echo ""
   echo "UH OH!! I dont see the YSFReflector application file after attempting to compile. The output above is the only indication as to why it might have failed. Removing install files... "
   # Removing install files and Directories
   rm -rf /root/reflector-install-files
   exit 0
fi
#Copying over files.
cp $YSFINTDIR/YSFClients/YSFReflector/YSFReflector /ysfreflector
cp $YSFINTDIR/YSFClients/YSFReflector/YSFReflector.ini /ysfreflector
#Updating the ini file
sed -i "s/16[ ]*characters[ ]*max/$YSFNAME/g" /ysfreflector/YSFReflector.ini
sed -i "s/14[ ]*characters[ ]*max/$YSFDESC/g" /ysfreflector/YSFReflector.ini
sed -i "s/FilePath=./FilePath=\/var\/log\/YSFReflector\//g" /ysfreflector/YSFReflector.ini
#Creating mmdvm user that is apparently required for this to run.
groupadd mmdvm
useradd mmdvm -g mmdvm -s /sbin/nologin
mkdir -p /var/log/YSFReflector
chown mmdvm: /var/log/YSFReflector
cp $DIRDIR/templates/ysfreflector.service /etc/systemd/system
systemctl enable ysfreflector
systemctl daemon-reload
echo ""
echo "--------------------------------------"
echo "YSFReflector is finished installing."
echo "--------------------------------------"
echo ""
if [ -e $YSF2INTDIR/MMDVM_CM/YSF2DMR/YSF2DMR ]
then
   echo ""
   echo "It looks like you have already compiled YSFReflector. If you want to install it again, delete the directory '/root/reflector-install-files' and run this script again. "
   #exit 0
else
   echo "------------------------------------------------------------------------------"
   echo "Installing YSF2DMR... "
   echo "------------------------------------------------------------------------------"
   cd $YSF2INTDIR
   git clone $YSF2DMRREPO
   cd $YSF2INTDIR/MMDVM_CM/YSF2DMR/
   make
fi
#Now the file should be there, if it compiled correctly.
if [ -e $YSF2INTDIR/MMDVM_CM/YSF2DMR/YSF2DMR ]
then
   echo "--------------------------------------"
   echo "It looks like YSF2DMR compiled successfully. "
   echo "--------------------------------------"
else
   echo ""
   echo "UH OH!! I dont see the YSF2DMR application file after attempting to compile. The output above is the only indication as to why it might have failed. Removing install files and directories. "
   exit 0
fi
#Copying files over
cd $YSF2INTDIR/MMDVM_CM/YSF2DMR/
cp YSF2DMR /ysf2dmr/
cp YSF2DMR.ini /ysf2dmr/
cp DMRIds.dat /ysf2dmr/
cp XLXHosts.txt /ysf2dmr/
echo ""
echo "--------------------------------------"
echo "YSF2DMR is finished installing."
echo "--------------------------------------"
echo ""
echo "------------------------------------------------------------------------------"
echo "Installing the YSF Dashboard and configuring apache... "
echo "------------------------------------------------------------------------------"
cd $YSFDASDIR
git clone $YSFDASHREPO
cp -R $YSFDASDIR/YSFReflector-Dashboard/* $YSFWEBDIR/
mkdir $YSFWEBDIR/config
cp $DIRDIR/templates/config.php $YSFWEBDIR/config/
mv $YSFWEBDIR/setup.php $YSFDASDIR/original-setup.php
#Copy apache vhost directives
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/apache.tbd/$XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
#Copy apache vhost files over for ysf
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$YSFDOMAIN.conf
sed -i "s/apache.tbd/$YSFDOMAIN/g" /etc/apache2/sites-available/$YSFDOMAIN.conf
sed -i "s/ysf-xlxd/ysf/g" /etc/apache2/sites-available/$YSFDOMAIN.conf
chown -R www-data:www-data /var/www/ysf
echo "--------------------------------------"
echo "Enabling $XLXDOMAIN and $YSFDOMAIN... "
echo "--------------------------------------"
#Enable the sites
a2ensite $XLXDOMAIN
a2ensite $YSFDOMAIN
echo "--------------------------------------"
echo "Starting xlxd and YSFReflector... "
echo "--------------------------------------"
service xlxd start
service ysfreflector start
echo "--------------------------------------"
echo "Reloading apache2."
echo "--------------------------------------"
systemctl restart apache2
echo ""
echo ""
echo "***********************************************************************************"
echo ""
echo "              Your 3-in-1 Reflector is finished installing.                        "
echo "   At this time, you have a D-Star and YSF Server installed and running!!          "
echo "              There is still more configuration to be done..."
echo " Please visit https://github.com/n5amd/Multi-Reflector-Installer For more info..   "
echo ""
echo "                   Your 2 web dashboards can be found at:                          "
echo "                      http://$XLXDOMAIN                                            "
echo "                      http://$YSFDOMAIN                                            "
echo ""
echo "***********************************************************************************"
echo ""
