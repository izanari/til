# AWS Elastic Beanstalk
- 定番構成の構築・アプリデプロイの自動化サービス
- 速く簡単にアプリケーションをデプロイ可能
- インフラストラクチャの準備＆運営からアプリケーションスタックの管理まで自動化
- Auto Scalingによりコストを抑えながらスケーラビリティを確保
- Java,PHP,Ruby,Python,Node.js,.NET,Docker,Goに対応
- アプリケーションの保存、実行に必要なAWSリソース（EC2,S3,RDS,ELB)に対してのみ課金される
- アプリケーションの開発にだけフォーカスすればよく、そこから下のHTTP Server〜Hostまでは、EBが用意してくれる
## 構成
### アプリケーション
- トップレベルの論理単位
- バージョン、環境、環境設定が含まれている入れ物
- Amazon S3上でのバージョン管理を行う
- 異なる環境に異なるバージョンをデプロイ可能とする

### 環境のタイプ
- ロードバランシング、Auto Scaling環境
  - 高い可用性と伸縮自在性を兼ね備えた構成
  - ウェブサーバ環境は、ELB+AutoScaling
  - ワーカー環境は、SQS+Auto Scaling
- シングルインスタンス環境
  - EC2 1台構成(Auto Scalingでmax,minが1に設定されている)
  - 開発環境などの構築のため、低コストで構築可能

### ウェブサーバー環境
- スケーラブルなウェブアプリケーションを実行
  - ELB+Auto Scalingでスケーラブルな環境
    - ホストマネージャーがデプロイ・監視などを自動的に実施
  - 環境ごとにDNS名を付与

### ワーカー環境
- バッチアプリケーションをElastic Beanstalkで
  - SQS+Auto Scaingでスケーラブルなバッチ処理基板
  - Scale-InしてもメッセージはSQSに残るため後から処理
  - Sqsd
    - Workerホスト内で動作するデーモン
    - Webアプリからの応答
      - 200 OKの場合は、SQSからメッセージを削除
      - 200 OK以外の場合は、VisibilityTimeout(SQSの設定)後にSQSからのメッセージが取得可能
      - 応答無しの場合は、Inactivity Timeout(Elastic Beanstalkの設定)後にSQSからメッセージが取得可能（リトライ）
    - DLQ
      - 何度実行しても200 OK以外でSQSのキューに残り続けてしまうメッセージを別のキューに移動
  - 定期的なタスク実行
    - cron.yaml

### アプリケーション、環境を構築する方法
- AWS Management Console
- 各種IDEツール
  - AWS Toolkit for Visual Studio
  - AWS Toolkit for Eclipse
- 各種SDK,AWS CLI
- EB Command Line Interface(EB CLI)
  - ハイレベルな操作が可能なコマンドラインツール
  - 頻繁にデプロイが繰り返される環境下での自動化に便利

### デプロイ
- Elastic Beanstalkではどちらの方式も簡単に実現可能
#### In Place Deployment(Rolling Deploy)
- インスタンスは現行環境のものをそのまま利用し、新しいリビジョンのコードをその場で反映させる
#### Blue/Green Deployment(Red/Black Deployment)
- 新しいリビジョンのコードを、新しいインスタンスに反映させ、インスタン毎入れ替える
#### 選択肢
- デプロイポリシーに従った既存環境へのデプロイ
  - All at once --> (In Place)
    - 展開に必要な時間を最短にするデプロイ方法
  - Rolling --> (In Place)
    - [Rolling] (ローリング) デプロイでは、Elastic Beanstalk は環境の EC2 インスタンスを複数のバッチに分割し、アプリケーションの新しいバージョンを一度に 1 つのバッチにデプロイするため、環境内の残りのインスタンスは古いアプリケーションバージョンを実行した状態になります。つまりローリングデプロイ中は、アプリケーションの古いバージョンでリクエストを処理するインスタンスもあり、新しいバージョンでリクエストを処理するインスタンスも存在します。
  - Rolling with additional batch --> (In place & Blue/Green )
  - Immutable --> ( Blue/Green )
    - [Immutable] デプロイは、変更不可能な更新を実行して、古いバージョンを起動しているインスタンスと並行しながら、別の Auto Scaling グループにあるアプリケーションの新しいバージョンを起動している新しいインスタンスのフルセットを起動します。[Immutable] デプロイは、部分的に完了したローリングデプロイにより発生する問題を防止できます。新しいインスタンスがヘルスチェックをパスしなかった場合、Elastic Beanstalkはそれを終了し、元のインスタンスをそのまま残します。
- URL Swap による既存環境と新環境の切り替え --> ( Blue/Green )
- Amazon Route53 を利用した既存環境と新環境の切り替え --> ( Blue/Green )
#### デプロイに関する設定
- バッチタイプ
  - 一度にデプロイを反映させる台数（バッチ）をどう決めるかを設定する
    - 割合（％）：現在起動中のインスタンスの合計数に対する割合で構成
    - 固定：各バッチにデプロイするインスタンスの数または割合
  - バッチタイプ、バッチサイズはRolling,Rolling with additional batchのときのみ設定可能
#### まとめ
|方式|失敗時の影響|時間|ダウンタイム|ELB暖気|DNS切替|ロールバック|デプロイ先|
|---|---|---|---|---|---|---|---
|All at one|ダウンタイム発生|1|ダウンタイム発生|不要|無し|再デプロイ|既存
|Rolling|1バッチ分だけサービスアウト|2（バッチサイズに依存）|無し|不要|無し|再デプロイ|既存
|Rolling with additional batch|最初のバッチであれば最小|3(バッチサイズに依存)|無し|不要|無し|再デプロイ|新規+既存
|Immutable|最小|4|無し|不要|無し|再デプロイ|新規
|URL swap|最小|4|無し|必要|有り|URL swap|新規
|Route53による切替|最小|4|無し|必要|有り|URL swap|新規

## 設定変更
### 環境設定
- インスタンスタイプの変更
- ELBのヘルスチェック設定変更
- デプロイポリシーの変更

### プラットホームの更新
- 新バージョンのAMI
- OS,Web,App,Serverのマイナーアップグレード
- バグフィックス

#### マネージドプラットホーム更新
- 自動的に最新するよう設定可能
  - メンテナンスウィンドウの指定
  - 更新対象のバージョン指定
  - Immutable方式で実施される
  - Windows(.net)環境はサポート対象外

### 環境設定
- `eb config`
- 以下のいずれかの方法でカスタマイズ可能
  - 作成時に直接設定
    - `eb create`のオプション
  - 保存済み設定
    - 起動中の環境で使用している環境設定を保存可能
      - Amazon S3に設定ファイルを保存
    - 保存した環境設定を再利用可能
      - 環境作成時に指定
      - 起動中の環境に適用
    - `eb config save`
  - `.ebextensions`
    - 環境で使用しているリソースの高度なカスタマイズが可能
    - 環境に対する様々な操作を自動化＆集約可能
    - ユースケース 
      - カスタム環境設定の指定
      - ソフトウェアのインストール
      - インストールしたソフトウェアの実行
      - デフォルトの環境には用意されていないAWSリソースの作成。例えば、DynamoDBなど。
    - ソースルートで、`.ebextensions`フォルダに設定ファイルを追加
      - 設定ファイルは複数配置可能
    - Tips
      - セクション毎にファイルを分割するのを推奨
        - 大きいファイルはメンテナンスが大変
          - 設定ファイルはアルファベット順に処理される
      - インストールするパッケージのバージョンを明記する
      - カスタムAMIとのトレードオフを検討する
#### 設定ファイル
- Dockerrun.aws.json
- cron.yml
- env.yml
## モニタリング
- 基本ヘルスサポート
  - 環境のヘルスサポート
  - ELBのヘルスチェック
  - CloudWatchメトリクス
- 拡張ヘルスサポート
  - OSレベルのメトリクス
  - アプリケーションレベルのメトリクス
  - EnvironmentHealth
  - etc....
- EB CLIでモニタリング
  - `eb health --reresh`
- マネジメントコンソール上でモニタリング
- CloudWatch Logsを使ってログ監視
  - 書き込み権限はIAM Roleで行う

## ライフサイクル
- コンソールもしくはEB CLIを使用して新しいバージョンのアプリケーションをアップロードするたびに、Elastic Beanstalkはアプリケーションバージョンを作成する。

## 便利機能
- SSH接続はEB CLIで行うことができる
  - `eb ssh -i xxxxx`
### Docker Support
- Single Container
  - EC2インスタンスの中で単一のDockerコンテナを実行
  - Beanstalkの標準的であらかじめ定義された設定の活用
- Multi Container
  - ECSを使用
  - `Dockerrun.aws.json`を使ったより柔軟な構成が可能になる
### Environment間リンク機能
- SQSキューを介して疎結合なアーキテクチャを実現
### 時間指定のスケーリング
- Time-based Scaling
### インスタンスのログ
- Linux
  - /var/log/eb-activity.log
  - /var/log/eb-commandprocessor.log
  - /var/log/eb-version-deployment.log
### Aliasレコードのサポート

## 設計上の考慮事項
- ステートレス
  - Auto Scalingを利用しやすいことを意識すること
  - スケールアウト/インしやすいように構築すること
- 永続データの格納場所
  - Beanstalk環境外に配置する
  - マネージドサービスを利用する 
    - S3
    - DynamoDB
    - RDS
## 参考情報
- [AWS Elastic Beanstalk ドキュメント](https://docs.aws.amazon.com/ja_jp/elastic-beanstalk/?id=docs_gateway)
- [トラブルシューティング](https://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/troubleshooting.html)
- [AWS ナレッジセンター](https://aws.amazon.com/jp/premiumsupport/knowledge-center/)
- [Beanstalk – 特集カテゴリー –](https://dev.classmethod.jp/referencecat/aws-elastic-beanstalk/)

## EB CLIをインストールする
- GitHubに公開されています
  - https://github.com/aws/aws-elastic-beanstalk-cli-setup
  ```
  git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
  cd aws-elastic-beanstalk-cli-setup/scripts
  ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer
  （インストール処理が始まります）
  ```
- exeにパスを通します
  ```
  echo 'export PATH="/YourPath/.ebcli-virtual-env/executables:$PATH"' >> ~/.bash_profile && source ~/.bash_profile
  ```
- 動作確認します
  ```
  % eb --version
  EB CLI 3.15.3 (Python 3.7.2)
  ```
### 参照
- [Elastic Beanstalk コマンドラインインターフェイス（EB CLI）](https://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/eb-cli3.html)
- [プロジェクトフォルダの代わりに圧縮ファイルをデプロイする](https://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/eb-cli3-configuration.html#eb-cli3-artifact)

## 参照サイト
- [ダウンタイム、データベース同期の問題、またはデータの損失なしで Amazon RDS インスタンスを Elastic Beanstalk 環境から分離するには、どうすれば良いですか?](https://aws.amazon.com/jp/premiumsupport/knowledge-center/decouple-rds-from-beanstalk/)
- [デプロイポリシーと設定](https://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/using-features.rolling-version-deploy.html)
- [変更不可能な環境の更新](https://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/environmentmgmt-updates-immutable.html)