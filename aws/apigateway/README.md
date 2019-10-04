# AWS API Gateway
## アクセス制御
### Lambdaオーソライザー
- トークンベースとリクエストベースの二種類ある
- WebSocket APIではリクエストベースのみがサポートされている

### 統合タイプ
- CloudFormationでは、`AWS::ApiGateway::Method`の`Integration`で指定する
- パラメータの種類
  - AWS
  - AWS_PROXY
  - HTTP
  - HTTP_PROXY
  - MOCK