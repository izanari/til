# fluentd
- https://docs.fluentd.org/
  
## 読み方
- フルエントディー
## 参考サイト
- [柔軟なログ収集を可能にする「fluentd」入門](https://knowledge.sakura.ad.jp/1336/)
- [fluentdでOSのいろんなログをまとめてS3に出力する設定考えてみた](https://dev.classmethod.jp/cloud/aws/fluentd-settings-with-some-os-logs/)
  
## インストール方法
### Amazon Linux 2
- インストール
```
curl -L https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent3.sh | sh
sudo systemctl start td-agent.service
```
- td-agentをrootで起動するようにする
``` /lib/systemd/system/td-agent.service
User=root
Group=root
```
- 起動する
```
systemctl enable td-agent
systemctl start td-agent
systemctl status td-agent
```

#### EC2起動時にユーザーデータで流す場合
```
curl -L https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent3.sh | sh
sed s/User=td-agent/User=root/ /lib/systemd/system/td-agent.service 
sed s/Group=td-agent/Group=root/ /lib/systemd/system/td-agent.service
systemctl enable td-agent
systemctl start td-agent
systemctl status td-agent
```

