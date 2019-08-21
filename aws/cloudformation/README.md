# CloudFormation

## リファレンス
- [パラメーター](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)
- [疑似パラメーター](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html)


## tips
- 疑似パラメータを使う
  - AWSアカウントIDは埋め込まないようにする
    ```
        Resources:
            TestXRayFunction:
            Type: AWS::Serverless::Function 
            Properties:
            CodeUri: src/
            Handler: app.lambda_handler
            Runtime: python3.7
            Role: !Sub arn:aws:iam::${AWS::AccountId}:role/Project_LambdaBasic
            Tracing: Active
      ```


## サンプル
- [awslabs](https://github.com/awslabs/aws-cloudformation-templates)

## 気をつけるところ
- 全てをCloudFormationではできないことがある
  - `AWS::CertificateManager::Certificate`を`ValidationMethod: DNS `した時、すぐに承認されないとロールバックされてリクエストが消されてしまいます。ロールバックは180分までしか設定できないから、手動で作成したほうが無難。