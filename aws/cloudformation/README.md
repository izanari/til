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
  - [パラメータ](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)
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
  - SSMパラメータを使うことができる。[ここ](https://aws.amazon.com/jp/blogs/mt/integrating-aws-cloudformation-with-aws-systems-manager-parameter-store/)を参照しましょう
    - 事前に登録しておく
      ```
      # Create a parameters for Dev and Prod environments in Systems Manager Parameter Store
      aws ssm put-parameter --name myEC2TypeDev --type String --value “t2.small”
      aws ssm put-parameter --name myEC2TypeProd --type String --value “m4.large”

      ```
    - テンプレートではこのように指定する
      ```
        # Reference/use existing Systems Manager Parameter in CloudFormation
        Parameters:
          InstanceType :
            Type : 'AWS::SSM::Parameter::Value<String>'
            Default: myEC2TypeDev
          KeyName :
            Type : 'AWS::SSM::Parameter::Value<AWS::EC2::KeyPair::KeyName>'
            Default: myEC2Key
          AmiId:
            Type: 'AWS::EC2::Image::Id'
            Default: 'ami-60b6c60a'
            
        Resources :
          Instance :
            Type : 'AWS::EC2::Instance'
            Properties :
              Type : !Ref InstanceType
              KeyName : !Ref KeyName
              ImageId : !Ref AmiId 
       ```
      - 参照ページ
        - [動的な参照を使用してテンプレート値を指定する](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/dynamic-references.html)
- Mappings
- Conditions
  - リソースを作成するかどうか
    ```
    Conditions:
      CreateResource: !Equals [ !Ref Env,Prod ]

    Resources:
      EC2Instance:
        Type: "AWS::EC2::Instance"
        Condition: CreateResource
        Properties:
          InstanceType: t3.small
    ```

- Transform
- Resources(必須)
- Outputs
  - AWSアカウント毎にリージョン内でユニークなエクスポート名である必要がある
  - リージョンを超えて参照することはできない

## ヘルパースクリプト
- [CloudFormation ヘルパースクリプトリファレンス](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/cfn-helper-scripts-reference.html)
- cfn-init
  - リソースメタデータの取得と解釈、パッケージのインストール、ファイルの作成、およびサービスの開始で使用します。
- cfn-signal
  - CreationPolicy または WaitCondition でシグナルを送信するために使用し、前提となるリソースやアプリケーションの準備ができたときに、スタックの他のリソースを同期できるようにします。
- cfn-get-metadata
  - 特定のキーへのリソースまたはパスのメタデータを取得するために使用します。
- cfn-hup
  - メタデータへの更新を確認し、変更が検出されたときにカスタムフックを実行するために使用します。
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

- 動的なパラメータを利用する
  - SSMパラメータに格納しておく方法
    - `TestText`という名前を設定しておく
    - `${Env}-TestText`という名前を設定しておく
```
AWSTemplateFormatVersion: 2010-09-09
Description: |
  
Parameters:
  Env:
    Type: String
    Default: dev 
    AllowedValues:
      - dev
      - stg
      - prod
  SsmParamVersion:
    Type: String
    Default: 1
Resources:
  LogicalID:
    Type: "AWS::IAM::User"
    Properties:
      Tags:
        - Key: Test 
          Value: '{{resolve:ssm:TestText:1}}'
      UserName: test-test
  IamUser2:
    Type: "AWS::IAM::User"
    Properties:
      Tags:
        - Key: Test 
          Value: !Sub '{{resolve:ssm:${Env}-TestText:${SsmParamVersion}}}'
      UserName: test-test2
```

## サンプル
- [awslabs](https://github.com/awslabs/aws-cloudformation-templates)

## 気をつけるところ
- 全てをCloudFormationではできないことがある
  - `AWS::CertificateManager::Certificate`を`ValidationMethod: DNS `した時、すぐに承認されないとロールバックされてリクエストが消されてしまいます。ロールバックは180分までしか設定できないから、手動で作成したほうが無難。
  - `--capabilities CAPABILITY_NAMED_IAM`をつけるとき