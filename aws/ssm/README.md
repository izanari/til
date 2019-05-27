# AWS Systems Manager
## amazon-ssm-agentを自動更新するには
```
aws ssm create-association --targets Key=tag:Name,Values=fugafuga --name AWS-UpdateSSMAgent --schedule-expression "cron(30 3 ? * MON *)" --profile hogehoge

```
- cron式はJSTではなく、UTC表記になります
  - https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/reference-cron-and-rate-expressions.html

### 参考ドキュメント
- [自動的に SSM エージェント (CLI) を更新する](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-state-cli.html)