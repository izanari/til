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

## systemd
### ユニットファイルを更新した時
```
systemctl daemon-reload
```