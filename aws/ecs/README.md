# ECS
## ECSの主要要素
### Task Definition
- Taskを構成するコンテナ群定義
  - コンテナ定義
    - イメージの場所
  - 要求CPUとメモリ
  - Taskに割り当てるIAMロール
  - ネットワークモード
    - タスクのコンテナで使用するDockerネットワーキングモード
      - none
        - タスクのコンテナの外部接続なし
      - bridge
        - タスクはDockerの組み込み仮想ネットワークを使用
      - host
        - EC2インスタンスのネットワークインターフェースにコンテナポートを直接マッピング
      - awsvpc
        - タスクごとにENIが割り当てる
        - Fargate起動タイプを使用する場合は、awsvpcを利用する
### Task
- Task Definitionに基づき起動されるコンテナ群
- Task内コンテナは同一ホスト上で実行される
### Service
- Task実行コピー数（n個）を定義
- 起動後、Task実行コピー数を維持
- ELBと連携
- 起動タイプ（EC2、Fargate）を設定
### Cluster
- 実行環境の境界
- IAM権限の境界
  - クラスターに対する操作
- スケジュールされたタスクの実行を設定可能

## ロードバランサー
- awsvpcネットワークモードでサポートされるELBの種別
  - ALB
  - NLB
- Task定義でネットワークモードがawsvpcの場合、ターゲットグループのtarget typeはipとする

## ECSコンテナエージェントの設定
- ECS Optimized AMIのLinuxバリアントを使用して起動された場合は、環境変数を`/etc/ecs/ecs.config`ファイルに設定してからエージェントを開始することができます
  - 使用できるパラメータ
    - ECS_CLUSTER
      - このエージェントが確認するクラスター。この値を定義しない場合、default クラスターが想定されます。default クラスターが存在しない場合は、Amazon ECS コンテナエージェントによってその作成が試みられます。default 以外のクラスターを指定した場合、そのクラスターが存在しないと、登録は失敗します。

## ECSを管理するツール
- https://github.com/nathanpeck/awesome-ecs#build-and-deploy-tools
  - ecs-cli
    - [Amazon ECS コマンドラインリファレンス](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ECS_CLI_reference.html)
## 参考ページ
- [AWS ECSでDockerコンテナ管理入門（基本的な使い方、Blue/Green Deployment、AutoScalingなどいろいろ試してみた）](https://qiita.com/uzresk/items/6acc90e80b0a79b961ce)
- [ECS運用のノウハウ](https://qiita.com/naomichi-y/items/d933867127f27524686a)
- https://aws.amazon.com/jp/premiumsupport/knowledge-center/ecs-create-docker-volume-efs/