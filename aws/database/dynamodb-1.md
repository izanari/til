# DynamoDB(1)
## DynamoDBのこと
- RDBでいうレコードのことをDynamoDBではアイテムと呼びます。
- プライマリーキーは、Hash属性もしくは、Hash属性+Range属性のどちらかです。3つ以上の属性を定義することはできません
- put_item はデフォルトは上書きです。プライマリーキーが同じデータをput_itemしてもエラーにはなりません
  - エラーとするには、`ConditionExpression`を指定します。ソースコードを参照
- アイテム属性は入れ子にすることができる
  - [項目属性の指定](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Expressions.Attributes.html)
## ローカル環境でDynamoDBを動かす
- Docker イメージが提供されている。以下のコマンドで実行することは可能。
```
docker run -p 8000:8000 -d amazon/dynamodb-local
```
## 動いていることを確認する
1. dokcer ps
```
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                    NAMES
3a6e7f715cba        amazon/dynamodb-local   "java -jar DynamoDBL…"   9 minutes ago       Up 9 minutes        0.0.0.0:8000->8000/tcp   boring_perlman
```
2. ブラウザからアクセスする
- `http://localhost:8000/shell/` でアクセスすると、JavaScriptからDynamoDBが操作できるコンソールが表示される
### ローカルのDynamoDBでは
- volumeをマウントできないのでデータを永続化させることはできない。コンテナを止めたらデータはクリアされます
- endpointを指定することでローカルのdynamodbにアクセスすることができます

## 操作する
### テーブルを作成する
- Memberテーブル、MemberIDをプライマリーキー（ハッシュキー）とする
``` create_table.py
import boto3
from botocore.exceptions import ClientError

client = boto3.client('dynamodb', endpoint_url="http://localhost:8000")

my_tablename = 'Member'

try:
    response = client.describe_table(
        TableName = my_tablename
    )
except ClientError as ex:
    if ex.response['Error']['Code'] == 'ResourceNotFoundException' :
        print("テーブルを作成します")
        response = client.create_table(
            TableName = my_tablename,
            AttributeDefinitions=[
                {
                    'AttributeName': 'MemberID',
                    'AttributeType': 'S'
                },
            ],
            KeySchema=[
                {
                    'AttributeName': 'MemberID',
                    'KeyType': 'HASH'
                }
            ],
            ProvisionedThroughput={
                    'ReadCapacityUnits': 1,
                    'WriteCapacityUnits': 1
            }
            
        )
        print("テーブルを作成しました")
        
print(response)
```

### アイテムを登録する
- MemberIDが同じアイテムを登録しようとするとエラーとする
  - `ConditionExpression = 'attribute_not_exists(MemberID)'`をつけないと上書きになります！
  - 利用できる関数は、[関数](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/Expressions.OperatorsAndFunctions.html#Expressions.OperatorsAndFunctions.Functions)を参照する
``` put_item.py
import boto3
from botocore.exceptions import ClientError

client = boto3.client('dynamodb', endpoint_url="http://localhost:8000")

my_tablename = 'Member'

try:
    response = client.put_item(
        TableName = my_tablename ,
        Item = {
            'MemberID':{
                'S':'hoge03'
            },
            'Name':{
                'S':'ほげ02'
            },
            'sourceDomain':{
                'S':'https://hoge02.hoge'
            }
        },
        ConditionExpression = 'attribute_not_exists(MemberID)'
    )
except ClientError as ex:
     if ex.response['Error']['Code'] == 'ConditionalCheckFailedException' :
         print("put_itemに失敗しました")
else:
    print("成功しました")
    print(response)
```

### アイテムを参照する
``` get_item.py
import boto3
from botocore.exceptions import ClientError

client = boto3.client('dynamodb', endpoint_url="http://localhost:8000")

my_tablename = 'Member'
my_key = 'hoge01'

response = client.get_item(
    TableName = my_tablename,
    Key = {
        'MemberID':{
            'S': my_key
        }
    }

)

if response.get('Item') is None:
    print("アイテムがありませんでした")
    print(response)
else:
    print("アイテムがありました")
    print(response['Item'])
    for k,v in response['Item'].items():
        print("キー："+k)
        if ( type(v) is dict ): // バリュー部分は辞書型になっているため
            for _k,_v in v.items():
                print("値："+_v)

```
- .getはキーが無い時に、`None`が返却されるので、`is None`でチェックをする
- アイテムのバリュー部分は入れ子になっていない文字型でも、辞書型になっている点に注意


## 参考ドキュメント
- [DynamoDB のベストプラクティス](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/best-practices.html)
- https://github.com/aws-samples/aws-sam-java-rest
- [Amazon DynamoDB まとめ](https://qiita.com/kenichi_nakamura/items/bc60d4702b5f88d59cfb)
- [DynamoDBをPython（boto3）を使って試してみた](https://qiita.com/estaro/items/b329deafdfef790aa355)
- [ここにハマった！DynamoDB](https://blog.brains-tech.co.jp/entry/2015/09/30/222148)
