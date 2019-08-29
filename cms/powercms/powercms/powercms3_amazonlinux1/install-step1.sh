#/bin/sh

yum update -y;

TARGETSTR="Reboot is required";

REBOOTMESSAGE=`needs-restarting -r`
RETSTR=`echo $REBOOTMESSAGE | grep "$TARGETSTR"`

if test ${#RETSTR} -gt ${#TARGETSTR} ;then
  # grep した結果の文字数で判断する
  /bin/sync
  /bin/sync
  /sbin/reboot >> /var/log/reboot.log 
fi