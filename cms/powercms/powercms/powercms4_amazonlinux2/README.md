# Amazon Linux2に対するPowerCMS4・5の導入方法

## OSのタイムゾーン設定・タイムサーバの設定をする
- [EC2インスタンス作成時に流すユーザーデータ](./install-step0.sh)


## パッケージを最新状態にする
- [yum-update](./install-step1.sh)


## PowerCMSに必要なパッケージをインストールする
- [yum+cpanm](./install-step2.sh)
- ダイナミックパブリッシングをするのであればPHPもインストールする


## mariadbの設定をする
```
systemctl start mariadb
mysql -u root -p
mysql > create database powercms character set utf8;
mysql > grant all on powercms.* to cmsman@localhost identified by 'yourpassword';
```
- 初期インストール時にはrootのパスワードが設定されていない

## PowerCMSのインストール・Apacheの設定をする
- [powercms+apache](./install-step3.sh)

## SuperVisorの設定をする
- [supervisor](./install-step4.sh)
