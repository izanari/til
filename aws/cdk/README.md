# cdk
- [aws/aws-cdk](https://github.com/aws/aws-cdk)
  - [aws-samples/aws-cdk-examples](https://github.com/aws-samples/aws-cdk-examples)
- [CDKで使えるパッケージ](https://github.com/aws/aws-cdk/tree/master/packages/%40aws-cdk)
- [AWS CDK](https://docs.aws.amazon.com/cdk/api/latest/)
  - [AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html)
- [WorkShop](https://cdkworkshop.com/)
    - [日本語版WorkShop](http://bit.ly/cdkworkshopjp)
      - リソースのダウンロードが始まります

## 使い方
- 初期化する
  ```
  cdk init app --language=python
  ```
  - サンプルアプリのファイルを含みたい場合
    ```
    cdk init sample-app --language=python
    ```
- deploy

```
cdk bootstrap
cdk synth mystack
cdk deploy mystack
```

## 参考サイト
- [【AWS CDK】CDK標準の3種類のConstructを使って、AWSリソースをデプロイしてみた](https://dev.classmethod.jp/cloud/aws/aws-cdk-construct-explanation/)
- [AWS Cloud Development Kit (AWS CDK)でECS環境を構築してみた](https://dev.classmethod.jp/cloud/aws/aws-cdk-getting-ecs/)
- 