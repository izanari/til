# ec2
## 起動時にSSMを使えるようにする
### Amazon Linux2の場合
- インスタンス作成時に、ユーザーデータから`ssm-agent`を起動するようにする
![EC2](../img/ec2-01.png)

- IAMロールには、`AmazonEC2RoleforSSM`を付与したロールをつけておく
- EIPを付与する。もしくは、ゲートウェイを作成し、SSMサービスと通信できるようにする
