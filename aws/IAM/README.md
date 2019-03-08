# IAM
## セッションマネージャーの利用を規制したい場合
- EC2に付与されているタグに応じて`Deny`する例。これをIAMグループポリシーに設定しておけばよい。
  - 参照：[インスタンスタグに基づく Run Command アクセスの制限](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-rc-setting-up-cmdsec.html)
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "ssm:StartSession",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ssm:resourceTag/location": [
            "dmz"
          ]
        }
      }
    }
  ]
}
```
