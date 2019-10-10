# ecs-cli
- AWS純正のECS管理ツールです
- ソースは、[aws/amazon-ecs-cli](https://github.com/aws/amazon-ecs-cli):octocat:にあります
## ECS CLIをインストールする
- [Amazon ECS CLI のインストール](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
- 環境変数をセットする
    ```
    export AWS_ACCESS_KEY_ID=hogehoge
    export AWS_SECRET_ACCESS_KEY=fugafuga
    ```
## 起動する
- クラスタの名前を指定する  
    ```
    ecs-cli configure --region ap-northeast-1 --cluster test-ecs-cluster
    ```
    - デフォルトのcluster名を設定しておくと、ecs-cliで`--cluster`をつける必要がなくなります

- ECSクラスタを起動します
  - `ecs-cli up`に下記のようなパラメータを付与します。`size`が起動したいEC2インスタンスです
    ```
    #/bin/sh 

    ecs-cli up \
    --keypair ${KEYS} \
    --capability-iam \
    --cluster ${CLUSTER_NAME} \
    --size 2 \
    --instance-type ${INSTANCE_TYPE} \
    --launch-type EC2 \
    --region ap-northeast-1 \
    --extra-user-data user-data.txt \
    --force
    ```
  - VPCやサブネットをパラメータから指定をしない場合は、自動で作成してくれます。何が作成されたか確認する場合は、CloudFormationのリソースを見るとわかります。指定をしたい場合は、別途作成しておき、パラメーターで指定を行います。
  - `extra-user-data`はEC2インスタンスのユーザーデータのこと。起動させるEC2インスタンスで何かやらせたい場合は、ここに記述すること
    - 例えば、SSMのセッションマネージャーでEC2インスタンスを管理したい場合は、エージェントのインストールおよび起動させる。IAM roleも気に留めること。

- コンテナを起動させます
    - ecs-cliはDocker Composeに対応しています。以下のようなcomposeファイルを用意します。

        ```
        version: '2'

        services:
        apache:
            image: httpd
            ports:
            - "80:80"
            volumes:
            - "/var/www/task1/html:/usr/local/apache2/htdocs"
            logging:
            driver: awslogs
            options:
                awslogs-group: ecs-test 
                awslogs-region: ap-northeast-1 
                awslogs-stream-prefix: apache
        ```
    - ecsパラメータファイルを用意します
      - ファイル名は`ecs-params.yml`
      - service_name（下の`apache` は実行するコンテナの名前と一致させます
      - メモリの指定がうまくいってない
        ```
        version: 1
        task_definition:
        family: ecs-test-v1
        ecs_network_mode: bridge
        service:
            apache:
                essential: true
                cpu_shares: 100
                mem_limit: 256
                healthcheck:
                test: ["CMD","curl -f http://localhost:80"]
                interval: 10s
                timeout: 15s
                retries: 5   
        run_params:
        network_configuration:
            awsvpc_configuration:
            subnets:
                - subnet-hogehoge
                - subnet-hogehoge
        ```
            - subnetsは各自の環境にあわせます
    - まずはタスク定義を作成します
        ```
        #!/bin/sh

        ecs-cli compose \
        --verbose \
        --file ${COMPOSE_FILE} \
        --cluster ${CLUSTER_NAME} \
        --project-name ${FAMILY_NAME} \
        --ecs-params ${ECS_PARAMS_FILE} \
        --region ap-northeast-1 \
        create
        ```

    - 起動します
        ```
        #!/bin/sh

        ecs-cli compose \
        --file ${COMPOSE_FILE} \
        --ecs-params ${ECS_PARAMS_FILE} \
        --project-name ${FAMILY_NAME} \
        start \
        --create-log-groups \
        --cluster ${CLUSTER_NAME} 
        ```
        - これだけでは、サービスとしては登録されていないため。別途登録する必要があります。
- コンテナを停止させる
    ```
    ecs-cli compose down
    ```
## 削除する
- ECSクラスタを削除する
    ```
    ecs-cli down
    Are you sure you want to delete your cluster? [y/N]
    ```
    - CloudFormationスタックが削除されるので、ecs-cliで作成したリソースがすべて削除されます

## その他コマンド
### コンテナインスタンスの数を変更したい
```
ecs-cli scale --capability-iam --size 1
INFO[0001] Waiting for your cluster resources to be updated... 
INFO[0001] Cloudformation stack status                   stackStatus=UPDATE_IN_PROGRESS
INFO[0061] Cloudformation stack status                   stackStatus=UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
```
- size の数字を変更することでインスタンス数を変更することができます
- このコマンドでASGの希望するキャパシティを変更してくれます
- EC2インスタンスは、`stop`ではなく、`terminated`になるので、必要なファイルがあれば、事前にバックアップしておきましょう
  - というか、そのような運用をしてはいけないってことですかね


## 参考サイト
- [Amazon ECS コマンドラインリファレンス](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ECS_CLI_reference.html)
- [Amazon ECS パラメータの使用](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-ecsparams.html)
- [タスク定義パラメータ](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/task_definition_parameters.html)
- [ECS CLIを使ってDocker Composeのファイルを使ってECSにデプロイする](https://qiita.com/toshihirock/items/824a86da51015350a051)
- 