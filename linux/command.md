# linuxのよく使うコマンド
## ps
- プロセスのメモリとCPU使用率を表示する
```
ps aux
```
- ツリー状にプロセスを表示する
```
ps auxf
```

## ls
- ファイルサイズの大きさをM表示する
```
ls -lh
```

## systemd
### ユニットファイルを更新した時
```
systemctl daemon-reload
```

## yum
- インストール済みパッケージを表示する
  - `yum list installed`
- アップデート可能なパッケージを表示する
  - `yum list updates`
- セキュリティパッチの緊急なものだけをアップデートする
  - `yum update --sec-severity=critical`
  - `critical`のところは以下のようにすることも可能
    - important
    - medium
    - low
  - このオプションは、`yum list updates --sec-severity=low`というように使うことも可能
- パッケージをダウングレードする
  - `yum --showduplicate list packagename` で表示されれば可能です
  - `yum downgrade packagename`
- 参考ドキュメント
  - [Redhat系Linuxで、OSパッケージを戻す方法](https://qiita.com/sasasin/items/f865848239e7b0a38e06)
## find
- 指定した日付（時間）のファイルを削除する
  - `mmin`：分
  - `mtime`：日
```
find /var/www/html -name "mt-preview-*" -mmin +30 -exec rm -f {} \;
```

## more
- 現在の行番号を表示する
  ```
  =
  ```
- パターン検索する
  ```
  /パターン
  ```

## grep
- 行数を表示する
  ```
  grep -n "hogehoge" fugafuga.txt
  ```