#!/bin/bash

set -ex;
start amazon-ssm-agent
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
cat << EOL | sudo tee /etc/sysconfig/clock
ZONE="Asia/Tokyo"
UTC=true
EOL

service ntpd stop
yum -y erase ntp*
yum -y install chrony
service chronyd start
chronyc sources –v
chkconfig --level 345 chronyd on
