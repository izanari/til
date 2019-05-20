# Lambda
## 参照URL
- [AWS Lambda 関数を使用する際のベストプラクティス](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/best-practices.html)
- 

## CloudWatchのエラーカウントをあげる
- ただしこれはベストプラクティスに反します
```
client = boto3.client('cloudwatch')
client.put_metric_data(
            Namespace = 'AWS/Lambda',
            MetricData=[
                {
                    'MetricName': 'Errors',
                    'Dimensions': [
                        {
                            'Name': 'FunctionName',
                            'Value': context.function_name
                        }
                    ],
                    'Timestamp': datetime.datetime.today(),
                    'Value': 1,
                    'Unit': 'Count'
                }
            ]
        )
```
