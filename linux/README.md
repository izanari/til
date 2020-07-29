# Linux 全般
## cron
### cronからのメールを停止させたい
```
vim /etc/sysconfig/crond

CRONDARGS="-m off"
```
- 編集後はcrondの再起動が必要です

## 標準出力・エラー
- 標準出力とエラーを一つのファイルに出力する
```
hoge.sh > /tmp/fuga-log 2>&1
```
## RedHat Linux
- [ライフサイクル](https://access.redhat.com/ja/support/policy/updates/errata)
- [Red Hat Software Collections (RHSCL) または Red Hat Developer Toolset (DTS) を使用する](https://access.redhat.com/ja/solutions/666823)
- [Red Hat Enterprise Linux における PHP のサポート](https://access.redhat.com/ja/solutions/1290433)

## logrotate
- 参考URL https://www.atmarkit.co.jp/flinux/rensai/linuxtips/747logrotatecmd.html
```
/var/log/hogehoge/*log {
    missingok       ログファイルが存在しなくてもエラーを出さずに処理を続行
    notifempty      ログファイルが空ならローテーションしない
    sharedscripts   複数指定したログファイルに対し、postrotateまたはprerotateで記述したコマンドを実行
    delaycompress   ログの圧縮作業を次回のローテーション時まで遅らせる。compressと共に指定
    compress        ローテーションしたログをgzipで圧縮 
    #
    daily           ログを毎日ローテーションする(weekly/monthly)
    dateext
    rotate 90       ローテーションする回数を指定
    copytruncate    ログファイルをコピーし、内容を削除
    #
    postrotate      postrotateとendscriptの間に記述されたコマンドをログローテーション後に実行
	for logfile in $1; do
        	/usr/bin/perl /fullpath/hogehoge.pl $logfile
	done
    endscript
}
```

/var/www*log{
    missingok
    notifempty
    delaycompress
    compress
    daily
    dateext
    rotate 35 
    create 0644 nginx nginx
}

## 行番号付きでcatする
```
cat -n filename | more
```

## ソースコードの入手方法
- ソースコードをダウンロードします
  - yumdownloader --source vsftpd
- ソースコードを取り出します
  - rpm2cpio vsftpd-3.0.2-25.amzn2.src.rpm | cpio -id