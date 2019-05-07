# CloudFront
## ヘッダー
- S3をBehaiviorを指定した場合、セキュリティのヘッダーはつけてくれません。それをする場合は、以下のURLを参照しましょう
  - [Adding HTTP Security Headers Using Lambda@Edge and Amazon CloudFront](https://aws.amazon.com/jp/blogs/networking-and-content-delivery/adding-http-security-headers-using-lambdaedge-and-amazon-cloudfront/)
### カスタムオリジンの場合
- https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorCustomOrigin.html
### S3オリジンの場合
- https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorS3Origin.html

- ちょっっと翻訳が怪しいな