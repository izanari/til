# S3をウェブコンテンツのバケットとして使用する
- 方法は2種類あります
  - オリジンアクセスアイデンティティを使う
    - [オリジンアクセスアイデンティティを使用して Amazon S3 コンテンツへのアクセスを制限する](https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
  - 静的ウェブサイトを使う
    - [Amazon S3 での静的ウェブサイトのホスティング](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/WebsiteHosting.html)
 

## オリジンアクセスアイデンティティを使った場合
### できること
- アクセスをCloudFrontからのみの設定を行うこと
  - OAIを使う

### できないこと（難しいこと）
- リダイレクトの設定
- インデックスドキュメントの設定
  - どちらもLamda@edgeと絡める必要がある
    - [できた！S3 オリジンへの直接アクセス制限と、インデックスドキュメント機能を共存させる方法](https://dev.classmethod.jp/articles/directory-indexes-in-s3-origin-backed-cloudfront/)

## 静的ウェブサイトを使った場合
- [Amazon S3 + Amazon CloudFrontでWebサイトを構築する際にS3静的Webサイトホスティングを採用する理由](https://dev.classmethod.jp/articles/cloudfront-with-s3-hosting/)
### できること
- インデックスドキュメントの設定
- リダイレクトの設定
  - [(オプション) ウェブページリダイレクトの設定](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/how-to-page-redirect.html)
    - オブジェクトのプロパティに設定する方法
    - ルーティングルールを設定する方法
- エラードキュメントをカスタムする
  - [(オプション) カスタムエラードキュメントの設定](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/CustomErrorDocSupport.html)
### できないこと（難しいこと）
- アクセス元の制限をかけること
  - CloudFrontからのみのアクセスのみを許可する場合は難しい 
    - バケットポリシーで、CloudFrontのみからのアクセスを許可するか？

## その他の使い方など
## 注意点
- CloudFrontにもデフォルトドキュメントを設定できるが、ルート(/)しか設定することができない。
## Lambda@Edgeを使う
- [Lambda@Edge を使用したエッジでのコンテンツのカスタマイズ](https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html)
- [5分で読む！Lambda@Edge 設計のベストプラクティス](https://dev.classmethod.jp/articles/lambda-edge-design-best-practices/)