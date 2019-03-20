# SAM
## 使い方
### Lambda Functionを用意する
- requirements.txtは空でもいいので作成する
### evnet.jsonを用意する
- 作成したfunctionに応じて、テストで利用する`event.json`を作成します
- `sam local generate-event s3 put > event.json`　というようにコマンドでも作成できます。
  - `s3 put`以外に何が使えるかは、[ここ](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-local-generate-event.html)を参考ください。
### SAMのテンプレートを用意します
- [テンプレートのサンプル](https://github.com/izanari/aws-cloudformation-samples/blob/master/lambda/template-03.yml)
### SAMテンプレートのチェックをします
```
sam validate -t template.yml --profile hogehoge --region ap-northeast-1 --debug
```
### ビルドします
```
sam build -t template.yml --profile hogehoge --parameter-overrides ParameterKey=Logging,ParameterValue=DEBUG ParamterKey=hogehoge,ParameterValue=FugaFuga
```
### ローカル環境で動作確認をしてみる
```
sam local invoke --event ./event.json
```
- samでテストできない場合は、`python-lambda-local`を使う手もあり
### S3にアップロードします
```
sam package --s3-bucket hogehoge --output-template output.yml --profile hogehoge
```
### デプロイします
```
aws cloudformation deploy \
 --template-file output.yml \
 --stack-name hogehoge \
 --parameters-overrides Logging=DEBUG param2=value2　\
 --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
```
以下が表示されればデプロイ環境です
```
Successfully created/updated stack - test-lambdadeploy
```
- `deploy`する際のパラメータ指定方法と`build`する時の指定方法が異なります。注意してください。
## ファイル構成
```
.
├── __pycache__
│   └── index.cpython-37.pyc
├── event.json
├── output.yml
├── template.yml
└── test-lambdadeploy
    ├── index.py
    └── requirements.txt
```
- deployした際に、`.aws-sam`ディレクトリが自動生成されます
- `output.yml`も、`sam package`した時に自動生成されます

## はまるポイント
- deploy時のパラメーターがbuildと違う
- パラメータを''で括る時にも注意する
```
 --parameters-overrides 'Logging=DEBUG param2=value2'
 ```
 - このような指定方法をすると、パラメータ名が`Logging`、値が、`DEBUG param2=value2`となってしまいます。
```
 --parameters-overrides Logging='DEBUG' param2='value2'
 ```
- valueに改行がはいることがある時はこのようにくくりましょう
## 参考URL
- [Declaring Serverless Resources](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-template.html)
  - https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
- [AWS SAM CLI Command Reference](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)
  - [sam local generate-event](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-local-generate-event.html)
- https://github.com/HDE/python-lambda-local
- https://dev.classmethod.jp/server-side/serverless/aws-lambda-dev-test-deploy-ci/