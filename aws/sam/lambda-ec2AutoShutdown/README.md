# ec2自動停止function
- EC2インスタンスに、autostop: false とタグ付けされていない場合は、タイマーで自動停止させる
- 開発はSAMを使っている

## samを使った、開発からデプロイまでの手順
- CloudWatch Eventsからlambdaを起動させるようにします
### samの初期化
```
sam init -r python3.7 -n ec2_auto_shutdown
```
- `-n`で指定した名前でディレクトリが生成されるため、適切な名前をつけます。そのディレクトリにテンプレートファイルが生成されます。
### lambda関数をコーディングする
- srcというディレクトリを生成し、その中にlambda関数ファイルをおきます
- ライブラリを使っていなくても、`requirements.txt`は作っておきます

### テスト用のevent.jsonを作成します
```
sam local generate-event cloudwatch scheduled-event > event.json
```
#### ここまでくるとこのようなファイル構成になってます
```
ec2_auto_shutdown
├── README.md
├── event.json
├── hello_world <-- これは使わないから消してもよい
│   ├── __init__.py
│   ├── __pycache__
│   │   ├── __init__.cpython-36.pyc
│   │   └── app.cpython-36.pyc
│   ├── app.py
│   └── requirements.txt
├── src
│   ├── lambda_function.py
│   └── requirements.txt
├── template.yaml
└── tests　<-- これは使わないから消してもよい
    └── unit
        ├── __init__.py
        ├── __pycache__
        │   ├── __init__.cpython-36.pyc
        │   └── test_handler.cpython-36.pyc
        └── test_handler.py
```

### samのテンプレートファイルの一部を修正します
- template.yaml 修正前
```
            CodeUri: hello_world/
            Handler: app.lambda_handler
```

- template.yaml 修正後
```
            CodeUri: src/
            Handler: lambda_function.lambda_handler
```
- これを修正しないと、samコマンドがlambda関数ファイルを認識しません。残りの修正は後でします。
- `template.yml` じゃなく、`template.yaml`ですよ。

### ローカル環境でテストします
```
sam local invoke --profile hoge -e event.json --region ap-northeast-1
```
- テストして問題ないようであれば、template.yamlを修正します。修正後は、[このように](./template.yaml)なります。

### テンプレートの検証をします
```
sam validate -t template.yaml --profile hoge
--region ap-northeast-1
```
### ビルドします
```
sam build -t template.yaml --profile hoge
--region ap-northeast-1
```
ビルドが成功すると、画面に以下のように表示されます
```
Build Succeeded

Built Artifacts  : .aws-sam/build
Built Template   : .aws-sam/build/template.yaml

Commands you can use next
=========================
[*] Invoke Function: sam local invoke
[*] Package: sam package --s3-bucket <yourbucket>
```
### S3へアップロードします
```
sam package --s3-bucket mybucket --output-template output.yml --profile hoge
```
- 正常に終了すると、ソースコードの場所が編集された`output.yml`が生成されます
### CloudFormationでデプロイします
```
aws cloudformation deploy --template-file output.yml --stack-name lambda-ec2-auto-shutdown  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
```
- 成功時にはこのような表示がされます
```
Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - lambda-ec2-auto-shutdown
```
- 失敗した時にはこのような表示がされます
```
Waiting for changeset to be created..
Waiting for stack create/update to complete

Failed to create/update the stack. Run the following command
to fetch the list of events leading up to the failure
aws cloudformation describe-stack-events --stack-name lambda-ec2-auto-shutdown
```
- 失敗した原因を知りたい場合は、`aws cloudformation describe-stack-events --stack-name lambda-ec2-auto-shutdown`を実行するか、コンソール画面で確認します。

## 変更が発生した場合
- `sam build`から行います。
- lambda関数ファイルが編集されていない場合でも、バージョンが1つあがります。（これの回避策は不明。たぶんできない）

## 参考ドキュメント
- [AWS Serverless Application Model](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md)

## 備考
- `hello_world`フォルダは意図的に残してあります。他のプロジェクトでは削除しましょうね。