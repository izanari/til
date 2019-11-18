# Amazon Simple Queue Service (SQS)
スケーラビリティが備わったフルマネージドな分散メッセージキュー

## 参照サイト
- [ドキュメント](https://docs.aws.amazon.com/sqs/index.html)
- [Black Belt Online](https://www.slideshare.net/AmazonWebServicesJapan/20190717-aws-black-belt-online-seminar-amazon-simple-queue-service)

## 用語
- プロデューサ
  - キューにメッセージを送信するアプリケーション
- コンシューマ
  - キューのメッセージを取得するアプリケーション
## 料金
- 標準(スタンダード)キュー 
  - 100万件あたり0.4$
- FIFOキュー
  - 100万件あたり0.5$
- 仮に10億キューだったとした場合、標準キュー400$=約4.5万円、FIFOキュー500$=約5.5万円となる。これだけメッセージを送るシステムなら、どちらでもよいかと思われる。どちらを採用するかは、パフォーマンスを取るか、順序性が必要かの選択になる。
- データ転送量は別途かかります

## スタンダードキューとFIFOキューの違い

-- | スタンダード | FIFO
---|------------|------
スループット|ほぼ無制限|1秒あたり300件のメッセージ
配信方式|少なくとも1回の配信（２回以上の配信もあり得る|1回のみ配信
配信順序|ベストエフォート（変更あり）| 順序性を保つ


## キューの設定
- キューの名称
  - FIFOの場合は`.fifo`をsuffixをつかてください
    - URLを見れば、FIFOやスタンダードキューなのかが識別することができます
- キューの属性
  - デフォルトの可視性タイムアウト`(VisibilityTimeout)`
    - 0秒から12時間(43,200s)
    - 他のコンシューマから同一メッセージへのアクセスをブロックする機能
    - アプリケーションがメッセージを処理して、削除するのにかかる時間によって異なる。削除までの最大時間を設定する。大きすぎると再処理が遅延する。
      - 不明な場合はハートビートを作成し、タイムアウトを延長し続けるようなアプリとする
    - 遅延キューやメッセージタイマーの時間は含まない。あくまでも、受信してからの時間のこと
  - メッセージ保持期間`(MessageRetentionPeriod)`
    - 1分から14日（1,209,600s）
    - メッセージが削除されない場合、SQSが保持する期間
  - 最大メッセージサイズ`(MaximumMessageSize)`
    - 1〜256KB（1,024〜262,144byte)
    - SQSが受け付ける最大メッセージサイズ
  - 配信遅延（遅延キュー）`(DelaySeconds)`
    - 0〜15分（0〜900s）
    - キューに追加されたメッセージの初回配信遅延時間。メッセージがキューに入ってから指定された時間はコンシューマに表示されなくなる。
  - メッセージ受信待機時間`(ReceiveMessageWaitTimeSeconds)`
    - 0〜20秒
    - ロングポーリング受信呼び出しが空の応答を返すまでに、メッセージが利用可能になるまで待機する最大時間です。
- デッドレターキュー設定
  - 最大受信数
    - DLQに送信されるまでに受信できるメッセージ回数
    - 1〜1000
    - RedrivePolicy
      - `deadLetterTargetArn` : DLQのarn
      - `maxReceiveCount` : メッセージを受信できる最大数
      
- サーバ側の暗号化(SSE)の設定
  - AWS KMS カスタマーマスターキー (CMK)(`KmsMasterKeyId`)
    - エイリアスが使える
  - データキー再利用期間(`KmsDataKeyReusePeriodSeconds`)
### 遅延キューとメッセージタイマー
- メッセージタイマーは個々のメッセージに対して設定する初期非表示期間のこと。
- 遅延キューは、キュー全体に有効になる。
- メッセージタイマーのほうが優先されます。
- メッセージタイマーの設定方法
- スタンダードキューの場合は、キューごとの遅延設定はありません。設定を変更しても、既にキューにあるメッセージには影響しない。
- [Amazon SQS 遅延キュー](https://docs.aws.amazon.com/ja_jp/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-delay-queues.html)
  ```
  aws sqs send-message --queue-url <value> --message-body <value> --delay-seconds <value>
  ```
- 遅延キューの設定方法
  ```
  aws sqs create-queue --queue-name <value>
  --attributes DelaySeconds=10
  ```

## ショートポーリングとロングポーリング
- 通常はロングポーリングを使用する
  
-- | ショートポーリング | ロングポーリング
-- | --------------- | -------------
応答方式| 即応答。メッセージが無い場合は空を応答 | 最大20秒メッセージの受領を待つ。メッセージが無い場合はタイムアウト。その場合は空を応答
取得メッセージ | 分散されたサーバからサンプリングされたサーバのメッセージを応答。取得できないこともある。| 全てのサーバをクエリしメッセージを応答
利用料金 | 繰り返しショートポーリングを実施する場合APIコール数が増え利用料金が増加する可能性がある| ショートポーリングに比べAPIコール数が抑制できるため利用料金が安価になる可能性あり
利用シーン | 複数のキューを１つのスレッドでポーリングするケース | 複数のキューをポーリングする必要がないケース

-  デフォルトではショートポーリングでキューが作成される
-  ロングポーリングにするには、`メッセージ受信待機時間(ReceiveMessageWaitTimeSeconds)`を1以上の値にする
-  ロングポーリングを採用する場合、タイムアウトまでの時間を考慮する必要がある。
   -  可視性タイムアウトは、ロングポーリングのタイムアウト時間＋メッセージの処理時間＋メッセージの削除時間を合算した時間をセットする必要がある

## Dead Letter Queue(DLQ)
- 最大受信数を超えたらメッセージをDLQに移動させることができる
- DLQにアラームを設定することで検知可能
- FIFOのDLQはFIFO、スタンダードのDLQはスタンダードのキューを指定する必要がある
- ソースキューとDLQは、同一リージョンに存在する必要がある
- DLQに移動しても、メッセージのタイムスタンプは変わらない
  - 元のキューで1日経過して、DLQのMessageRetentionPeriodが3日の場合、2日後にDLQからも削除される
    - MessageRetentionPeriodは、ソースキューの時間より長い時間を設定する必要がある。

## 暗号化
- キュー内に保存されたメッセージを暗号化する
- キューへのアクセス権とAWS KMS鍵へのアクセス権が必要

## メタ情報の格納
- 本文とは別にメタデータを保持させることができる。ただし、容量は上限の256KBに含まれる
- 最大10個
- サーバーサイド暗号化の対象ではない

## その他、設計時に考慮すること
- 冪等性を確保すること
  - 冪等性とは1回でも複数回の実行でも結果が変わらない特性
    - DynamoDB等で処理済であることを判定できる仕組にする
- 1.ポーリング→2.取得&処理→3.削除とすること。自動で削除はされない。

## キューのモニタリング
- スタンダードキューの場合、結果は概算。FIFOキューの場合は厳密な値。

メトリクス | 説明
---------|---------
ApproximateAgeOfOldestMessage | キューで最も古い削除されていないメッセージのおおよその経過期間。
ApproximateNumberOfMessagesDelayed | 遅延が発生したため、すぐに読み取ることのできない、キューのメッセージ数。遅延キューやメッセージタイマー指定時した時のみ
ApproximateNumberOfMessagesNotVisible | 処理中のメッセージ数。削除されていない、可視性タイムアウトに達していない場合のメッセージ数。
ApproximateNumberOfMessagesVisible | キューから取得可能なメッセージ数
NumberOfEmptyReceives | メッセージを返さなかったReceiveMessage API呼び出し数
NumberOfMessagesDeleted | キューから削除されたメッセージの数
NumberOfMessagesReceived | ReceiveMessage アクセスへの呼び出しで返されたメッセージの数
NumberOfMessagesSent | キューに追加されたメッセージの数
SentMessageSize | キューに追加されたメッセージのサイズ（バイト数）

- ApproximateNumberOfMessagesVisibleが増えていっている時は、コンシューマをスケールアウトする必要があるといえる

## 実行例
- メッセージの送信
  - 複数のメッセージを送信したい場合は、`send-message-batch`を使う
  ```
  aws sqs send-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/accountid/test \
  --message-body "あいうえお\nかきくけこ" \
  --output json

  {
      "MD5OfMessageBody": "ff228862c350882af0f28aaacccxxx",
      "MessageId": "d23dd18d-qqqq-4d7b-96b6-4a2fa36902f1"
  }
  ```
- メッセージの取得
  - 一度のAPIでは1つのメッセージしか取得できない
  ```
  aws sqs receive-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/accountid/test \
  --output json
  {
      "Messages": [
          {
              "MessageId": "143f8cb0-e5eb-xxxx-aa82-xxxxxxxxx",
              "ReceiptHandle": "AQEBVrM7Wn2KXKUnc0C/QijF1YH2bb6cJB/pwq8NBQQYU6GTd2Sio571yJEIbJbr32pw2vePcfboV5NyZDRdN+mIalp6I0p4C6hab8RkSQND+ali4d1/+ZaEhZsufQlTxxxxxxxudD8AbDgLUcuQQ38nVPKnk31k32nhutmZEun6i+V4KWy78fESEQeDtSGy2XuqKjp55GyGIYgQEW1LfDrEf1oZJkg4y33ahS/MLGyua4fQM3s+hJD0t+ThrLHMxDAB3Log0eIm74d6Xj7bJLz/oaC5bZAqF8aIFVuvTuGy23Rhv6eHwqAlf/xxxxxx/oA==",
              "MD5OfBody": "ff228879c4b62c350882af0f28cc6714",
              "Body": "あいうえお\\nかきくけこ"
          }
      ]
  }
  ```
- 削除
  ```
  aws sqs delete-message \
  --queue-url https://sqs.ap-northeast-1.amazonaws.com/accountid/test \
  --receipt-handle xxxxxxxxxxxxxxxxxxxxxx

  レスポンスは無い(削除ができたことをどうやって確認するのか？？)
  ```
- キューの属性を取得する
  ```
    aws sqs get-queue-attributes --profile fork_y.izawa --queue-url https://sqs.ap-northeast-1.amazonaws.com/accountid/test --attribute-names All --output json
  {
      "Attributes": {
          "QueueArn": "arn:aws:sqs:ap-northeast-1:accountid:test",
          "ApproximateNumberOfMessages": "0",
          "ApproximateNumberOfMessagesNotVisible": "0",
          "ApproximateNumberOfMessagesDelayed": "0",
          "CreatedTimestamp": "1564117040",
          "LastModifiedTimestamp": "1564117040",
          "VisibilityTimeout": "30",
          "MaximumMessageSize": "262144",
          "MessageRetentionPeriod": "345600",
          "DelaySeconds": "0",
          "ReceiveMessageWaitTimeSeconds": "20",
          "KmsMasterKeyId": "alias/aws/sqs",
          "KmsDataKeyReusePeriodSeconds": "300"
      }
  }
  ```

## 構成例
### プロデューサー → SQS → Lambda
  - lambdaのイベントソースにSQSを指定することができます。Lambdaが自動起動します。
  - ただし、標準キューのみで、FIFOキューには対応していません
  - 参考サイト
    -  [AWS Lambda を Amazon SQS に使用する](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/with-sqs.html)
    - [AWS LambdaがSQSをイベントソースとしてサポートしました！](https://dev.classmethod.jp/etc/aws-lambda-support-sqs-event-source/)
  - この構成の場合、ReceiveMessageやDeleteMessageを実行する必要は無い。では、どういう時にMessageが残ってしまうのか？
    - → Exceptionをスローした時には、不可視メッセージとして残っていた。Lambdaが正常に終了した時のみdelete-messageしていると思われる。
    - 処理が複雑な場合は自分でdelete-messageしたほうがよいかもしれない
      - まだ検証できていない
      - ドキュメントには以下のように記載されている
        ```
        Lambda はキューをポーリングして、キューメッセージを含むイベントで関数を同期的に呼び出します。Lambda はメッセージをバッチで読み取り、バッチごとに関数を呼び出します。関数が正常にバッチを処理すると、Lambda はキューからそのメッセージを削除します。
        ```
  - maxReceiveCountを5以上にしておく必要がある。
  - 不可視時間をLambdaの時間の6倍にしておいたほうがよい。


## コスト削減
### メッセージアクションのバッチ処理
- 1つのアクションで複数のメッセージの可視性タイムアウトを変更するには、バッチAPIアクションを使用します
- 空のキューでの空の受信数を減らすにはロングポーリングを有効にする
  

## FIFOキューにおける推奨事項
https://docs.aws.amazon.com/ja_jp/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-additional-fifo-queue-recommendations.html