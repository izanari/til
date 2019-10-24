# AWS API Gateway
## アクセス制御
### Lambdaオーソライザー
- トークンベースとリクエストベースの二種類ある
  - トークンベースのLambdaオーソライザー（TOKENオーソライザーとも呼ばれる）は、JSON Web Token（JWT）やOAuthトークンなどのベアラートークンで呼び出し元のIDを受け取ります。
  - 要求パラメーターベースのLambdaオーソライザー（REQUESTオーソライザーとも呼ばれます）は、ヘッダー、クエリ文字列パラメーター、stageVariables、および$ context変数の組み合わせで呼び出し元のIDを受け取ります。
- WebSocket APIではリクエストベースのみがサポートされている

### 統合タイプ
- [API Gateway API 統合タイプを選択する](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-api-integration-types.html)
- CloudFormationでは、`AWS::ApiGateway::Method`の`Integration`で指定する
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