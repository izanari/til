# S3 
## リダイレクトするには
### オブジェクトにリダイレクトルールを設定する
```
aws s3api put-object --bucket mybucket --key index.html --website-redirect-location "https://hogehoge/fugafuga/"
```
  - CloudFrontで`S3-Origin`で指定をした場合
    - HTTPヘッダーには、`x-amz-website-redirect-location: https://hogehoge/fugafuga/` が付与されているがブラウザはそれを解釈できないのでリダイレクトできない。
  - CloudFrontでカスタムオリジンでS3のウェブサイトホスティングのエンドポイントを指定した場合
    - HTTPヘッダーには、`location: https://hogehoge/fugafuga/`が付与され、リダイレクトされる。

### ウェブサイトホスティングのリライトルールを設定する
- ルールはオブジェクトに設定したルールよりも優先される
- どんなアクセスでもリライトする設定
```
<RoutingRules>
  <RoutingRule>
    <Redirect>
      <Protocol>https</Protocol>
      <HostName>www.github.com</HostName>
      <ReplaceKeyWith>hoge/fugafuga/</ReplaceKeyWith>
    </Redirect>
  </RoutingRule>
</RoutingRules>

```


## アクセスコントロール
### バケットポリシー
- ウェブサイトホスティングのリライトルールだけでよいならバケットポリシーの設定は不要
- CloudFrontからアクセスさせたい場合はユーザーエージェントが妥当か
```
{
    "Version": "2012-10-17",
    "Id": "Policy20190314-01",
    "Statement": [
        {
            "Sid": "Stmt20190314-01",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::hogehoge/*",
                "arn:aws:s3:::hogehoge"
            ],
            "Condition": {
                "StringEqualsIgnoreCase": {
                    "aws:UserAgent": "Amazon CloudFront"
                }
            }
        }
    ]
}

```

### 参考サイト
- [S3のアクセスコントロールまとめ](https://qiita.com/ryo0301/items/791c0a666feeea0a704c)
