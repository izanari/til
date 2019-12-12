# CloudWatch Logs
## ログをS3へエクスポートする
- [コンソールを使用したログデータの Amazon S3 へのエクスポート](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/S3ExportTasksConsole.html)
- バケットポリシーは以下のように設定する
```
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Action": "s3:GetBucketAcl",
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::my-exported-logs",
          "Principal": { "Service": "logs.ap-northeast-1.amazonaws.com" }
      },
      {
          "Action": "s3:PutObject" ,
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::my-exported-logs/random-string/*",
          "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } },
          "Principal": { "Service": "logs.ap-northeast-1.amazonaws.com" }
      }
    ]
}
```
