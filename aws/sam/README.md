# SAM
## 使い方
### Lambda Functionを用意する
- requirements.txtは空でもいいので作成する
### evnet.jsonを用意する
- 作成したfunctionに応じて、テストで利用する`event.json`を作成します
- `sam local generate-event s3 put > event.json`　というようにコマンドでも作成できます。
### SAMのテンプレートを用意します
- [テンプレートのサンプル](https://github.com/izanari/aws-cloudformation-samples/blob/master/lambda/template-03.yml)
### ビルドします
```
sam build -t template.yml --profile hogehoge --parameter-overrides 'Logging=DEBUG'
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
aws cloudformation deploy --template-file output.yml --stack-name hogehoge --parameter-overrides 'Logging=DEBUG'
```
以下が表示されればデプロイ環境です
```
Successfully created/updated stack - test-lambdadeploy
```
## 参考URL
- [Declaring Serverless Resources](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-template.html)
  - https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
- [sam local generate-event](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-local-generate-event.html)
- https://github.com/HDE/python-lambda-local