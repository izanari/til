# dynamodb local

## 接続方法
### AWS CLI
```
aws dynamodb list-tables --endpoint-url http://localhost:8000
```
### boto3
```
client = boto3.client('dynamodb', endpoint_url="http://localhost:8000")
```
