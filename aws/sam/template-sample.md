# テンプレートの書き方
## AWS::Serverless::Function 
### Policies
- 複数のポリシーを定義したい場合
  ```
    Policies:
            - {
              "Version": "2012-10-17",
              "Statement":[
                {
                  "Sid": "VisualEditor0",
                  "Effect": "Allow",
                  "Action": [
                    "ssm:SendCommand",
                  ],
                  "Resource": "*"
                } 
              ]
            }
            - {
              "Version": "2012-10-17",
              "Statement":[
                {
                  "Sid": "VisualEditor0",
                  "Effect": "Allow",
                  "Action": [
                    "iam:PassRole"
                  ],
                  "Resource": !Sub "arn:aws:iam::${AWS::AccountId}:role/prod-sns-from-ssm"
                }
              ]
            }
    ```

- 自動的に付与される管理ポリシー
  - `arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`は勝手に付与されてしまいます
- `Role`プロパティがセットされた場合は、`Policies`は無視される
- SAMが定義しているpolicyを使うことも可能
  - [テンプレート](https://github.com/awslabs/serverless-application-model/blob/develop/examples/2016-10-31/policy_templates/all_policy_templates.yaml)
    - ```
      - EC2DescribePolicy: {}
      ```
      パラメーターが必要ない場合でも空dictionaryを渡す必要があるポリシーがあります
### Environment
- Lambdaの環境変数を定義したい
    ```
        Type: AWS::Serverless::Function 
        Properties:
            Environment:
                Variables:
                    env1: value1
                    env2: value2