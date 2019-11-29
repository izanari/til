# DynamoDB
- データは3箇所のAZに保存されるため信頼性が高い
- ストレージは自動的にパーティショニングされる
- ストレージの容量制限がない
- キャパシティモードは２つある
  - プロビジョンド
    - Auto Scalingも可能
  - オンデマンド
    - Auto Scalingは選択できない

## 参考ドキュメント
- [コンセプトから学ぶAmazon DynamoDB – シリーズ –](https://dev.classmethod.jp/series/conceptual-learning-about-dynamodb/)
- [DynamoDB – 特集カテゴリー ](https://dev.classmethod.jp/referencecat/aws-dynamodb/)
- [DynamoDB のベストプラクティス](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/best-practices.html)

## 料金
### プロビジョンドされたキャパシティの場合
- Read/Writeそれぞれ25キャパシティユニットまでは無料
- 書き込み
  - $0.00742 10ユニットの書き込み容量あたり/1時間
- 読み込み
  - $0.00742 50ユニットの読み込み容量あたり/1時間
#### リザーブドキャパシティ
- リザーブドインスタンスと同じで、かなり安価になる
### オンデマンドキャパシティの場合
- 書き込みリクエスト
  - 100万単位あたり：1.4269USD
- 読み込みリクエスト
  - 100万単位あたり：0.285USD

## キャパシティの決め方
- プロビジョンドとオンデマンドがある
- オンデマンドならキャパシティを考える必要がない
- GSIは別に設定する必要がある。ベーステーブルの設定は使わない。 
  - ベーステーブルのWCU < GSIのWCU となるようにする
### キャパシティユニット
- 書き込み
  - 1ユニット: 最大1KBのデータを1秒に1回書き込み可能
- 読み込み
  - 1ユニット：最大4KBのデータを1秒に1回読み込み可能
    - 強い一貫性を持たない読み込みであれば1秒あたり2回
### プロビジョンドスループット
- https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/ProvisionedThroughput.html#ItemSizeCalculations.Writes
- https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html
- テーブル毎にReadとWriteのそれぞれに対し、必要な分だけのスループットキャパシティを割り当てる
  - Read:1000 , Write:100
  - この値はDB運用中にオンラインで変更することができる
  - ただし、スケールダウンは1日9回までしかできない

- Read Capacity Units(RCU)
  - 1RCUは、最大4KBの項目について、1回の強力な整合性のある読み込みリクエストを処理できる。また、2回の結果整合性のある読み込みを処理できる。トランザクション読み込みリクエストの場合、4KBまでの項目を1回読み込みためには2RCU必要である
  - 結果整合性のある読み込み(4KBまで)
    - 1秒あたり1回ごとに0.5RCU
  - 強力な整合性のある読み込み(4KBまで)
    - 1秒あたり1回ごとに1RCU
  - トランザクション読み込み(4KBまで)
    - 1秒あたり1回ごとに2RCU
  - 1秒あたりの読み込み項目数x項目のサイズ(4KBブロック)
  - 結果整合性のある読み込みをする場合はスループットが２倍
  - 1秒あたりのサイズを求めて（切り上げする）から計算すること
    - 例１ 強力な読み込み
      - アイテムサイズ1.2KB→1.2/4=0.3→1に繰り上げ
      - 読み込み項目数1000回/秒
      - 1000x1=1000 RCU
    - 例２
      - アイテムサイズ4.5KB→4.5/4=1.1→2に繰り上げ
      - 読み込み項目数1000回/秒
      - 1000x2=2000 RCU
      - 結果整合性のある読み込みの場合→1000x2x1/2=1000 RCU
    - 10RCU設定されていて、1アイテム4KBの場合
      - 10RCU x 4KB = 40
      - 40 / 4KB = 10 リクエスト（強い整合性）
      - 40 / 2KB = 20 リクエスト（結果整合性）
- Write Capacity Unit
  - 1WCUは、サイズが1KBまでの項目を1回書き込みできる
  - サイズが1KBまでの項目をトランザクション書き込みの場合は、2WCU
    - 項目のサイズが2KBの場合1回の書き込みには2WCUが必要となる。
  - 1秒あたりの書き込み項目数x項目のサイズ
    - 例１
      - アイテムサイズ512B→0.512/1=0.5→1に繰り上げ
      - 書き込み項目数 1000項目数/秒
        - 1000 x1 = 1000 WCU
    - 例2
      - アイテムサイズ2.5KB→2.5/1=2.5→3に繰り上げ
      - 書き込み項目数1000項目数/秒
        - 1000 x3 = 3000 WCU
  - スループットはパーティションに均等に付与される
    - アクセスされるキーに偏りが発生すると、思うような性能が出ない場合がある。よって、Partation Keyの設計には注意が必要である
- キャパシティを減らすときはパーティション数は減らさずに各パーテションのキャパシティが減るので注意
  - ひとつひとつのパーティションのキャパシティが低い状態になる。結果としてキャパシティエラーを起こしやすい状態になる
- Burst Capacity
  - パーティションごとのキャパシティのうち、利用されなかった分を過去300秒分までリサーブされる。プロビジョン分を超えたバーストトラフィックを処理するために利用する
- `ReturnConsumedCapacity`
  - 消費したキャパシティを知りたい時は、ReturnConsumedCapacityパラメータを付与する。デフォルトはNONEになっているため、返ってこない
  - [クエリで消費されるキャパシティーユニット](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Query.html#Query.CapacityUnits)
    - INDEXES
      - レスポンスは、アクセスする各テーブルとインデックスの消費されるキャパシティーとともに、消費される読み込みキャパシティーユニットの合計値を示します。
      - put-itemした時の表示
        ```
          {
            "ConsumedCapacity": {
                "TableName": "Person",
                "CapacityUnits": 2.0,
                "Table": {
                    "CapacityUnits": 1.0
                },
                "GlobalSecondaryIndexes": {
                    "Person-Name-index": {
                        "CapacityUnits": 1.0
                    }
                }
            }
          }
        ```
    - TOTAL
      - レスポンスには消費された読み込みキャパシティーユニットの合計値が含まれます。
        ```
          {
            "ConsumedCapacity": {
                "TableName": "Person",
                "CapacityUnits": 2.0
            }
          }
        ``` 
    - NONE
      - デフォルト値

## 整合性モデル
- Write
  - 少なくとも2つのAZで書き込み完了となった時点でAckがある
- Read
  - デフォルトは結果整合性読み込みである
  - 最新の書き込み結果が即時読み取り処理に反映されない可能性がある
  - Consistent Readオプションをつけたリクエスト
    - GetItem/Query/Scanでは強力な整合性のある読み込みオプションを指定することができる
    - Readリクエストを受け取る前までのWriteが全て反映されたレスポンスを保証する
    - Capacity Unitを2倍消費する
    - aws dynamodb get-item `--consistent-read`
  - グローバルセカンダリインデックス (GSI)で「強力な整合性のある読み込み」が利用できない


## テーブルについて
- テーブルにはプライマリーキーを設定する。
- プライマリーキーは１つの属性（パーティションキー）または２つの属性（パーティションキー+ソートキー）で構成される。
- パーティションキーの値は内部ハッシュ関数への入力として使われる。パーティションキーのみのテーブルには、同じキー値を持つ項目は作れない
- プライマリーキーに指定できる属性型は、文字列、数値、バイナリのどれかです
### Partation Table（ハッシュキーテーブル）
- Partation Keyは順序を指定しないハッシュインデックスを構築するためのキー
- テーブルは性能を確保するために分割される場合がある
- GetItem（キーを指定した0〜1件のみ取得）もしくは、Scan(全件返ってくる)しかできない
### Partation-Sort Table（複合テーブル）
- プライマリー+ソートキーがプライマリーキーのテーブル
- 同一のPartation Keyでのデータの並びを保証するためにSort Keyが使われる
- Partation Keyの数に上限は無い
  - Local Secondary Indexesを使用時はデータサイズに上限あり
- GetItemではhashとsortキーを指定して(=)0〜1件取得する
- Queryでは、hash(=)、sort(範囲条件)を指定して、0〜複数件取得する

### テーブル操作について
- GetItem
  - Partation Keyを条件として1件のアイテムを取得する
- PutItem
  - 1件のアイテムを書き込む
- Update
  - 1件のアイテムを更新する
- Delete
  - 1件のアイテムを削除する
- Query
  - Partitaion KeyとSort Keyの複合条件にマッチするアイテム群を取得する
- BatchGet
  - 複数のプライマリキーを指定してマッチするアイテム群を取得する
- Scan
  - テーブルを総ナメする
- ★Query/Scanで最大1MBのデータを取得可能
### 高度なテーブル操作
- Conditional Write
  - キーにマッチするレコードが存在したら/しなかったら
  - この値がxx以上/以下だったらという条件付き書き込み/更新ができる
- Filter式による結果の絞り込み
  - QueryまたはScanでは必要に応じてフィルタ式を指定して、返された結果を絞り込みことができる
  - Query,Scanの1MBの制限はフィルタ式の適用前に適用される。また消費されるキャパシティユニットもフィルタ式を指定しなくても同じ
- UpdateItemにおけるAttributeへの操作
  - Attributeに対して、UpdateItemでPut,Add,Deleteという３種類の操作が可能
    - Put:Attributeを指定した値で更新
    - Add:AttributeがNumber型なら足し算、引き算、Set型ならそのセットに対して値を追加する
    - Delete:当該Attributeを削除する
#### プロジェクション式
- 一部の属性のみを取得するにはプロジェクション式を利用する
```
aws dynamodb get-item --table-name HogeTable --key fugafuga --projection-expression "Zip,Address1,Address2"
```

## テーブル設計
- Partitaion Keyは必須
- Sort Keyは任意
  - 型は文字列、数値、バイナリでなければならない
- プライマリーキーは、Partitaion Keyのこと。または、Partitaion Key+Sort Keyのことです
- Attributesの型
  - String(S)
  - Number(N)
  - Binary
  - Boolean(BOOL)
  - Null(NULL)
  - 多値データ型(Object→M)
    - Set Of String
    - Set Of Number
    - Set Of Binary
  - ドキュメントデータ型
    - List型：順序付きの値コレクションを含む
    - Map型：順序なしの名前と値のペアのコレクションを含む

### サイズ
- テーブルには任意の数のアイテムが追加可能
  - １つのアイテムは400KB
  - local secondary indexについて、異なるハッシュキーの値ごとに最大10GBのデータを格納
### パーティション
  - パーティションの数はDynamoDBがマネージするので、ユーザーは気にする必要はないし、知る方法が無い。しかし、その特性を理解しておくことでより便利にDynamoDBを活用することができる


### セカンダリインデックス
- 20グローバルインデックスと5ローカルインデックスに制限されている
- 一般的にグローバルセカンダリインデックスを使用する
#### Local Secondary Index (LSI)
- Sort key以外に絞り込み検索を行うkeyを持つことができる
- Partation keyが同一で、他のアイテムからの検索のために利用
- すべての要素（テーブルとインデックス）の合計サイズを各ハッシュキーごとに10GBに制限
- ハッシュキーのみの設定ができない。複合キーのみ設定が可能。
- **ハッシュキーはそのテーブルと同じキーしか設定ができない**
- レンジキーは別の属性を指定することができる
- テーブル作成時にしか設定できない
#### Global Secondary Index (GSI)
- Partation Key属性の代わりになる
- Partation Keyをまたいで検索をするためのインデックス
- テーブルとは独立したスループットをプロビジョンして利用するため、十分なスループットが必要
- テーブルあたり最大5個だったが20個までに引き上げらた。更に必要な場合は上限緩和申請をする。
  - GSIへ射影できる属性が100まで可能になった
- GSI OVERLOADING
  - GSIの多重定義
  - １つのGSIで複数の用途で利用出来るように定義する
  - Overloadするattributeの値はitemのcontextが分かる値にする
- 作成してもすぐに完了にならない
- テーブル作成後でも設定することができる

  
#### 注意点
- LSI/GSIは便利だがスループットやストレージ容量が追加で必要になる
- インデックスが増えれば増えるほど書き込みコストが上がる
- セカンダリインデックスに強く依存するテーブル設計になるようであれば、一度RDBで要件を満たせないかを確認してすることがベター
- 強い整合性読み込みは、LSIのみ。GSIは結果整合性しかサポートしていない
- LSIはベーステーブルのCUを消費するが、GSIでは独自にプロビジョニングしたCUを消費する
##### 参考ドキュメント
- [GSI OVERLOADING について 自分なりにまとめてみた](https://dev.classmethod.jp/cloud/aws/basic-of-gsi-overloading/)
- [セカンダリインデックスを使用したデータアクセス性の向上](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/SecondaryIndexes.html)


## DynamoDBの機能
### TTL
- テーブルの項目の有効期限が切れ、データベースから自動的に削除できるタイミングを定義出来る
- プロビジョンされたスループットを使用することなく、関連例のないデータのストレージ使用量と保存コストを減らせる
- エポック形式含む数値データ型のみ
- 有効期限が切れても即削除・読み取りができなくなる訳じゃない
- 削除されるのに最大48時間かかることがある
- Queryを利用するか、フィルタ処理が必要となる
### Auto Scaling
- フルマネージドでWCU,RCU,GSIに対する設定を管理
- 設定はターゲット使用率と上限、下限を設定するだけでよい
- Auto Scalingが発動すると即座に容量が拡大する訳ではない
- 瞬発的なスパイクに対応するにはDAXに合わせてアーキテクチャを組む必要がある
- 下がる回数は１日９回まで
### グローバルテーブル
- グローバルテーブルは DynamoDB Streams を使用してレプリカ間の変更を伝播します。

## ベストプラクティス
- Time Series Tables
  - ホットデータとコールドデータは混在させない。アーカイブしたコールドデータはS3へ
- [DynamoDB のベストプラクティス](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB グローバルセカンダリインデックスを使用してクエリのパフォーマンスを向上させ、コストを削減する方法](https://aws.amazon.com/jp/blogs/news/how-to-use-dynamodb-global-secondary-indexes-to-improve-query-performance-and-reduce-costs/)

## データのバックアップ
- 静止点をとってバックアップするような機能は無い！
  - DynamoDB Streamsを用いたCross Region Replication
  - AWS Data Pipelineを使ったデータバックアップ
    - 別リージョン、同一リージョンのDynamoDBのテーブルに対してコピー、選択したAttributeのみコピー、選択したAttributeのみのIncrementakコピーのジョブを実行することが可能
  - Amazon MapRededuceを使ったコピー


# DAX
- リージョン内でマルチAZ構成かつキャッシュ情報のレプリケーション、障害時のフェイルオーバーなどをフルマネージドで実現してくれている
- 最大10ノードまでスケールアウトする
- VPCに配置する
- Java SDKのみの対応となっているようです


# DynamoDB Streams
- 過去24時間以内にそのテーブルのデータに対して行われた変更のストリームすべてにアクセス可能。24時間経過したストリームデータは削除される。
- 容量は自動的に管理される
- 操作された順番に沿ってシリアライズされる
- ハッシュキーが異なる場合は順番が異なる場合がある
- DynamoDB テーブルのWriteプロビジョニングスループットの最大2倍の速度でDynamoDB Streamsから更新を読み取ることが可能
- 使いどころ
  - クロスリージョンレプリケーション
  - ユーザーの集計、分析、解析のための非同期集計
  - ホットデータとコールドデータでテーブルを分ける
  - [DynamoDB ストリーム Kinesis Adapter を使用したストリームレコードの処理](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Streams.KCLAdapter.html)
## ストリームの表示タイプ
|表示タイプ|概要|
|---|---|
|キーのみ（KEYS_ONLY）|変更された項目のキー属性のみ|
|新しいイメージ（NEW_IMAGE）|変更後に表示される項目全体|
|古いイメージ（OLD_IMAGE）|変更前に表示されていた項目全体|
|新旧イメージ（NEW_AND_OLD_IMAGES）|項目の新しいイメージと古いイメージの両方|
## 設定について
- ストリームを有効にするとARNが生成される
- テーブルには1つのストリームしか設定はできない
## DynamoDB Streams API
- ListStrreams
- DescribeStream
- GetShadIterator
- GetRecords
## DynamoDB Triggers
- DynamoDB トリガーは、DynamoDB ストリームを Lambda 関数に接続します。テーブル内の項目が変更されるたびに、新しいストリームレコードが書き込まれ、その後 Lambda 関数がトリガーされて実行されます。
  - [DynamoDB ストリーム と AWS Lambda のトリガー](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Streams.Lambda.html)
### ユースケース
- DynamoDBへの書き込みに応じて値をチェックしつつ別テーブルの更新やプッシュ通知を実行
- DynamoDBの更新状況の監査ログをS3へ保存
- ゲームデータなどのランキング集計を非同期に実施
### 参考ドキュメント
- [DynamoDB ストリーム と AWS Lambda のトリガー](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Streams.Lambda.html)
- [Amazon DynamoDB Triggersを使ってDynamoDB StreamsとAWS Lambdaを連携する](https://dev.classmethod.jp/cloud/aws/dynamodb-streams-cooperates-with-lambda/)

### Lambdaで取得できるevent
- 2つのLambdaを設定しても動作はするようだ
#### 新休イメージを設定した場合
- `BarkTable`は、プライマリーキーに、`Username+Timestamp`を設定してあります
- 項目の追加をした場合
  - `eventName`が`INSERT`になっている
```
{'Records': [
  { 'eventID': 'eventid', 
    'eventName': 'INSERT', 
    'eventVersion': '1.1', 
    'eventSource': 'aws:dynamodb', 
    'awsRegion': 'ap-northeast-1', 
    'dynamodb': {'ApproximateCreationDateTime': 1564988394.0, 
    'Keys': {'Username': {'S': 'hogehoge'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 'NewImage': {'Email': {'S': 'hogehoge@gmail.com'}, 'Username': {'S': 'hogehoge'}, 'Sex': {'S': 'mail'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 
    'SequenceNumber': '12600000000000084089244', 
    'SizeBytes': 111, 
    'StreamViewType': 'NEW_AND_OLD_IMAGES'
  }, 
  'eventSourceARN': 'arn:aws:dynamodb:ap-northeast-1:accountid:table/BarkTable/stream/2019-08-05T06:38:17.212'}]
}
```
- 項目の更新
  - `eventName`が`MODIFY`になっている
```
{'Records': [
  { 'eventID': 'eventid', 
    'eventName': 'MODIFY', 
    'eventVersion': '1.1', 
    'eventSource': 'aws:dynamodb', 
    'awsRegion': 'ap-northeast-1', 
    'dynamodb': {'ApproximateCreationDateTime': 1564988734.0, 'Keys': {'Username': {'S': 'hogehoge'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 'NewImage': {'Email': {'S': 'hogehoge@gmail.com'}, 'Username': {'S': 'hogehoge'}, 'Sex': {'S': 'mail'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 'OldImage': {'Email': {'S': 'hogehoge@gmail.com'}, 'Username': {'S': 'hogehoge'}, 'Sex': {'S': 'mail'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 
    'SequenceNumber': '12700000000000084250113', 
    'SizeBytes': 182, 
    'StreamViewType': 'NEW_AND_OLD_IMAGES'}, 
    'eventSourceARN': 'arn:aws:dynamodb:ap-northeast-1:accountid:table/BarkTable/stream/2019-08-05T06:38:17.212'}]
}
```
- 項目の削除
  - `eventName`が`REMOVE`になっている
```
{
  'Records': [
    { 'eventID': 'eventid', 
      'eventName': 'REMOVE', 
      'eventVersion': '1.1', 
      'eventSource': 'aws:dynamodb', 
      'awsRegion': 'ap-northeast-1', 
      'dynamodb': {'ApproximateCreationDateTime': 1564989017.0, 'Keys': {'Username': {'S': 'hogehoge'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 'OldImage': {'Email': {'S': 'hogehoge@gmail.com'}, 'Username': {'S': 'hogehoge'}, 'Sex': {'S': 'mail'}, 'Timestamp': {'S': '2019-08-05 15:58'}}, 
      'SequenceNumber': '12800000000000084379557', 
      'SizeBytes': 112, 
      'StreamViewType': 'NEW_AND_OLD_IMAGES'}, 
      'eventSourceARN': 'arn:aws:dynamodb:ap-northeast-1:accountid:table/BarkTable/stream/2019-08-05T06:38:17.212'}]
}
```
### Lambda側の設定
- テーブル名
- バッチサイズ
  - 一度に読み取るレコードの最大数。最大1000。
  - 2以上設定した場合は、Lambda内でループさせる必要がある
- 開始位置
  - 最新：最新のものから順番に読み取る
    - 最新のデータを使用する設計なら
  - 水平トリム：読み取りされていないものを古い順から読み取る
    - 時間順に処理したい場合

### 必要なrole
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```
## その他
### アトミックカウンターを実装する
- RDSで`SQL AUTO_INCREMENT`を使わなくても実装することができます
- https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/WorkingWithItems.html#WorkingWithItems.AtomicCounters
```
aws dynamodb update-item \
 --table-name ProductCatalog \
 --key '{"Id": {"N": "601"}}' \
 --update-expression "SET Price = Price + :incr" \
 --expression-attribute-value '{":incr":{"N":"5"}}' \
 --return-values UPDATED_NEW
 ```

### optimistic（オプティミスティック） と pessimistic（ペシミスティック） concurency

- pessimistic concurency
  - データの競合が多い環境で使用されることが多い。行でロックし、ロック解除されるまで操作が実行できない
  - レコードが長時間ロックされる場合には向いていない
- optimisitic concurency
  - 行ロックしない
  - 行の読み取り後に別のユーザーがその行を変更したかどうかをアプリで確認する必要がある
- 参考
  - [オプティミスティック コンカレンシー](https://docs.microsoft.com/ja-jp/dotnet/framework/data/adonet/optimistic-concurrency)

### ページネーション
- page-size
  - アイテムの数には影響しないページサイズ
- max-items
  - アイテムの総数。指定された値を超える場合は、NextTokenが提供され、ページネーションを再開するにはMextToken値を指定します
    ```
    aws s3 api list-objects --bucket my-bucket --max-items 100 --starting-token aaaaaaaaaaa
    ```
### その他
- [自分のテーブルにはスロットリングがかけられていますが、消費したキャパシティーユニットはまだプロビジョンドキャパシティーユニットを下回っています。](https://aws.amazon.com/jp/premiumsupport/knowledge-center/throttled-ddb/)
- [書き込みシャーディングを使用してワークロードを均等に分散させる](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/bp-partition-key-sharding.html)