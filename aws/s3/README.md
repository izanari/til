# S3 
## 暗号化によるデータ保護
- サーバサイド暗号化
  - メタデータは暗号されない。オブジェクトデータのみが暗号化される
  - 暗号化種別
    - SSE-S3
      - AWSが管理する鍵を利用して暗号化
        - コンソール画面上では、AWSマネージ型キーと表示されている
      - AES-256を利用して暗号される
      ```
      aws s3 cp ./test.txt s3://yourbucket/ --sse
     
      (確認方法)
      aws s3api get-object --bucket yourbucket --key test.txt download-object
      {
        "AcceptRanges": "bytes", 
        "ContentType": "text/plain", 
        "LastModified": "Wed, 11 Sep 2019 06:04:13 GMT", 
        "ContentLength": 19, 
        "ETag": "\"xxxxxx\"", 
        "ServerSideEncryption": "AES256", 
        "Metadata": {}
      }
      ```

    - SSE-KMS
      - Key Managemtn Service(KMS)の鍵を利用して暗号化
        - カスタマー管理型のキーと表示されている
      - KMSで作成したキーを指定してAWSコマンドを実行します
      ```
      aws s3 cp test2.txt s3://yourbucket --sse-kms-key-id 111111111-2222-333-b66e-9c700cd608a3 --sse aws:kms
      （get-objectで確認すると）
        {
        "AcceptRanges": "bytes", 
        "ContentType": "text/plain", 
        "LastModified": "Wed, 11 Sep 2019 06:44:43 GMT", 
        "ContentLength": 27, 
        "ETag": "\"e1198a08d47ee2ecb0182aacea5753cc\"", 
        "ServerSideEncryption": "aws:kms", 
        "SSEKMSKeyId": "arn:aws:kms:ap-northeast-1:{accountid}:key/{keyのid}", 
        "Metadata": {}
        }
      ```

    - SSE-C
      - ユーザーが提供した鍵を利用して暗号化
        - カスタムキーストア（CloudHSM)が必要
- クライアントサイド暗号化
    - 暗号化プロセスはユーザー側で管理する
    - クライアント側で暗号化したデータをS3へアップロードする
    - 暗号化種別
      - AWS KMSで管理されたカスタマーキーを利用して暗号化
      - クライアントが管理するカスタマーキーを利用して暗号化
### 参考URL
- [サーバー側の暗号化を使用したデータの保護](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/serv-side-encryption.html)
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
- 使用できる演算子は、[IAM JSON ポリシーエレメント: 条件演算子](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) を参照
#### CloudFront経由のアクセスのみを許可する
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
#### 特定のIPからのアクセスのみを許可する
````
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
                "arn:aws:s3:::test.hogehoge.jp/*",
                "arn:aws:s3:::test.hogehoge.jp"
            ],
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "xx.xx.xx.xx/32",
                        "dd.dd.dd.dd/32
                    ]
                }
            }
        }
    ]
}

````

### 参考サイト
- [S3のアクセスコントロールまとめ](https://qiita.com/ryo0301/items/791c0a666feeea0a704c)

## メタヘッダーを追加する
- s3にputされたらlambdaをキックしてヘッダーを追加するようにする
  - [Lambda Function](./01_lambda_handler.py)

## マルチパートアップロード
- 通常、オブジェクトサイズが 100 MB 以上の場合は、単一のオペレーションでオブジェクトをアップロードする代わりに、マルチパートアップロードを使用することを考慮してください。
- マルチパートアップロードは 5 MB～5 TB のオブジェクトで使用できます。
- マルチパートアップロード API を使用すると、最大 5 TB の大容量オブジェクトをアップロードできます。
- 1 回の PUT オペレーションでアップロードできるオブジェクトの最大サイズは 5 GB です。


## その他
### s3syncをはやくする
- [AWS CLI S3 Configurationを試したら想定以上にaws s3 syncが速くなった話](https://dev.classmethod.jp/cloud/aws/aws-s3-sync-with-aws-cli-s3-configuration/)
