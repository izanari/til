# SAM
## 文法
### AWS::Serverless::Function
- CodeUri
  - s3にアップロードしたコードの指定方法
  ```
  Resources:
    HelloWorldFunction:
      Type: AWS::Serverless::Function
      Properties:
        CodeUri: s3://hogehoge.zip
  ```
  - Inline Codeの書き方
    - テンプレート内に直接コードを記述することができる
  ```
  Resources:
    HelloWorldFunction:
      AWS::Serverless::Function
      Properties:
        InlineCode: |
          exports.handler = async(event, context, callback) => {
            return event
          }
        Handler: index.handler
  ```
- DeploymentPreference
  - Deployの仕方を指定することができる
    - AllAtOnce
      - すべてのLambda関数の実行を最新バージョンで行う
    - Canary{x}Percent{y}Minutes
      - Lambda関数の実行のうち{x}%は最新バージョンを実行し、{y}分後にすべてが最新バージョンで実行される
    - Linear{x}Percent{y}Minutes
      - {y}分毎に{x}パーセントずつ新しいLambda関数へトラフィックを流し、100％になるまでこれを継続する
## 使い方
### プロジェクトディレクトリを作成する
```
sam init -n sam-test -r pyrhon3.7 
```
- `sam-test`ディレクトリが作成され、デフォルトのファイルが作成される


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
 --parameters-overrides 'param1=value1 param2=value2'
 ```
 - このような指定方法をすると、パラメータ名が`param1`、値が、`value1 param2=value2`となってしまいます。
```
 --parameters-overrides param1='value1' param2='value2'
 ```
- valueに改行がはいることがある時はこのようにくくりましょう
## 参考URL
- [Declaring Serverless Resources](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-template.html)
  - https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
- [AWS SAM CLI Command Reference](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)
  - [sam local generate-event](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-local-generate-event.html)
- https://github.com/HDE/python-lambda-local
- https://dev.classmethod.jp/server-side/serverless/aws-lambda-dev-test-deploy-ci/

## トラブルシューティング
### nodejs8.10をサポートしていないと言われたとき
- samのバージョンが古い。v0.9からサポートされているため、upgradeしましょう
  - 表示されるエラー
```
Build Failed
Error: 'nodejs8.10' runtime is not supported
```
  - Macの場合
```
brew upgrade aws-sam-cli
or
pip install --upgrade aws-sam-cli
```

## 参考URL
- [AWS SAMを通してCodeDeployを利用したLambda関数のデプロイを理解する – ClassmethodサーバーレスAdvent Calendar 2017 #serverless #adventcalendar #reinvent](https://dev.classmethod.jp/server-side/serverless/understanding-lambda-deploy-with-codedeploy-using-aws-sam/)