# Route53
## エイリアスレコード
- [エイリアスレコードと非エイリアスレコードの選択](https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html)
- [エイリアスレコードの値](https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html#rrsets-values-alias-alias-target)
- [Amazon Route 53のALIASレコード利用のススメ](https://dev.classmethod.jp/cloud/aws/amazon-route-53-alias-records/)

### S3のウェブサイトホスティングを使用し、独自ドメインで公開する場合
1. バケットを作成する。この時のバケット名は、設定するレコード名と一致させること
2. S3のウェブサイトホスティングを有効にする
3. 少し待つ。すぐには反映されない。
4. Route53のコンソールから、タイプ：Aレコード、エイリアス：はいを選択する
   1. エイリアス先は選択肢から選択する