# IAMでの操作

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