# Multi-Reflector-Installer (Proof of Concept)
The script is very much currently a proof of concept and gets you about 90% of the way to have everything fully installed and configured. The concept is, This will build you a 3 mode ham radio digital voice reflector server that will transcode Yaesu Fusion, DMR, and D-Star with the help of AMBED and AMBE vocoder chips. I did not build each application. This script simply goes through the install steps for each application for you and configures apache for the dashboards. Features and abilities coming...

#### This script will install the following:
  - `XLXD` *(D-Star/DMR Reflector that also communicates with AMBED)*
  - `YSFReflector` *(HomeBrew Fusion Reflector)*
  - `YSF2DMR` *(The bridge software between YSF and XLX)*
  - `YSF and XLX Dashboards` *(Web pages that shows real-time activity)*
  - Apache2 and configure the virtualhosts for both dashboards
  
  **But not**
 - `AMBED` (along with the required AMBE chips)
 - *AMBED can be installed locally or on a remote server, but is required for the transcoding part.* 
  
#### You will need the following information to get started:
 - Ready to go **and updated** fresh install of Debian 9.x
 - FQDN for ysf and xlx web dashboards
 - XLX number that isnt taken (or pick a random one for testing)


#### The script does not yet edit all the config files in order to complete the installation:
| App | Config file(s) |
| ------ | ------ |
| XLXD | /etc/init.d/xlxd, /var/www/xlxd/pgs/config.inc.php |
| YSF | /ysfreflector/YSFReflector.ini |
| YSF2DMR | /ysf2dmr/YSF2DMR.ini |

### Using the Multi-Reflector-Installer script:
```sh
git clone https://github.com/n5amd/Multi-Reflector-Installer.git
cd Multi-Reflector-Installer
./Multi-Reflector-Installer.sh
```

### To manage each service after installation:
 **XLXD** 
 ```sh
 systemctl start|stop|status|restart xlxd
 ```
  - Installs to /xlxd
  - Logs are in /var/log/messages
  - Be sure to restart xlxd after each config change

 
 **YSFReflector**
  ```sh
 systemctl systemctl start|stop|status|restart ysfreflector
 ```
  - Installs to /ysfreflector
  - Logs are in /var/log/YSFReflector
 
 **YSF2DMR**
 ```sh
 Screen -S ysf2dmr
 cd /ysf2dmr
 ./YSF2DMR YSF2DMR.ini
 ```
  To exit the screen session to leave the program running:
  ```sh
  ctrl-a, then press d
  ```
  
#### To give you a visual idea of what the end result would look like, here are 2 scenarios..

## Scenario A :
Cloud Server installation allowing for worldwide connectivity. Here is XLX410 as an example..

![Reflector setup](https://sadigitalradio.com/wp-content/uploads/2018/11/Local-XLX-Network.jpg)

## Scenario B :
A single tower site installation allowing local communication across 3 different digital modes…

![Single Site](https://sadigitalradio.com/wp-content/uploads/2018/11/Single-repeater-site.png)

### For more information, please visit:
https://sadigitalradio.com/digital-radio-how-tos/build-digital-voice-transcoding-server/
