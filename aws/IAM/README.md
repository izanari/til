# IAM
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
## CLIでの調べ方
### roleに付与されている権限を調べる
1. roleをリスト表示させて、調べたいRoleNameを特定する。rolenameがわかっている場合は不要。
```
aws iam list-role 
```
2. リストに関連づけているPolicyNameを調べる
```
aws iam list-attached-role-policies --role-name rolename （管理ポリシーの場合）
aws iam list-role-policies --role-name rolename  (インラインポリシーの場合)
```
3. 管理ポリシーの場合：policyのarnとversionを調べる
```
aws iam list-policies --profile hogehoge --output json | grep -B3 -A8 'arn:aws:iam::accountid:policy/policyname'
```
4. 管理ポリシーの場合：policyarnとバージョンを指定して詳細を表示する
```
aws iam get-policy-version --policy-arn arn:aws:iam::accountid:policy/policyname --version-id v2
```
5. インラインポリシーの場合：rolenameとpolicynameを指定して詳細を表示する
```
aws iam get-role-policy --role-name rolename --policy-name policyname 
```

#### 参考URL
- [【AWS】aws-cliでIAMの管理ポリシー・インラインポリシーを操作する](https://dev.classmethod.jp/cloud/aws/aws-cli-operate-iam-policy/)
