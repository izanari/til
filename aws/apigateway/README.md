# AWS API Gateway
## ゲートウェイのレスポンス
- [ゲートウェイレスポンスのタイプ](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/supported-gateway-response-types.html)
## アクセス制御
### Lambdaオーソライザー
- トークンベースとリクエストベースの二種類ある
  - トークンベースのLambdaオーソライザー（TOKENオーソライザーとも呼ばれる）は、JSON Web Token（JWT）やOAuthトークンなどのベアラートークンで呼び出し元のIDを受け取ります。
  - 要求パラメーターベースのLambdaオーソライザー（REQUESTオーソライザーとも呼ばれます）は、ヘッダー、クエリ文字列パラメーター、stageVariables、および$ context変数の組み合わせで呼び出し元のIDを受け取ります。
- WebSocket APIではリクエストベースのみがサポートされている
### IAMユーザーで認証する
- リクエストを署名バージョン4を使用して著名する
  - [署名バージョン 4 署名プロセス](https://docs.aws.amazon.com/ja_jp/general/latest/gr/signature-version-4.html)

### 統合タイプ
- [API Gateway API 統合タイプを選択する](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-api-integration-types.html)
- CloudFormationでは、`AWS::ApiGateway::Method`の`Integration`で指定する
- 統合タイムアウト値は、50ミリ秒〜29秒の間で設定することができる
- パラメータの種類
  - AWS 
    - AWSサービス、もしくはLambda関数
  - AWS_PROXY
    - Lambda関数+Lambdaプロキシ統合
    - [API Gateway の Lambda プロキシ統合をセットアップする](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format)
  - HTTP
    - HTTP
  - HTTP_PROXY
    - HTTP+HTTPプロキシ統合
  - MOCK
    - MOCK
  - VPCリンクは、ConnectionTypeで指定をする
- 参照URL
  - https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-api-integration-types.html
  - https://docs.aws.amazon.com/cli/latest/reference/apigateway/create-resource.html

### 設定
- [API Gateway のメソッドリクエストをセットアップする](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-method-settings-method-request.html#setup-method-request-model)

## ディメンションとメトリクス
- [Amazon API Gateway のディメンションおよびメトリクス](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html)
### API Gateway メトリクス
|メトリクス|説明|
|--|--|
|CacheHitCount|指定された期間内に API キャッシュから配信されたリクエストの数。|
|CacheMissCount|API キャッシュが有効になっている特定の期間における、バックエンドから提供されたリクエストの数。|
|Count|指定された期間内の API リクエストの合計数。|
|IntegrationLatency|API Gateway がバックエンドにリクエストを中継してから、バックエンドからレスポンスを受け取るまでの時間。|
|Latency|API Gateway がクライアントからリクエストを受け取ってから、クライアントにレスポンスを返すまでの時間。レイテンシーには、統合のレイテンシーおよびその他の API Gateway オーバーヘッドが含まれます。|

## APIキャッシュ
- [API キャッシュを有効にして応答性を強化する](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-caching.html#override-api-gateway-stage-cache-for-method-cache)
  - [API を呼び出すためのアクセスの制御](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html)