## IAM 記述サンプル
### Principal
- AカウントのIAMユーザーhogehoge
  ```
        "Principal": {
          "AWS": "arn:aws:iam::Aカウント:user/hogehoge"
        },
  ```

- 各サービスに必要なアクションはここに記載されています
  - [Actions, Resources, and Condition Keys for AWS Services](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)
## セッションマネージャーの利用を規制したい場合
- EC2に付与されているタグに応じて`Deny`する例。これをIAMグループポリシーに設定しておけばよい。
  - 参照：[インスタンスタグに基づく Run Command アクセスの制限](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-rc-setting-up-cmdsec.html)
  - 参照：[特定 EC2 インスタンスには、SSM セッションログインさせたくないんや](https://dev.classmethod.jp/cloud/aws/deny-session-manager/)
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