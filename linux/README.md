# Linux 全般
## cron
### cronからのメールを停止させたい
```
vim /etc/sysconfig/crond

CRONDARGS="-m off"
```
- 編集後はcrondの再起動が必要です

