# DynamoDBの操作

## テーブル
### テーブルを作成する
- オンデマンド(`PAY_PER_REQUEST`)
```
aws dynamodb create-table \
--table-name Counter \
--attribute-definitions AttributeName=RecordId,AttributeType=N \
--key-schema AttributeName=RecordId,KeyType=HASH \
--billing-mode PAY_PER_REQUEST \
--endpoint-url http://localhost:8000
```
- RCU/WCUを指定して作成する
```
aws dynamodb create-table \
--table-name Person \
--attribute-definitions AttributeName=Id,AttributeType=S AttributeName=Group,AttributeType=S \
--key-schema AttributeName=Id,KeyType=HASH AttributeName=Group,KeyType=RANGE \
--billing-mode PROVISIONED \
--provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=20 \
--endpoint-url http://localhost:8000
```
- GSIを作る
```
aws dynamodb update-table \
 --table-name Person \
 --attribute-definitions AttributeName=FirstName,AttributeType=S \
 --billing-mode PROVISIONED \
 --endpoint-url http://localhost:8000 \
 --global-secondary-index-updates '[{
     "Create": {
         "IndexName":"Person-Name-index",
         "KeySchema":[
             {"AttributeName":"FirstName", "KeyType":"HASH"},
             {"AttributeName":"Id", "KeyType":"RANGE"}
         ],
         "Projection": {"ProjectionType":"ALL"},
         "ProvisionedThroughput": { "ReadCapacityUnits":10, "WriteCapacityUnits":20 }
     } }]' 
```
### テーブルの内容を確認する
```
aws dynamodb describe-table \
 --table-name Counter \
 --endpoint-url http://localhost:8000 
```

## アイテム
### アイテムを登録する
```
aws dynamodb put-item \
 --table-name Counter \
 --item '{ "RecordId": {"N": "2"}, "Counter": {"N":"1"} }'\
 --return-values 'ALL_OLD' \
 --endpoint-url http://localhost:8000
```

### 上書きはしない
```
aws dynamodb put-item \
 --table-name Person \
 --item '{ "Id": {"S": "235"}, "Group": {"S":"AWS"}, "FirstName":{"S":"HogeHoge"}}'\
 --return-values 'ALL_OLD' \
 --condition-expression "attribute_not_exists(Id)" \
 --return-consumed-capacity INDEXES \
 --endpoint-url http://localhost:8000
```
- 失敗した時の表示
  ```
   An error occurred (ConditionalCheckFailedException) when calling the PutItem operation: The conditional request failed
  ```
### アイテムを1件取得する
```
aws dynamodb get-item \
 --table-name Counter \
 --key '{ "RecordId": {"N":"1"} }' \
 --endpoint-url http://localhost:8000
 ```

### レコード数をカウントする
```
aws dynamodb scan \
 --table-name Counter \
 --select "COUNT" \
 --endpoint-url http://localhost:8000
```

### Query
#### ハッシュキーに対する条件指定
- ハッシュキーにはレンジ指定は使えない
```
aws dynamodb query \
 --endpoint-url http://localhost:8000 \
 --table-name Counter \
 --key-condition-expression 'RecordId = :a' \
 --expression-attribute-values '{ ":a":{"N":"1"} }'
 ```

### Update
#### カウンターとして使う
```
aws dynamodb update-item \
 --table-name Counter \
 --key '{"RecordId": {"N": "11"}}' \
 --update-expression "SET CountVal = CountVal + :incr" \
 --expression-attribute-value '{ ":incr":{"N":"1"} }' \
 --return-values ALL_NEW \
 --endpoint-url http://localhost:8000
 ```
 
## 参考サイト
- [比較演算子および関数リファレンス](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Expressions.OperatorsAndFunctions.html)
- https://blog.brains-tech.co.jp/entry/2015/09/30/222148
