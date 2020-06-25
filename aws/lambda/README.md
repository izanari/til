# Lambda
## 参照URL
- [AWS Lambda 関数を使用する際のベストプラクティス](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/best-practices.html)
- [今から始めるサーバーレス](https://aws.amazon.com/jp/serverless/patterns/start-serverless/)
- [AWS Lambda](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/welcome.html)

## 料金
- リクエスト
  - 月間100万リクエストまでは無料
  - 超過分は$0.2/100万リクエスト
- 実行時間
  - 100ms単位で課金となり、100ms以下は繰り上げされる
  - メモリー容量により単価および無料時間が異なる


## [AWS Lambda の制限](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/limits.html)
- インバウンドネットワーク接続はブロックされる
- アウトバウンドはTCP/IPとUDP/IPソケットのみ
- ptraceシステムコールはブロックされる
- 25port/TCPトラフィックはブロックされる
- 同時実行数は、デフォルト1000
- 関数とレイヤーストレージは75GB
- メモリ割り当ては、128MB〜3008MBまで、64M単位で増加可能
- タイムアウトは最大900s(15分)
- 関数の環境変数は4KB
- 関数リソースベースのポリシーは20KB
- 関数のレイヤーは、５layers
- 呼び出しペイロード（リクエストとレスポンス）
  - 6MB（同期）
  - 256KB（非同期）
- デプロイパッケージのサイズ
  - コンソールからは50MB(zip圧縮済み、直接アップロード)
    - S3を使えばこの制限は回避できる
  - 250MB（解凍）
    - 関数とすべてのレイヤーの解凍された合計サイズ
  - 3MB（コンソールのエディタ）
- テストイベントは１０個まで
- /tmpのストレージサイズは、512MB
- ファイルの説明は1024
- 実行プロセス・スレッドは1024



## イベントソース
- イベントの発生元となるAWSサービスもしくはユーザーが開発したアプリケーションのこと
- そのイベントソースがLambda関数の実行をトリガーする
### タイプ
- ポーリングベース（同期）
  - ストリームベース
  - 非ストリーム
- イベントソース（同期・非同期）

### サポートされるイベントソース(2019年4月1日現在)  
| イベントソース        | タイプ | 備考                             |
| --------------------- | ------ | -------------------------------- |
| S3                    | 非同期 |
| DynamoDB              | 同期   | ポーリングベース（ストリーム）   |
| Kinesis Data Streams  | 同期   | ポーリングベース（ストリーム）   |
| SNS                   | 非同期 |
| SES                   | 非同期 |
| SQS                   | 同期   | ポーリングベース（非ストリーム） |
| Cognito               | 同期   |
| CloudFormation        | 同期   |
| CloudWatch Logs       | 同期   |
| CloudWatch イベント   | 非同期 |
| CodeCommit            | 非同期 |
| CloudWatch Events     | 非同期 |
| Config                | 非同期 |
| Alexa                 | 同期   |
| Lex                   | 同期   |
| API Gateway           | 同期   |
| Iotボタン             | 非同期 |
| CloudFront            | 同期   |
| Kinesis Data Firehose | 同期   |

### 呼び出しタイプ
- 非同期呼び出し
  - InvocationTypeはEvent
  - レスポンスの内容はリクエストが正常に受付されたかどうかのみ
  - 以下の読み出しをｓｈちえも、response.jsonには情報が含まれない
  ```
  $ aws lambda invoke --function-name my-function  --invocation-type Event --payload '{ "key": "value" }' response.json
  {
      "StatusCode": 202
  }
  ```
- 同期呼び出し
  - https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/invocation-sync.html
  - InvoationTYpeはRequestResponse
  - 実行完了時にレスポンスが返ってくる。内容はLambda関数内でセットされる
  ```
  $ aws lambda invoke --function-name my-function --payload '{ "key": "value" }' response.json
  {
      "ExecutedVersion": "$LATEST",
      "StatusCode": 200
  }
  ```

### リトライ
- エラーの種類、イベントソース、呼び出しタイプによって異なる
- ストリームベースではないイベントソース
  - 同期呼び出し
    - API Gateway
    - エラー発生時にはレスポンスのヘッダにFunctionErrorが含まれる
    - パーミッション、Limit、関数コードの設定の問題によるエラーの場合は特定のステータスコードが返る。
  - 非同期呼び出し
    - S3
    - 自動的に２回リトライされ、その後イベントは破棄される
      - 最初の呼び出しでエラーがあると、その後２回リトライする。よって、都合３回まで呼び出しがある
    - リトライには遅延がある
      - ２回目の呼び出しには１分間、２回目と３回目の呼び出しには２分間の待機時間がある
    - Dead Letter Queueを設定することで未処理のイベントをSQS/SNSトピックスに移動させて確認することができる
- ポーリングベースでストリームベース
  - Dynamo / Kinesis Data Streams
  - データの有効期限が切れるまでリトライが行われる
  - 失敗したレコードの有効期限が切れるか処理が成功するまで、そのシャードからの読み込みはブロックされ新しいレコードの読み込みは行われない
- ポーリングベースでストリームベースではないイベントソース
  - SQS
  - そのバッチのメッセージはすべてキューに返り、Visibility Timeoutが過ぎれば処理が行われ、その後成功すればキューから削除される
  - 新しいメッセージの処理はブロックされない

## VPCアクセス
- VPC内のリソースにインターネットを経由しないでアクセスさせたい場合に利用する
- VPCサブネットおよびセキュリティグループを指定する
- AZごとに１つ以上のサブネットを指定することを推奨
- ENIを利用している
  - IAM Roleに`AWSLambdaVPCAccessExecutionRole`をアタッチしておく必要がある
- インターネットへアクセスさせたい場合はNATゲートウェイを利用すること
- サブネットにIPがない場合はリクエスト数が増えた場合に失敗する
  - 非同期呼び出しの場合は、エラーがCloudWatchに記録されない
  - コンソールで実行した場合のエラー応答は取得可能
- Public IPは割当されない
- Private IPを固定することはできない
- 初回アクセス時などENI作成に伴う場合、10〜60秒程度の時間を要する
- ENIは複数のLambdaから共用される

## 実行ロール
- 最低でもログ出力用にCloudWatch Logsへのアクセス許可が必要

## アクセス許可
- 別のAWSアカウントにアクセス許可を付与することができる
  - principalとして別のAWSアカウントIDを指定する

## 同時実行数
- デフォルトでは1000に制限されている。関数単位ではなくアカウントに対しての制限。
  - 実績に応じて制限緩和申請することができる
- 制限を超えた場合はスロットリングエラー（コード：429）が返却される
  - 非同期呼び出しの場合、15〜30分程度はバーストが許容されるがそれ以降はスロットリングの対象となる
- アカウントに許可された値を上限として、関数単位で任意の割合で割り振ることも可能
- 見積もり
  - ポーリングベースかつストリームベース（DynamoDB、Kinesis Data Streams）
    - シャード数と同じ
  - ポーリングベースだがストリームベースじゃない（SQS）
    - 同時実行数までポーリングを自動的にスケールアップ
    - SQSでは５つの同時関数呼び出しが最初のバーストでサポートされる
    - １分毎に60の同期実行呼び出しで同時実行が増加
  - それ以外
    - 秒間呼び出し回数x平均実行時間（秒）

## ライフサイクル
1. ENIの作成
   - VPCを利用する場合だけ、10〜30秒かかる。Durationには含まれない
2. コンテナの作成
3. デプロイパッケージのロード
4. デプロイパッケージの展開
   - Durationには含まない
5. ランタイムの起動および初期化
    - ランタイムの初期化処理
    - グルーバルスコープ処理もここで実行される
    - Durationには含まない
6. 関数・メソッドの実行
    - ハンドラーで指定した関数、メソッドの実行
    - ここがDurationの実行時間
7. コンテナの破棄

- １から６を実行するのがコールドスタート
  - 起こる条件
    - １つもコンテナがない場合に発生
    - 利用可能な数以上に同時に処理すべきリクエストが来た
    - コード、設定を変更した
  - 安定的にリクエストが発生している場合はコールドスタートはほとんど発生しない

## プログラミングモデルの基本
- ハンドラー
  - 利用する言語の関数もしくはメソッドを指定し、実行の際に呼び出すエントリポイントとなる
  - 呼び出しの際にパラメーターとして渡されるイベントのデータ（JSON形式）にアクセスすることが可能
- コンテキスト
  - ランタイムに関する情報が含まれ、ハンドラー内部からアクセス可能
  - コールバックを利用する言語（NodeJS)の場合、コールバックメソッドの振る舞いを設定可能
    - デフォルト（true）は全ての非同期処理の完了を待ってレスポンス
    - falseにするとcallbackが呼び出された時点で即座に処理終了
        ```
        const AWS = require('aws-sdk')
        const s3 = new AWS.S3()

        exports.handler = function(event, context, callback) {
            context.callbackWaitsForEmptyEventLoop = false
            s3.listBuckets(null, callback)
            setTimeout(function () {
                console.log('Timeout complete.')
            }, 5000)
        }
        ```
    - [Node.js での AWS Lambda Context オブジェクト](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/nodejs-prog-model-context.html)
- ロギング
  - Lambda関数内にログ出力のステートメントを含めることができる
  - スロットリングによって失われることがある
- 例外
  - 使用する言語によって正常終了方法は異なる
  - 実行中に発生したエラーを通知する方法も異なる
  - 同期呼び出しされている場合は、クライアントへエラーがレスポンスされる
- ステートレスにする必要がある
  - 関数が実行される度に同じインスタンスで実行されるとは限らない
  - ローカルファイルシステムへのアクセス、子プロセス、その他類似の生成物はリクエストの有効期限に限定される
  - 永続化するにはS3,Dynamoなどへの保存が必要

### 環境変数
- 関数のコードからのアクセスは各言語でサポートされている環境変数へのアクセス方法がそのまま利用可能
  - Node.jsの場合は、process.envを利用する
- バージョニング利用時は環境変数の情報もスナップショットに含まれる
- Lambda関数内で時刻を扱う場合はタイムゾーンをJSTにできます
  - 環境変数`TZ`を`Asia/Tokyo`とする
#### 暗号化
- KMSで自動的に暗号化して保存され、必要に応じて複合される
  - デフォルトではLambda用のKMSサービスキーを利用して暗号化・復号化
  - 暗号化されるのはデプロイ中ではなくデプロイ後
  - 関数が呼び出しされると自動的に復号化される
  - 独自のサービスキーを利用する場合は、AWS KMSの料金が適用される
    - ロールに
    - kms:Decryptを許可する必要がある
  - 暗号化ヘルパー
    - 機密情報を暗号化して保存可能
    - 複合はLambda関数内で実行
    - 暗号化された環境変数の値をLambda関数内で復号化するサンプルも生成

## デプロイパッケージ
- コードと依存関係で構成されるzip/jarファイル
- 依存関係の含め方は言語により異なる
  - Node.jsの場合、ライブラリは、`node_mobukes`フォルダにインストールしzip化する


## ベストプラクティス
- コールドスタートを速くする
  - リソースを増やすと初期化処理自体も速くなる
    - 見極め方法
      - メモリサイズと比例してCPU能力も割り当てされる
      - メモリを増やすことで処理時間が短くなり結果的にコストは変わらず性能があがることもある
      - 少しづつ設定を変更していき、処理時間が変わらなくなるサイズを見極め
  - ランタイムを変える
    - JVMは起動は遅い。一度温まるとコンパイル言語速い。
  - パッケージサイズを小さくする
    - 依存関係を減らす
      - 不要なモジュールは含まない
      - SDKのコンポーネントは必要なものだけを含むようにしたほうがよい
    - コード最適化ツールを使って減らす
      - ProGuard(Java)
      - UglifyJS
  - VPCは必要でない限り使用しない
    - 10秒〜30秒程度のコールドスタートが発生する
    - Elasticsearch ServiceはIAMで保護できるのでパブリックに公開してもいいだろう
- 再帰的なコードを使用しない
  - 任意の条件が満たされるまでその関数自身を自動的に呼び出すような再帰的なコードを使用しない。使用すると意図しないボリュームで関数が呼び出され、料金が急増することがある。
- 各言語のベストプラクティス、最適化手法はそのまま当てはまる
- 関数内でオーケストレーションはしない
- Lambdaハンドラーからコアロジックを分離する
  - 単体テストがやりやすくなる
  ```
  app=Todo()

  def lambda_handler(event, context):
    ret=app.dispatch(event)
    return
      {
        'statusCode': ret["status_code"],
        'headers': ret["headers"],
        'body': json.dumps(ret["body"])
      }
  ```
- コンテナ再利用を有効活用する
  - グローバルスコープを賢く利用する
  - AWS SDKクライアントやDBクライアントの初期化はハンドラの外側で行う
    - グローバルスコープはコールドスタートでしか実行されない
    - コンテナが維持されている間は利用可能
- 必要なもののみを読み込む
  - s3 select等で絞り込む
- レジリエンシの向上
  - エラーハンドリング
    - 外部接続する際、タイムアウトを適切にコントロールする
    - リトライ処理を実装する
      - リトライポリシーを理解しておく
        - 同期はリトライ無し
        - 非同期は２回リトライしてくれる
        - ストリームは期限が切れるまでリトライが繰り返される
    - DLQを活用すること
      - 関数ごとに設定する
- 組み込まれたSDKを使用しない
  - すべての依存関係はデプロイパッケージとしてパッケージすることを推奨
  - Lambda関数の動作が微妙に変わる場合がある
  - Lambdaに含まれるランタイムは[AWS Lambda ランタイム](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-runtimes.html)に記載されている
- 非同期実行を活用する
  - バーストも許容される
  - 同時呼び出しの場合エラーが変えるけど、非同期はリトライされる
- 冪等性を確保する
  - Lamdabは最低１回実行することで１回しか実行しないことではない
  - イベントIDをDynamoDBに保管するなど
  - 処理前後でバケットを分けて、処理後には消す
- １つのイベントを小さくして同時に並列で動かせるようなアーキテクチャにする
  - １回のInvokeでループさせるのではなく、ループ回数分Lambdaファンクションを非同期Invokeする
  - 同時実行しているLambdaファンクションが減るので、同時実行数の制限に引っかかりにくくなる
- Javaの場合
  - POJOではなくバイトストリームを使う
- 複雑な依存関係のフレームワークは使わない
  - Spring FrameworkよりもDaggerやGuiceなど単純なものを使う
- ハードコーディングしない
  - 関数へのパラメータは環境変数を利用する
  - System Manager Parameter StoreやSecrets Managerの利用も考える
    - ssm_cacheを利用してもよい
- ストリーム型のイベントソースを利用する上でのプラクティス
  - バッチサイズはLambda関数の実行
  - 1バッチで最大6MBまでしか処理はできない
  - 処理が失敗するとデータが期限切れになるまでシャード全体がブロックされる
    - Lambdaは常に成功したと返却し、関数のコード内でログ出力やキューに失敗したレコード情報をおくるようにしないといけない
  - 複数のコンシューマを紐付けることはやめたほうがよい
    - DynamoDBストリームがサポートするのは最大2プロセスからのアクセス
  - 順序が重要ではないときはAmazon SNSを利用する
  - ファンアウトパターン
    - Streaming source -> Kinesis Data Stream -> Lambda Dispatcher
- Lambdaで利用するデータベースについて
  - コネクション数の問題とコールドスタートの問題がある
  - 実行数が少ない、コールドスタートが許容できるのであればRDSを使っても問題無い
  - DynamoDBを使ってもよい
  - RDMSを使う場合は非同期に行う
    - DynamoDB StreamsとAWS Lambdaを利用してRDSへ反映
    - Amazon Kinesis Data StreamsやSQSとLambdaを利用して非同期に反映
    - Amazon API Gatewayとの組み合わせの場合、サービスプロキシで構成してLambda関数を非同期呼び出しする
  - 同時実行数を指定する
  - Aurora Serverlessを使う
    - Data API
    - 1分以内に処理が完了しないとタイムアウトする
    - 結果はJSON
    - 1000行もしくは1MB
- IPは固定しない
  - 署名や証明書などで担保すべきである
- IAMはきつくしぼって使用する
- イベントソースにSQSを使っている場合は関数の実行時間＜キューの可視性タイムアウトの関係になっていることを確認する
  - Lambdaの実行タイムアウトよりもキューが見えてしまっては２度メッセージが実行されてしまう
- すべてをLambdaでやらない
  - ステートフルなアプリケーション
  - ロングバッチ
  - CPU/メモリのスペックが合わない
    - このような場合はコンテナ/EC2を使いましょう
- Lambda関数のロードテストにより最適なタイムアウト値を決定します
  - メモリ使用量もログで確認する
- Lambda関数内からメトリクスを作成または更新しないようにする
- 実行コンテキストの再利用を活用して関数のパフォーマンスを向上させます
  - コードで取得する外部設定や依存関係が、最初の実行後はローカルで保存および参照されることを確認します。すべての呼び出しで変数/オブジェクトの再初期化を制限します。代わりに、静的初期化/コンストラクタ、グローバル/静的変数、およびシングルトンを使用します。前の呼び出しで確立した接続 (HTTP やデータベースなど) をキープアライブにして再利用します。
  - [AWS Lambda 実行コンテキスト](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/running-lambda-code.html)
## AWS Lambda 環境変数
### 保存データの暗号化
- デフォルトではAWSアカウントにあるLambda用のAWS管理CMSが使用される
- 自分で管理するCMSを使用することもできる
- コンソール上で暗号化ヘルパーを使う場合は自分で管理するCMSを指定する

## CloudFormation/SAM
### ソースコードの指定方法
- CloudFormation
  - Codeを使う
    ```
    MyFunction:
      Type: "AWS::Lambda::Function"
      Properties:
        Code:
          S3Bucket: yourbucketname
          S3Key: yourkey
    ```
  - ZipFileを使う
    - ただし、Node.jsとPythonのみ
    ```
    MyFunction:
      Type: "AWS::Lambda::Function"
      Properties:
        Code:
          ZipFile: >
            import boto3
            def lambda_handler(event, context):
              print("Hello World")
    ```
- SAM
  - CodeUriを使う
    ```
    Myfunction:
      Type: AWS::Serverless::Function
      Properties:
        CodeUri: s3://yourbucket
    ```
    - sam packageがS3のパスに変換してくれる

  - Inlineを使う
    ```
    Myfunction:
      Type: AWS::Serverless::Function
      Properties:
        InlineCode: |
            import boto3
            def lambda_handler(event, context):
              print("Hello World")
    ``` 

## チューニング
- https://github.com/alexcasalboni/aws-lambda-power-tuning

## 参考ドキュメント
- [AWS Lambdaのスロットリング緩和](https://speakerdeck.com/_kensh/how-to-manage-throttling-for-aws-lambda)