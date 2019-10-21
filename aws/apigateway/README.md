# AWS API Gateway
## アクセス制御
### Lambdaオーソライザー
- トークンベースとリクエストベースの二種類ある
  - トークンベースのLambdaオーソライザー（TOKENオーソライザーとも呼ばれる）は、JSON Web Token（JWT）やOAuthトークンなどのベアラートークンで呼び出し元のIDを受け取ります。
  - 要求パラメーターベースのLambdaオーソライザー（REQUESTオーソライザーとも呼ばれます）は、ヘッダー、クエリ文字列パラメーター、stageVariables、および$ context変数の組み合わせで呼び出し元のIDを受け取ります。
- WebSocket APIではリクエストベースのみがサポートされている

### 統合タイプ
- CloudFormationでは、`AWS::ApiGateway::Method`の`Integration`で指定する
- パラメータの種類
  - AWS
  - AWS_PROXY
  - HTTP
  - HTTP_PROXY
  - MOCK