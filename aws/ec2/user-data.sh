#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
timedatectl set-timezone Asia/Tokyo

yum -y update
systemctl enable amazon-ssm-agent

# code deploy agent
yum -y install ruby
cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto


echo "End user-data!"