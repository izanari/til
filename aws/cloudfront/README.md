# CloudFront
## ヘッダー
- S3をBehaiviorを指定した場合、セキュリティのヘッダーはつけてくれません。それをする場合は、以下のURLを参照しましょう
  - [Adding HTTP Security Headers Using Lambda@Edge and Amazon CloudFront](https://aws.amazon.com/jp/blogs/networking-and-content-delivery/adding-http-security-headers-using-lambdaedge-and-amazon-cloudfront/)
### カスタムオリジンの場合
- https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorCustomOrigin.html
### S3オリジンの場合
- https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorS3Origin.html

## キャッシュ
### 時間のコントロール
- クライアント（PC）側のキャッシュ時間を短くし、CloudFront側のキャッシュ時間を長め（オリジンに負担をかけない）にしたい場合
  - `Cache-Control: public; max-age:300`とし、CloudFrontの最小TTLを`86400`というようにする
  
## 参考ドキュメント
- [CloudFrontのデフォルトルートオブジェクトとS3の静的ウェブサイトホスティングのインデックスドキュメントの動作の違い](https://dev.classmethod.jp/cloud/aws/cloudfront_s3_difference/)

## ログ
### S3バケットに保存する
- [ロギングの設定およびログファイルへのアクセスに必要なアクセス許可](https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership)
- バケットポリシーではなく、アクセスコントロールリストを使う
- `c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0`