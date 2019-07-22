# AWS CLI
## 参考サイト
- [AWS CLIのフィルターとクエリーの使い方についてまとめてみた](https://dev.classmethod.jp/cloud/aws/aws-cli-filter-and-query-howto/)
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