# LambdaでAWS X-Rayによるトレーシングを行う
## IAMロールにポリシーを追加する
- ポリシー名：Project_EnableXRayTraceingForLambda
    - まあなんでもよい
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "xray:GetSamplingStatisticSummaries",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:PutTraceSegments"
            ],
            "Resource": "*"
        }
    ]
}
```
- ポリシー名：Project_PutCloudWatchLogsForLambda
  - 名前はなんでもよい
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "logs:PutLogEvents",
            "Resource": "arn:aws:logs:ap-northeast-1:123456789012:log-group:*:*:*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
            ],
            "Resource": "arn:aws:logs:ap-northeast-1:123456789012:log-group:*"
        }
    ]
}
```
## 管理コンソールからトレースを有効にする
- [アクティブトレースを有効にします]にチェックを入れる
- SAMを使っている場合は、以下を追加する
    ```
    AWS::Serverless::Function
        Tracing:Active
    ```
## boto3などの呼び出しをtraceしたい場合
- path_all()を使う
    ```
    from aws_xray_sdk.core import path_all
    patch_all()
    ```

- 読み込むライブラリを指定する
    ```
    from aws_xray_sdk.core import patch
    patch('botocore','boto3', 'requests')
    ```
    - サポートされているライブラリは以下のとおりです
      - botocore,boto3
      - pynamodb
      - aiobotocore,aioboto3
      - requests,aiohttp
      - httplib,http.client
      - sqlite3
      - mysql-connector-python
  
## Lambda関数をDeployする

