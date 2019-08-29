# Amazon Linux（AMI 2018.03.0）に対するPowerCMS3の導入方法
## OSのタイムゾーン設定・タイムサーバの設定をする
- [EC2インスタンス作成時に流すユーザーデータ](./install-step0.sh)
## パッケージを最新状態にする
- [yum-update](./install-step1.sh)
## PowerCMSに必要なパッケージをインストールする
- [yum+cpanm](./install-step2.sh)

## mysqlの設定をする
```
/etc/init.d/mysqld start
/usr/bin/mysqladmin -u root password 'yourpassword'

mysql -u root -p
mysql > create database powercms character set utf8;
mysql > grant all on powercms.* to cmsman@localhost identified by 'yourpassword';
```
- ここではMySQL5.1を利用しています
## PowerCMSのインストール・Apacheの設定をする
- [powercms+apache](./install-step3.sh)

## SuperVisorの設定をする
- [supervisor](./install-step4.sh)
