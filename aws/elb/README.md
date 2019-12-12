# ELB
## Application Load Balancer
### リスナー
#### サポートしているプロトコル,ポート
- プロトコル
  - HTTP,HTTPS
- ポート
  - 1から65535
- WebSocket
  - HTTP,HTTPSの両方で利用することができる
- HTTP/2
  - HTTPSリスナーがネイティブでサポートする
  - ALBはHTTP/2で受けて、HTTP/1.1のリクエストに変換し、ターゲットグループの正常なターゲットにこれを分配します。HTTP/2のサーバpush機能は利用することができない

## アクセスログ
### S3バケットに保存する
- [Application Load Balancer のアクセスログ](https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
- 東京リージョンは、`582318560864`
- バケットポリシーは、以下を追加します
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::aws-account-id:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::bucket-name/prefix/*"
    }
  ]
}
```