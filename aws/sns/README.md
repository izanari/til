# sns
## Lambdaからpublishする
- MessageAttributesをつけてpublishする

```
import boto3

def lambda_handler(event,context):
    
    topicArn = 'arn:aws:sns:ap-northeast-1:xxxxxxxx:xxxxx'
    subject = 'SNSへの送信テストです'
    body = '''ここはbody
テストです
１
２
３
'''
    fromAddress = 'no-reply@aaa.bbb.ccc'
    toAddress = 'hogehoge@aaa.bbb.ccc'
    
    client = boto3.client('sns')
    
    response = client.publish(
        TopicArn=topicArn,
        Subject=subject,
        Message=body,
        MessageAttributes={
            'fromAddress':{
                'DataType':'String',
                'StringValue':fromAddress
                
            },
            'toAddress':{
                'DataType':'String',
                'StringValue':toAddress
            }
            
        }
    )
```