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
### キャパシティユニット
- 書き込み
  - 1ユニット: 最大1KBのデータを1秒に1回書き込み可能
- 読み込み
  - 1ユニット：最大4KBのデータを1秒に1回読み込み可能
    - 強い一貫性を持たない読み込みであれば1秒あたり2回
### プロビジョンドスループット
- テーブル毎にReadとWriteのそれぞれに対し、必要な分だけのスループットキャパシティを割り当てる
  - Read:1000 , Write:100
  - この値はDB運用中にオンラインで変更することができる
  - ただし、スケールダウンは1日9回までしかできない
- Read Capacity Units(RCU)
  - 1秒あたりの読み込み項目数x項目のサイズ(4KBブロック)
  - 結果整合性のある読み込みをする場合はスループットが２倍
    - 例１
      - アイテムサイズ1.2KB→1.2/4=0.3→1に繰り上げ
      - 読み込み項目数1000回/秒
      - 1000x1=1000 RCU
    - 例２
      - アイテムサイズ4.5KB→4.5/4=1.1→2に繰り上げ
      - 読み込み項目数1000回/秒
      - 1000x2=2000 RCU
      - 結果整合性のある読み込みの場合→1000x2x1/2=1000 RCU
- Write Capacity Unit
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
- ハッシュキーテーブルには設定ができない。複合キーテーブルのみ設定が可能。
- ハッシュキーはそのテーブルと同じキーしか設定ができない
- レンジキーは別の属性を指定する
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
##### 参考ドキュメント
- [GSI OVERLOADING について 自分なりにまとめてみた](https://dev.classmethod.jp/cloud/aws/basic-of-gsi-overloading/)


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
## ストリームの表示タイプ
|表示タイプ|概要|
|---|---|
|キーのみ|変更された項目のキー属性のみ|
|新しいイメージ|変更後に表示される項目全体|
|古いイメージ|変更前に表示されていた項目全体|
|新旧イメージ|項目の新しいイメージと古いイメージの両方|
## 設定について
- ストリームを有効にするとARNが生成される
- テーブルには1つのストリームしか設定はできない
## DynamoDB Streams API
- ListStrreams
- DescribeStream
- GetShadIterator
- GetRecords
## DynamoDB Triggers
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