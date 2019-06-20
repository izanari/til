# AWS Systems Manager
## SSMの起動、再起動
- https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-manual-agent-install.html#agent-install-al
  
## amazon-ssm-agentを自動更新するには
```
aws ssm create-association --targets Key=tag:Name,Values=fugafuga --name AWS-UpdateSSMAgent --schedule-expression "cron(30 3 ? * MON *)" --profile hogehoge

```
- cron式はJSTではなく、UTC表記になります
  - https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/reference-cron-and-rate-expressions.html

### 参考ドキュメント
- [自動的に SSM エージェント (CLI) を更新する](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-state-cli.html)

## ログをローテートさせるには
- /etc/amazon/ssm/seelog.xml を作成する
```
<seelog type="adaptive" mininterval="2000000" maxinterval="100000000" critmsgcount="500" minlevel="info">
    <exceptions>
        <exception filepattern="test*" minlevel="error"/>
    </exceptions>
    <outputs formatid="fmtinfo">
        <console formatid="fmtinfo"/>
        <rollingfile type="date" filename="/var/log/amazon/ssm/amazon-ssm-agent.log" datepattern="20060102" maxrolls="90"/>
        <filter levels="error,critical" formatid="fmterror">
            <rollingfile type="size" filename="/var/log/amazon/ssm/errors.log" datepattern="20060102" maxrolls="90"/>
        </filter>
    </outputs>
    <formats>
        <format id="fmterror" format="%Date %Time %LEVEL [%FuncShort @ %File.%Line] %Msg%n"/>
        <format id="fmtdebug" format="%Date %Time %LEVEL [%FuncShort @ %File.%Line] %Msg%n"/>
        <format id="fmtinfo" format="%Date %Time %LEVEL %Msg%n"/>
    </formats>
</seelog>
```
## SSMパラメーターの値をLambdaが取得する時にキャッシュさせる
- https://github.com/alexcasalboni/ssm-cache-python

### 参考ドキュメント
- http://rikuga.me/2017/12/15/ssm-agent-logrotate/

