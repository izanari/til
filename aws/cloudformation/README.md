# CloudFormation

## リファレンス
- [パラメーター](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)
- [疑似パラメーター](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html)

## セクション
- AWSTemplateFormatVersion
- Metadata
  - テンプレートに関する追加情報を提供するオブジェクト
  ```
  Resources:
    MyInstance:
      Type: "AWS::EC2::Instance"
  Metadata:
    MyInstance:
      Description: "Information about the instance"
    Database:
      Description: "Information about the database"
  ```

- Parameters
  - スタック作成・更新時にユーザに入力させる値を定義
  - データ型、デフォルト値、最大、最小値などを設定可能
  - 主なプロパティ
    - Type
      - データ型：String,Number,List<Number>,CommaDelimitedList,AWS固有パラメータ,SSMパラメータタイプ
    - Default
    - NoEcho
      - 入力時に***となる（パスワードなどに使用）
    - AllowedValues
      - 入力可能値の一覧指定（例：["true","false"]）
    - AllowedPattern
      - 正規表現で入力可能なパターンを指定（例：[a-zA-Z]*)
    - MaxLength
    - MinLength
    - MaxValue
    - MinValue
    - Description
    - ConstrailDescription
      - 入力した値がAllowedPatternやMaxLengthなどの制約に引っかかった時に表示する説明

- Mappings
- Conditions
- Transform
- Resources(必須)
- Outputs


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
  - `--capabilities CAPABILITY_NAMED_IAM`をつけるとき