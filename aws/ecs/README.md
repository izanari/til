# ECS
## ECSの主要要素
### Task Definition
- [タスク定義パラメータ](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_definition_parameters.html#ContainerDefinition-portMappings)
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
        - 動的ホストポートマッピングが利用できる
      - host
        - EC2インスタンスのネットワークインターフェースにコンテナポートを直接マッピング
        - 動的ホストポートマッピングが利用できない
      - awsvpc
        - タスクごとにENIが割り当てる
          - インスタンスタイプによりENIの上限があるため、注意すること
        - Fargate起動タイプを使用する場合は、awsvpcを利用する
        - 動的ホストポートマッピングが利用できない
- 定義ファイルの雛形生成方法
  - `aws ecs register-task-definition --generate-cli-skeleton > hoge-ecs-task-def.json`
### Task
- Task Definitionに基づき起動されるコンテナ群
- Task内コンテナは同一ホスト上で実行される
### Service
- [サービス定義パラメータ](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/service_definition_parameters.html)
- Task実行コピー数（n個）を定義
- 起動後、Task実行コピー数を維持
- ELBと連携
- 起動タイプ（EC2、Fargate）を設定
- スケジューラーは２つある
  - REPLICA
    - クラスター全体で必要数のタスクを配置して維持する
  - DAEMON
    - コンテナインスタンスごとに１つのタスクのみをデプロイする
      - Fargateはサポートしていない
- サービス定義パラメータ
  - placementStrategy
    - binpack
      - field パラメータで指定したリソース(`cpu` or `memory`)の利用可能量が最も少ない利用可能候補にタスクを配置します。残メモリのもっとも少ないインスタンスに配置される。
    - random
      - タスクを利用可能なインスタンスにランダムに配置します
      - field パラメータは使用しない
    - spred
      - field パラメータに基づいて、利用可能候補間で均等にタスクを分散して配置する
      - field パラメータは、[Amazon ECS Task Placement](https://aws.amazon.com/jp/blogs/compute/amazon-ecs-task-placement/)を参照
    ```
    placementStrategy
            {
                "type": "binpack",
                "field": ""
            }
    ```
- CLI
  - サービスを作成する
    - schedulingStrategyがDAEMONの時は、desired-countは必要ない
    ```
    aws ecs create-service --service-name ecs-sample --task-definition ecs-sample-task --desired-coint 10
    ```

### Cluster
- タスクまたはサービスの論理グループ
- クラスターには、Farget,EC2のどちらの起動タイプもタスクに含めることができる
- 実行環境の境界
- IAM権限の境界
  - クラスターに対する操作
- スケジュールされたタスクの実行を設定可能
- [クラスタークエリ言語](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/cluster-query-language.html)
## サービスロードバランシング（ロードバランサー）
- ECSでは、ALB,NLB,CLBをサポートしている
  - おすすめはALB
- awsvpcネットワークモードでサポートされるELBの種別
  - ALB
  - NLB
- Task定義でネットワークモードがawsvpcの場合、ターゲットグループのtarget typeはipとする
  - インスタンスではなく、ENIに関連付けされるため
- ALBもしくはNLBを使用するサービスの場合、サービスに５つ以上のターゲットグループをアタッチすることはできません
- ALB
  - 動的ホストポートマッピングをサポートしている
  - コンテナポートを80,ホストポートを0の場合、32768〜61000ポートが選択されます

## ECSコンテナエージェントの設定
- ECS Optimized AMIのLinuxバリアントを使用して起動された場合は、環境変数を`/etc/ecs/ecs.config`ファイルに設定してからエージェントを開始することができます
  - [Amazon ECS コンテナエージェントの設定](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-agent-config.html)
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
- https://ecsworkshop.com/
- [ECS で Docker volume plugin を使って EFS 連携してみた](https://dev.classmethod.jp/tool/docker/try-efs-with-ecs-using-docker-volume-plugin/)
- [Dockerコンテナの作成からECSの動的ポート＋ALBでロードバランスするまで【cloudpack大阪ブログ】](https://qiita.com/taishin/items/eb759a8ec0c583fc5ebd)

- https://dev.classmethod.jp/cloud/aws/ecs-resources-knowledge-for-ecs-with-ec2/
- https://tech.yayoi-kk.co.jp/entry/2018/12/19/150000
- https://aws.amazon.com/jp/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
- 