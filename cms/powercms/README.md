# PowerCMS4のインストール
- 動作環境は、[ここ](https://www.powercms.jp/products/requirements.html)を参照しましょう
## Amazon Linux2 へのインストール
### 前提
- PSGI(starman)を利用する
- starmanはsupervisorで管理する
- mysqlではなく、mariadbを利用する
- Apacheを利用する

### ディレクトリ構成
```
/var/www/
├──html/                  ドキュメントroot
└──powercms4/
   └── mt/               PowerCMSの本体プログラム
　　　　 └── mt-static/   mt-static ディレクトリ
```

### 事前準備
- EC2インスタンスを作成します
  - SSHアクセスは設定しないでセッションマネージャーを利用しましょう
  - セッションマネージャーからアクセスするためには、IAMロールの設定が必要です。必要な権限を設定したロールが作成できるCloudFormationテンプレートは、[こちら](./scripts/make-iamrole.yml)にあります。最低限の設定しか記述していないので、必要に応じてカスタマイズしてください
  - EC2起動時に、AWS Systems Managerと通信できるようにする必要があります。agentのインストールはされていますが、デフォルトでは起動しません。EC2インスタンス作成時に、[この](./scripts/install-step0.sh)シェルを流し込んでください
  - EIPもしくはNATゲートウェイを設定し、EC2からインターネットにアクセスできるようにします
  - セキュリティグループのアウトバウンドは、80,443portを0.0.0.0/0でアクセスできるようにしておきます
- OSのモジュールを最新化しておきます
  - [この](./scripts/install-step1.sh)シェルを実行します

- そのほかに必要な設定をしておきます

### インストール
#### 必要モジュールのインストール
- PowerCMSが必要とするモジュールをインストールします。
  - 多くのモジュールが必要なため、シェルにしてあります。[この](./scripts/install-step2.sh)シェルを使ってください。
    - このシェルは、EC2インスタンス上にmariadb serverを起動することにしています。必要なければ、`yum -y install mariadb-server.x86_64;`の行は削除してください
    - 最低限のperlモジュールのインストール確認は、[この](./scripts/perl-installcheck.sh)シェルを使って確認することができます。インストールができていない時は以下のエラーメッセージが表示されます

```
Can't locate Image/Magick.pm in @INC (@INC contains: /root/perl5/lib/perl5/x86_64-linux-thread-multi /root/perl5/lib/perl5/usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .).
BEGIN failed--compilation aborted.
```

#### apacheの設定を行います
- Apacheの設定ファイルを追加します
  - サンプルの設定ファイルは、[これ](./apache/powercms4.conf)です。これを`/etc/httpd/conf.d/powercms4.conf`におきます。
    - 静的ファイルをブラウザにキャッシュさせるように設定しています
  - Apacheの再起動をします
    -  `sudo systemctl start httpd`

#### mysqlの設定を行います
- mysqlのrootパスワードの設定をします
- 同時にanonymous login やtest databaseを削除します
```
% /usr/bin/mysqladmin -u root password 'hogehoge';
% mysql_secure_installation
```

- DBのスキーマを作成します。下記情報は必要に応じて変更してください。
  - DB名： powercms4
  - ユーザー名： cmsman
  - パスワード： pass_pass_pass
```
sudo systemctl start mysql（起動していない場合）
mysql -u root -p 
mysql > create database powercms4 character set utf8;
mysql > grant all on powercms4.* to cmsman@localhost identified by 'pass_pass_pass';
```

#### PowerCMS4 を展開します
  - ec2-userのホームディレクトリにzipファイルがある前提です
  - ZIPを展開すると、`MT6.3.8001-PowerCMSProfessional4.41`というディレクトリが作成されるので、powercms4にシンボリックリンクを貼ります
  - powercmsのバージョンアップ時に`powercms_files`を移行するのが大変なので、`/var/www/powercms/powercms_files`などとしておきます
```
cd /var/www
sudo unzip -qq ~ec2-user/MT6.3.8001-PowerCMSProfessional4.41.zip;
sudo ln -s ./MT6.3.8001-PowerCMSProfessional4.41 ./powercms4;
cd /var/www/powercms4/options; sudo cp -pR ./* /var/www/powercms4/mt;
cd /var/www/powercms4/options_legacy; sudo cp -pR ./* /var/www/powercms4/mt;
cd /var/www/powercms4/mt; sudo mv ./powercms_files/ /var/www/powercms4/;
sudo ln -s /var/www/powercms4/powercms_files/ /var/www/powercms4/mt/powercms_files/
sudo chown -R apache /var/www/powercms4/;
sudo chown -R apache /var/www/html;
```
#### PowerCMSへアクセスする
- ブラウザから`http://yourdomein/powercms4/mt/mt.cgi`でアクセスします
- PowerCMS4のインストール画面が表示されます
  - 初期のウェブサイトまで作成しておきます
  - ログインできることを確認します
    - これで設定ファイルが書き込まれます

#### 次にPSGI環境を構築します
##### Apacheの設定を変更します
- 変更前（/etc/httpd/conf.d/powercms4.conf）
```
        Alias       /powercms4/mt/mt-static/   "/var/www/powercms4/mt/mt-static/"
        ScriptAlias /powercms4/mt/ "/var/www/powercms4/mt/"

        #ProxyRequests    Off
        #ProxyPass        /powercms4/mt/  http://localhost:5000/powercms4/mt/
        #ProxyPassReverse /powercms4/mt/ http://localhost:5000/powercms4/mt/
        #ProxyTimeout 1200
```
- 変更後
  - ScriptAliasをやめて、Proxyでstarmanに接続させます
```
        Alias       /powercms4/mt/mt-static/   "/var/www/powercms4/mt/mt-static/"
        #ScriptAlias /powercms4/mt/ "/var/www/powercms4/mt/"

        ProxyRequests    Off
        ProxyPass        /powercms4/mt/  http://localhost:5000/powercms4/mt/
        ProxyPassReverse /powercms4/mt/ http://localhost:5000/powercms4/mt/
        ProxyTimeout 1200
```
- Apacheの再起動をします
  - `sudo systemctl restart httpd`
##### PowerCMSの設定を追加します
- 下記の行を`/var/www/powercms4/mt/mt-config.cgi`に追加します
```
PIDFilePath /var/www/powercms4/mt/powercms4.pid
```
- supervisordの設定をします。以下のファイルを参照ください
  - [/etc/supervisor/supervisor.service](./supervisor.service)
  - [/etc/supervisor/supervisor.conf](./supowervisor/supervisor.conf)
  - [/etc/supervisor/powercms4.conf](./supowervisor/powercms4.conf)
```
sudo mkdir /etc/supervisor
sudo vim /etc/supervisor/supervisor.service
sudo systemctl link /etc/supervisor/supervisor.service
sudo mkdir /var/log/supervisor
sudo mkdir /var/log/starman
sudo chown apache /var/log/starman
sudo vi /etc/supervisor/supervisor.conf
sudo vi /etc/supervisor/powercms4.conf
```

- supervisorを登録します
```
sudo systemctl link /etc/supervisor/supervisor.service
```
- 起動テストをします
```
sudo systemctl start supervisor
sudo systemctl status supervisor
```
以下のような表示になります。
```
$ sudo systemctl status supervisor
● supervisor.service - Starman Service
   Loaded: loaded (/etc/supervisor/supervisor.service; linked; vendor preset: disabled)
   Active: active (running) since Wed 2019-04-17 16:21:05 JST; 7s ago
  Process: 3831 ExecStop=/usr/bin/supervisorctl shutdown (code=exited, status=1/FAILURE)
 Main PID: 4340 (supervisord)
   CGroup: /system.slice/supervisor.service
           ├─4340 /usr/bin/python2 /usr/bin/supervisord -n -c /etc/supervisor/supervisor.conf
           ├─4343 starman master -l 127.0.0.1:5000 --workers 2 --pid /var/www/powercms4/mt/powercms4.pid ./mt.psgi
           ├─4344 starman worker -l 127.0.0.1:5000 --workers 2 --pid /var/www/powercms4/mt/powercms4.pid ./mt.psgi
           └─4345 starman worker -l 127.0.0.1:5000 --workers 2 --pid /var/www/powercms4/mt/powercms4.pid ./mt.psgi
```
- ブラウザからPowerCMSにアクセスし、ログインできることを確認します
  - [システムメニュー]-[システム情報]を表示します
    - `サーバーモデル: PSGI`と表示されていればOKです

- 停止ができることも確認します
```  
sudo systemctl stop supervisor
```
- 以下のように表示されます
```
$ sudo systemctl status supervisor
● supervisor.service - Starman Service
   Loaded: loaded (/etc/supervisor/supervisor.service; linked; vendor preset: disabled)
   Active: failed (Result: exit-code) since Wed 2019-04-17 16:26:39 JST; 5s ago
  Process: 4375 ExecStop=/usr/bin/supervisorctl shutdown (code=exited, status=1/FAILURE)
  Process: 4340 ExecStart=/usr/bin/supervisord -n -c /etc/supervisor/supervisor.conf (code=exited, status=0/SUCCESS)
 Main PID: 4340 (code=exited, status=0/SUCCESS)

（以下省略）
```
- 以上で基本インストールは完了です

### 他にやること
- PowerCMSの設定を追加する
  - 設定ファイルは、[ここ](./powercms/mt-config.cgi)を参考にしてください
- 不要なプラグインは無効化します
  - [プラグイン]-[管理]から無効化します。これを行うことで、プラグインディレクトリからプラグインのディレクトリが退避されます。
- 必要なプラグインをインストールします
- cronの設定をします。サンプルは以下です。
```
$ more powercms 
MAILTO=yourmailaddress
MT_DIR=/var/www/powercms4/mt
*/5 0-23 * * * apache cd $MT_DIR && /usr/bin/perl ./tools/run-tasks -tasks FuturePost,EntryUnpublish,FutureRevision,CleanTemporaryFiles
*/10 0-23 * * * apache cd $MT_DIR && /usr/bin/perl ./tools/run-tasks -tasks StagingSync
*/60 0-23 * * * apache cd $MT_DIR && /usr/bin/perl ./tools/run-tasks -tasks PurgeExpiredSessionRecords,PurgeExpiredDataAPISessionRecords
#0 21 * * * apache cd $MT_DIR && /usr/bin/perl ./tools/run-backup-sql-and-docs
15 10 * * * apache cd $MT_DIR && /usr/bin/perl ./tools/mt-logrotate
34 10 * * * apache php /data/opt/sanno-php/tools/powercmslog2s3.php
*/30 * * * * apache find /var/www/html -name "mt-preview-*" -mmin +30 -exec rm -f {} \;
```
- プラグインの設定
  - 以下の設定はしておきましょう
    - Logrotate
      - Logファイルをどの程度保存しておくのか。
    - Backup Configuration
  
- Apacheの設定
  - 基本認証
  - PHP
  - .....

## 参考ドキュメント
- [環境変数リファレンス](https://www.powercms.jp/products/document/config-directives/)
- [PowerCMS 3.2 を PSGI 環境で運用する](https://www.powercms.jp/blog/2012/11/powercms_32_psgi.html)
- [Supervisorで簡単にデーモン化](https://qiita.com/yushin/items/15f4f90c5663710dbd56)