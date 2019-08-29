#!/bin/sh

set -ex;
systemctl enable amazon-ssm-agent;
timedatectl set-timezone Asia/Tokyo;

