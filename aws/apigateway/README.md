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
    - AWSサービス、もしくはLambdaカスタム統合
  - AWS_PROXY
    - Lambdaプロキシ統合
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
- 使用量プラン
  - API を作成し、テストして、デプロイすると、API Gateway 使用量プランを使用して、顧客への提供商品として使用できるようになります。ビジネス要件および予算の制約に合った承認済みのリクエストレートとクォータで顧客に、選択した API へのアクセスを許可する使用量プランと API キーを設定できます。必要に応じて、API のデフォルトのメソッドレベルのスロットリング制限を設定したり、個別の API メソッドのスロットリング制限を設定したりできます。
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


## レスポンスタイプ
- [ゲートウェイレスポンスのタイプ](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/supported-gateway-response-types.html)
  
|タイプ|コード|説明|
|--|--|--|
|INTEGRATION_FAILURE|504|統合が失敗した場合のゲートウェイレスポンス。(*1)|
|INTEGRATION_TIMEOUT|504|統合がタイムアウトした場合のゲートウェイレスポンス。(*1)|
|API_CONFIGURATION_ERROR|500|API 設定が無効な場合のゲートウェイレスポンス。たとえば、無効なエンドポイントアドレスが送信された場合、バイナリサポートが有効になっているときにバイナリデータに対する Base64 デコーディングが失敗した場合、統合レスポンスマッピングがいずれのテンプレートとも一致せず、デフォルトテンプレートも設定されていない場合などが該当します。(*1)|

- (*1) レスポンスタイプが未指定の場合、このレスポンスはデフォルトで DEFAULT_5XX タイプになります。

## 制限
- [Amazon API Gateway の制限事項と重要な注意点](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/limits.html)
### REST API 
- 統合のタイムアウト
  - Lambda、Lambda プロキシ、HTTP、HTTP プロキシ、AWS 統合など、すべての統合タイプで 50 ミリ秒～29 秒。
  - よって、Lambdaは30秒以上かかる場合はAPI Gatewayには向いていない