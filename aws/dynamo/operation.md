# DynamoDBの操作

## テーブル
### テーブルを作成する
```
aws dynamodb create-table \
--table-name Counter \
--attribute-definitions AttributeName=RecordId,AttributeType=N \
--key-schema AttributeName=RecordId,KeyType=HASH \
--billing-mode PAY_PER_REQUEST \
--endpoint-url http://localhost:8000
```
- `PAY_PER_REQUEST`はオンデマンド

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
- https://blog.brains-tech.co.jp/entry/2015/09/30/222148
