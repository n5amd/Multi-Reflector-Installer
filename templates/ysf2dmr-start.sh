#!/bin/bash
# This is a modified version of the startup script for DIREWOLF. 
# Original credit goes to 'wb2osz'.
# https://github.com/wb2osz/direwolf/blob/master/dw-start.sh
# Be sure to add this to crontab via 'crontab -e' 
# * * * * * /ysf2dmr/ysf2dmr-start.sh >/dev/null 2>&1
# Since YSF2DMR doesnt have an init or unit file yet, we need
# to start it via screen and this will do it for you and keep it alive.

RUNMODE=wb2osz
YSF2DMR="/ysf2dmr/YSF2DMR"
YSFCMD="$YSF2DMR YSF2DMR.ini"
LOGFILE=/var/tmp/ysf2dmr-start.log

#Status variables
SUCCESS=0

function wb2osz {
   SCREEN=`which screen`
   if [ $? -ne 0 ]; then
      echo -e "Error: screen is not installed but is required.  Aborting"
      exit 1
   fi

   echo "YSF2DMR Start"
   echo "YSF2DMR Start" >> $LOGFILE


   cd /ysf2dmr; $SCREEN -d -m -S ysf2dmr $YSFCMD >> $LOGFILE
   SUCCESS=1

   $SCREEN -list ysf2dmr
   $SCREEN -list ysf2dmr >> $LOGFILE

   echo "-----------------------"
   echo "-----------------------" >> $LOGFILE
}

a=`ps ax | grep YSF2DMR | grep -vi -e bash -e screen -e grep | awk '{print $1}'`
if [ -n "$a" ]
then
  exit
fi

# Main execution of the script

if [ $RUNMODE == "wb2osz" ];then
   wb2osz
else
   #echo -e "ERROR: illegal run mode given.  Giving up"
   exit 1
fi
