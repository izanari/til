# S3 
## Data Consistency モデル
- データの更新・削除には結果整合性が採用されている
  - 新規登録(New PUTs)
    - Consistency Read
      - 登録後、即時データが参照できる
  - 更新(Overwrite PUTs)
    - Eventual Consistency Read(結果整合性)
      - 更新直後は、以前のデータが参照される可能性がある
  - 削除(DELETE)
    - Eventual Consistency Read(結果整合性)
      - 削除直後は、削除前のデータが参照される可能性がある
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
      - [Amazon S3 で管理された暗号化キーによるサーバー側の暗号化 (SSE-S3) を使用したデータの保護](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/UsingServerSideEncryption.html)
      - REST APIでアップロードするには
        - `x-amz-server-side-encryption`
          - `AES256`とする

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
      - [AWS KMS に保存されたキー (SSE-KMS) でサーバー側の暗号化を使用してデータを保護する](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/UsingKMSEncryption.html)
      - REST APIでアップロードするには以下のヘッダーを付与する必要がある
        - `x-amz-server-side​-encryption`
          - `aws：kms`を指定する
        - x-amz-server-side-encryption-aws-kms-key-id
          - 省略可能。省略した場合はデフォルトのkeyが使用される
        - x-amz-server-side-encryption-context

    - SSE-C
      - ユーザーが提供した鍵を利用して暗号化
        - カスタムキーストア（CloudHSM)が必要
      - [お客様が用意した暗号化キーによるサーバー側の暗号化 (SSE-C) を使用したデータの保護](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/ServerSideEncryptionCustomerKeys.html)
      - REST APIでアップロードするには以下のヘッダーを付与する必要がある
        - `x-amz-server-side​-encryption​-customer-algorithm`
          - 暗号化アルゴリズムを指定するには、このヘッダーを使用します。ヘッダーの値は "AES256" である必要があります。 
        - `x-amz-server-side​-encryption​-customer-key` 
          - Amazon S3 でデータを暗号化または復号するために使用する base64 でエンコードされた 256 ビットの暗号化キーを指定するには、このヘッダーを使用します。 
        - `x-amz-server-side​-encryption​-customer-key-MD5`
          - RFC 1321 に従って、暗号化キーの base64 エンコードされた 128 ビット MD5 ダイジェストを指定するには、このヘッダーを使用します。Amazon S3 では、このヘッダーを使用してメッセージの整合性を調べて、送信された暗号化キーにエラーがないことが確認されます。
      - Amazon S3 コンソールを使用してオブジェクトをアップロードし、SSE-C をリクエストすることはできません。また、コンソールを使用して、SSE-C を使用して保存されている既存のオブジェクトを更新すること (ストレージクラスの変更やメタデータの追加など) もできません。 
      - http接続を拒否することができる
  
- クライアントサイド暗号化
    - 暗号化プロセスはユーザー側で管理する
    - クライアント側で暗号化したデータをS3へアップロードする
    - 暗号化種別
      - AWS KMSで管理されたカスタマーキーを利用して暗号化
      - クライアントが管理するカスタマーキーを利用して暗号化
- https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutObject.html#RESTObjectPUT-responses-examples
- https://aws.amazon.com/jp/blogs/security/how-to-prevent-uploads-of-unencrypted-objects-to-amazon-s3/
### 参考URL
- [サーバー側の暗号化を使用したデータの保護](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/serv-side-encryption.html)

## クロスリージョンレプリケーションを有効にする
- ソースバケットと宛先バケットでバージョン管理が有効になっている必要があります。
- Amazon S3には、ユーザーに代わってそのソースバケットから宛先バケットにオブジェクトを複製するアクセス許可が必要です。
- [レプリケーション](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/replication.html)


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

## トラブルシューティング
- [Amazon S3 から HTTP 307 Temporary Redirect レスポンスが返るのはなぜですか?](https://aws.amazon.com/jp/premiumsupport/knowledge-center/s3-http-307-response/)
## その他
### s3syncをはやくする
- [AWS CLI S3 Configurationを試したら想定以上にaws s3 syncが速くなった話](https://dev.classmethod.jp/cloud/aws/aws-s3-sync-with-aws-cli-s3-configuration/)

# Galcier
## タイプ
- Standard
  - 数時間以内にアーカイブにアクセスできます。通常、標準的な取得は3〜5時間以内に完了します。これがデフォルトのオプションです。
- Bulk Retriebal
  - Glacierの最も低コストの検索オプションであり、1日で大量（ペタバイト単位）のデータを安価に取得できます。通常、一括取得は5〜12時間以内に完了します。
- Expedited Retrieval
  - 迅速な取得により、アーカイブのサブセットに対する緊急の要求がときどき必要になる場合に、データにすばやくアクセスできます。迅速な取得は通常、1〜5分以内に利用可能になります。