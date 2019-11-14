# EC2
## メトリクス
### 標準のメトリクスで取得できるデータ
- CPU使用率
- ネットワーク使用率
- ディスク I/O
### カスタムメトリクスにしないと取得できない
- ディスク使用率
- swap使用率
- メモリ使用率
### [Amazon EC2 Linux インスタンスのメモリとディスクのメトリクスのモニタリング](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/mon-scripts.html)
- 必要なアクセス権
  - cloudwatch:PutMetricData
  - cloudwatch:GetMetricStatistics
  - cloudwatch:ListMetrics
  - ec2:DescribeTags
## EBS
- EBS暗号化はパフォーマンスに影響しない
- 
## 起動時にSSMを使えるようにする
### Amazon Linux2の場合
- インスタンス作成時に、ユーザーデータから`ssm-agent`を起動するようにする
![EC2](../img/ec2-01.png)

  - ec2の起動は以下のようにしましょう
```
#!/bin/bash
yum update -y
#yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
timedatectl set-timezone Asia/Tokyo

yum -y install httpd.x86_64 
systemctl enable httpd
systemctl start httpd

```
- そのほかに以下を忘れないよう設定する
  - IAMロールには、`AmazonEC2RoleforSSM`を付与したロールをつけておく
  - EIPを付与する。もしくは、ゲートウェイを作成し、SSMサービスと通信できるようにする
  
### Amazon Linux2以外は以下を参照
- [Amazon EC2 Linux インスタンスに SSM エージェント を手動でインストールする](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-manual-agent-install.html)