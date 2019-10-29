# dynamodb local

## セットアップ
- Dockerを使います
- https://hub.docker.com/r/amazon/dynamodb-local
- 
## 起動方法
```
docker run -p 8000:8000 amazon/dynamodb-local
```

## 接続方法
### AWS CLI
```
aws dynamodb list-tables --endpoint-url http://localhost:8000
```
### boto3
```
client = boto3.client('dynamodb', endpoint_url="http://localhost:8000")
```
