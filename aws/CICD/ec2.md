# CodeCommitからEC2へdeployする
- ロード・バランシングしていないシングル構成のEC2へ非コンパイル言語のアプリケーションをDeployする場合
- CI/CDのCDのみです
## 利用サービス
- CodeCommit
- CodeDeploy
- CodePipeline
- S3やCloudwatchなど暗黙的に利用するサービスは割愛
## 最低限ここは読んでおいてください
- [CodeDeploy AppSpec File リファレンス](https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/reference-appspec-file.html)
  - ECへのデプロイは、`files`,`permissions`,`hooks`が必要
- [EC2/オンプレミス のデプロイ向けの AppSpec の「hooks」セクション](https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-server)
  - 環境変数があるので、それを使うとある程度の切り分けは可能
## インストールおよび設定
- EC2にエージェントをインストールする
  - [Amazon Linux または RHEL 用の CodeDeploy エージェントのインストールまたは再インストール](https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/codedeploy-agent-operations-install-linux.html)
- デフォルトのロールが嫌いな場合は、ロールを作成しておきます。
  - 参考：[ステップ 3: CodeDeploy のサービスロールを作成する](https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/getting-started-create-service-role.html)
- アーティファクトストア用のS3バケットを用意しておく
- CodeCommitに以下をpushしておく
  - デプロイしたいアプリ（ファイル）
  - `appspec.yml`
  - hookさせるスクリプト(シェルファイル）
    - このスクリプトには実行権限をつけておくこと。下記の注意点を参照！ここははまりポイントです
## 設定
- CodePipelineの管理コンソールから設定すればよいです
  - ビルドステージはスキップできます
  - デプロイ設定
    - インプレースデプロイタイプを選択。デプロイ設定は、`CodeDeployDefault.AllAtOnce`を選択します
    - ロードバランサーを有効にするはOFFにします
- EC2上でデバッグしたい時はconfを書き換えます
  - `:verbose: false`をtrueにすればdebug出力されます
  - 設定変更した時には、sudo service codedeploy-agent restart`を行うこと
## サンプル
- ファイル構成とappspec.ymlのサンプルです。
- `BeforeInstall`の中はApacheの停止、`ApplicationStart`ではApacheの起動を行っています。不要かもしれませんが念のため。
### ファイル構成
```
.
├── appspec.yml
├── html
│   ├── common
│   │   └── js
│   │       └── index.js
│   ├── index.html
│   └── index2.html
└── scripts
    ├── ApplicationStart.sh
    └── BeforeInstall.sh
```

### appspec.yml
``` appspec.yml
version: 0.0
os: linux

files:
  - source: html/
    destination: /data/app/html/
  - source: scripts/
    destination: /data/app/scripts/ 

permissions:
  - object: /data/app/html/
    pattern: "**"
    #except:
    owner: apache
    group: root
    mode: 755
    type:
      - directory
      - file

hooks:
  BeforeInstall: 
    - location: "scripts/BeforeInstall.sh"
      timeout: 30
      runas: root
  ApplicationStart: 
    - location: "scripts/ApplicationStart.sh"
      timeout: 30
      runas: root 


```
## 注意点
- hooksで指定するスクリプトはリポジトリに含めておく。その際、実行権限をつけておく必要がある。gitの場合は、`git add`する前にローカルPC上で+xをつけておくこと。`appspec.yml`でスクリプトに実行権限をつけても無駄です。忘れていると実行されずに、成功扱いで処理が継続します。これは、hooksのスクリプトはインストール後のファイルが実行されるのではなく、codedeploy-agentが管理しているディレクトリのファイルが実行されるからです。
  - hooksで実行されるスクリプト
    - /opt/codedeploy-agent/deployment-root/配下にあるファイル
  - permissionsで指定しているファイル
    - インストールされたファイル（フルパスで指定してますからね）
  - AWSの公式ドキュメントには明確な記載はありませんので以下を参考ください 
    - 参考URL: [CodeDeployフックのベストプラクティス](https://dev.classmethod.jp/cloud/aws/best-practice-of-code-deploy-hooks/)
- hooksで指定するスクリプト
  - configファイルをgitリポジトリに含んだ場合は、インストール後のファイルをcpしてください。hooksのlocationのように、config/config.json　と書いても参照できません。
``` AfterInstall.sh
#!/bin/sh

# AfterInstall.sh 
CONFIGDIR='/data/var/www/pcx/config'
INSTALLDIR='/data/var/www/pcx/html/powercmsx'
cp $CONFIGDIR/config.json $INSTALLDIR/config.json
cp $CONFIGDIR/db-config.php $INSTALLDIR/db-config.php
chown apache:root $INSTALLDIR/config.json
chown apache:root $INSTALLDIR/db-config.php
```

## デバッグ等で参照するファイル
- CodeDeploy Agentのログファイル
  - /var/log/aws/codedeploy-agent/codedeploy-agent.log
- hooksで実行されたスクリプトのログ
  - /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log
- 設定ファイル
  - /etc/codedeploy-agent/conf/codedeployagent.yml
## 参考するサイト
- https://dev.classmethod.jp/referencecat/aws-codedeploy/
