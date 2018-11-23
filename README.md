# Multi-Reflector-Installer (Proof of Concept)
The script is very much currently a proof of concept. The concept is, This will build you a 3 mode Ham radio digital voice reflector that will transcode Yaesu Fusion, DMR, and D-Star with the help of AMBED and AMBE vocoder chips. I did not build each application, this script simply goes through the install steps for each application for you and configures apache for the dashboards. Features and abilities coming...

#### This script will install the following:
  - XLXD
  - YSFReflector
  - YSF2DMR
  - YSF Dashboard
  - Apache2 and configure the virtualhosts for both dashboards
  
  **But not**
 - AMBED (along with the required AMBED chips)
  
#### You will need the following information to get started:
 - Ready to go **and updated** fresh install of Debian 9.x
 - FQDN for ysf and xlx
 - XLX number that isnt taken (or pick a random one for testing)
 
#### The script does not yet configure the ini or config files which you will have to do:
 - ysf2dmr.ini
 - ysfreflector.ini
 - xlxd config.inc.php & init.d file
 
#### To give you a visual idea of what the end result would look like, Here is a diagram of XLX410 which is installed based off this method. AMBED can be installed locally or on a remote server. 

![Reflector setup](https://sadigitalradio.com/wp-content/uploads/2018/11/Local-XLX-Network.jpg)

### For more information, please visit:
https://sadigitalradio.com/digital-radio-how-tos/create-xlx-xrf-d-star-reflector/
