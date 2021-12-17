# AWS CLI
## [broamski/aws-mfa](https://github.com/broamski/aws-mfa)
二段階認証を求められる場合、簡単に認証が取れるツール。Pythonが必要です。
### 設定
- ~/.aws/credential に以下の設定をする。profile名の後に、`-long-term`をつける。
```
[profilename-long-term]
aws_access_key_id = your access key
aws_secret_access_key = secret key 
aws_mfa_device = arn:aws:iam::accountid:mfa/accountname
```
- 以下のコマンドを実行します
```
export AWS_PROFILE=profilename
aws-mfa
```
もしくは
```
aws-mfa --profile profilename
```

## 参考サイト
- [AWS CLIのフィルターとクエリーの使い方についてまとめてみた](https://dev.classmethod.jp/cloud/aws/aws-cli-filter-and-query-howto/)
- [AWS CLI の使用](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-using.html)
- [JMESPath チュートリアル](https://dev.classmethod.jp/cloud/aws/jmespath-tutorial/)

## 設定
### 参照サイト
- https://dev.classmethod.jp/cloud/aws/how-to-configure-aws-cli/

## コマンド
- 設定されているプロファイルを一覧表示する
```
% aws configure list
```
- デフォルトのプロファイルを変更する
```
% export AWS_DEFAULT_PROFILE=hogehoge
```
- 現在取得している認証情報を表示する
```
aws sts get-caller-identity
```

## 自分で作成したAMIの一覧を表示する
```
#!/bin/sh

aws ec2 describe-images \
 --owners self \
 --query 'Images[*].{id:ImageId,date:CreationDate}' \
 --output json
```

### 日付降順に表示したい場合
- 昇順は`reverse()`を取ればよい
```
#!/bin/sh

aws ec2 describe-images \
 --owners self \
 --query 'reverse(sort_by(Images[*].{id:ImageId,date:CreationDate},&date))' \
 --output json
 ```

 ## 日付降順に表示したい場合２
 - 直近の5世代のみを表示する
 ```
#!/bin/sh

aws ec2 describe-images --owners self \
--query 'reverse(sort_by(Images,&CreationDate))[:5].{id:ImageId}' 
```

## インスタンス名でフィルターする
```
aws ec2 describe-instances --filter Name=tag:Name,Values=hogehoge
```

## インスタンス名からインスタンスIDと状態を取得する
```
aws ec2 describe-instances --filter Name=tag:Name,Values=hogehoge --query 'Reservations[*].Instances[*].{id:InstanceId,state:State.Name}'
```
