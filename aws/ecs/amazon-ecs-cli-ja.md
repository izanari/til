# aws-cli
## Usging CLI
ECSは現在、タスクとサービス用にEC2とFARGATEの2つの異なる起動タイプを提供しています。 FARGATE起動タイプを使用すると、ユーザーは独自のコンテナインスタンスを管理する必要がなくなります。

ECS-CLIでは、`--launch-type`フラグを使用してクラスターを起動するときに、いずれかの起動タイプを指定できます（ECSクラスターの作成を参照）。 `--default-launch-type`フラグを使用して特定の起動タイプを使用するようにクラスターを構成することもできます（クラスター構成を参照）。

また、クラスターに構成されている起動タイプに関係なく、構成アップまたは構成サービスアップでタスクまたはサービスに使用する起動タイプを指定することもできます（タスクの開始/実行を参照）。

### Creating an ECS Cluster
Amazon ECS CLIをインストールして認証情報を設定したら、ECSクラスターを作成する準備ができました。クラスターを作成するための基本的なコマンドは次のとおりです。

```
$ ecs-cli up
```
（使用可能なオプションをすべて表示するには、ecs-cli up --helpを実行します）

たとえば、EC2起動タイプを使用して2つのAmazon EC2インスタンスでECSクラスターを作成するには、次のコマンドを使用します。

```
$ ecs-cli up --keypair my-key --capability-iam --size 2
```

ecs-cli upによって要求されたリソースを作成するには数分かかります。クラスターでタスクを実行する準備ができたことを確認するには、AWS CLIを使用してECSインスタンスが登録されていることを確認します。

```
$ aws ecs list-container-instances --cluster your-cluster-name
{
    "containerInstanceArns": [
        "arn:aws:ecs:us-east-1:980116778723:container-instance/6a302e06-0aa6-4bbc-9428-59b17089b887",
        "arn:aws:ecs:us-east-1:980116778723:container-instance/7db3c588-0ef4-49fa-be32-b1e1464f6eb5",
    ]
}
```

EC2インスタンスに加えて、デフォルトで作成される他のリソースには次のものが含まれます。
- Autoscaling Group
- Autoscaling Launch Configuration
- EC2 VPC
- EC2 Internet Gateway
- EC2 VPC Gateway Attachment
- EC2 Route Table
- EC2 Route
- 2 Public EC2 Subnets
- 2 EC2 SubnetRouteTableAssocitaions
- EC2 Security Group

フラグオプションを使用して、独自のリソース（サブネット、VPC、セキュリティグループなど）を提供できます。

注：ecs-cli upによって作成されたデフォルトのセキュリティグループは、デフォルトでポート80のインバウンドトラフィックを許可します。別のポートからのインバウンドトラフィックを許可するには、開くポートを--portオプションで指定します。デフォルトのセキュリティグループにさらにポートを追加するには、AWSマネジメントコンソールでEC2セキュリティグループに移動し、「ecs-cli」を含むセキュリティグループを検索します。セキュリティグループへのルールの追加のトピックの説明に従って、ルールを追加します。

または、`--security-group`オプションを使用して、1つ以上の既存のセキュリティグループIDを指定できます。

`--empty`または`--e`フラグを使用して、空のECSクラスターを作成することもできます。

```
ecs-cli up --cluster myCluster --empty
```
これはcreate-clusterコマンドと同等であり、クラスターに関連付けられたCloudFormationスタックを作成しません。

#### AMI
`--image-id`flagを使用して、EC2タイミングで使用するAMIを指定できます。または、イメージIDを指定しない場合、ECS CLIは推奨されるAmazon Linux 2 ECS Optimized AMIを使用します。デフォルトでは、このAMIのx86バリアントが使用されます。ただし、`--instance-type`を使用してA1ファミリーの必要を指定する場合、ECS Optimized AMIのarm64バージョンが使用されます。注：arm64 ECS Optimized AMIは、一部の地域でのみサポートされています。Amazon ECS最適化Amazon Linux 2 AMIをご覧ください。

#### User Data
EC2起動タイプの場合、ECS CLIは常に次のユーザーデータを含むEC2インスタンスを作成します。
```
#!/bin/bash
echo ECS_CLUSTER={ clusterName } >> /etc/ecs/ecs.config
```
このユーザーデータは、EC2インスタンスにECSクラスターに参加するよう指示します。オプションで`--extra-user-data`を使用して追加のユーザーデータを含めることができます。このフラグは引数としてファイル名を取ります。フラグを複数回使用して、複数のファイルを指定できます。追加のユーザーデータは、シェルスクリプトまたはcloud-initディレクティブです。詳細については、EC2のドキュメントを参照してください。 ECS CLIはすべてのユーザーデータを取得し、それをEC2インスタンスのcloud-initで使用できるMIME Multipartアーカイブにパックします。 ECS CLIでは、既存のMIME Multipartアーカイブを`--extra-user-data`で渡すこともできます。 CLIは既存のアーカイブをアンパックしてから、最終アーカイブに再パックします（すべてのヘッダーとコンテンツタイプ情報を保持します）。追加のユーザーデータを指定する例を次に示します。
```
ecs-cli up \
  --capability-iam \
  --extra-user-data my-shellscript \
  --extra-user-data my-cloud-boot-hook \
  --extra-user-data my-mime-multipart-archive \
  --launch-type EC2
  ```

#### Creating a Fargate cluster
```
ecs-cli up --launch-type FARGATE
```
これにより、コンテナインスタンスなしでECSクラスターが作成されます。デフォルトでは、これにより次のリソースが作成されます。
- EC2 VPC
- EC2 Internet Gateway
- EC2 VPC Gateway Attachment
- EC2 Route Table
- EC2 Route
- 2 Public EC2 Subnets
- 2 EC2 SubnetRouteTableAssocitaions

作成が完了すると、サブネットとVPC IDが端末に出力されます。その後、ECS ParamsファイルのサブネットIDを使用して、Fargateタスクを起動できます。

AWS Fargateの使用の詳細については、ECS CLI Fargateチュートリアルを参照してください。

## Starting/Running Tasks

クラスターの作成後、ECSクラスターでタスク（コンテナーのグループ）を実行できます。最初に、Docker Compose構成ファイルを作成します。 Docker Composeを使用して、構成ファイルをローカルで実行できます。 ecs-cliでサポートされている特定の構成バージョンとフィールドに関する情報は、ここにあります。

以下は、Webページを作成するDocker Compose構成ファイルの例です。
```
version: '2'
services:
  web:
    image: amazon/amazon-ecs-sample
    ports:
     - "80:80"
```
Amazon ECSで設定ファイルを実行するには、`ecs-cli compose up`を使用します。これにより、ECSタスク定義が作成され、ECSタスクが開始されます。たとえば、`ecs-cli compose ps`で実行されているタスクを確認できます。
```
$ ecs-cli compose ps
Name                                      State    Ports                     TaskDefinition
fd8d5a69-87c5-46a4-80b6-51918092e600/web  RUNNING  54.209.244.64:80->80/tcp  web:1
```
WebブラウザーをタスクのIPアドレスに移動して、ECSクラスターで実行されているサンプルアプリを確認します。

## Creating a Service
タスクをサービスとして実行することもできます。 ECSサービススケジューラは、指定された数のタスクが常に実行されていることを確認し、タスクが失敗した場合（たとえば、基になるコンテナーインスタンスが何らかの理由で失敗した場合）、タスクを再スケジュールします。
```
$ ecs-cli compose --project-name wordpress-test service create

INFO[0000] Using Task definition                         TaskDefinition=wordpress-test:1
INFO[0000] Created an ECS Service                        serviceName=wordpress-test taskDefinition=wordpress-test:1
```
その後、次のコマンドを使用してサービスのタスクを開始できます。`$ ecs-cli compose --project-name wordpress-test service start`

タスクの開始には1分かかる場合があります。次のコマンドを使用して、進行状況を監視できます。
```
$ ecs-cli compose --project-name wordpress-test service ps
Name                                            State    Ports                      TaskDefinition
34333aa6-e976-4096-991a-0ec4cd5af5bd/wordpress  RUNNING  54.186.138.217:80->80/tcp  wordpress-test:1
34333aa6-e976-4096-991a-0ec4cd5af5bd/mysql      RUNNING                             wordpress-test:1
```
負荷分散を含む利用可能なサービスオプションの詳細については、`$ ecs-cli compose service`ドキュメントページを参照してください。

## Using ECS parameters
ECSタスク定義には、Docker Composefileのフィールドに対応しない特定のフィールドがあるため、`--ecs-params`フラグを使用してそれらの値を指定できます。現在、ファイルは次のスキーマをサポートしています。
- パラメータの説明は、[タスク定義パラメータ](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/task_definition_parameters.html)を参照すること

``` ecs-params.yml
version: 1
task_definition:
  ecs_network_mode: string               // Supported string values: none, bridge, host, or awsvpc
  task_role_arn: string
  task_execution_role: string            // Needed to use Cloudwatch Logs or ECR with your ECS tasks
  task_size:                             // Required for running tasks with Fargate launch type
    cpu_limit: string
    mem_limit: string                    // Values specified without units default to MiB
  pid_mode: string                       // Supported string values: task or host
  ipc_mode: string                       // Supported string values: task, host, or none
  services:
    <service_name>:
      essential: boolean
      repository_credentials:
        credentials_parameter: string
      cpu_shares: integer
      firelens_configuration:
        type: string                     // Supported string values: fluentd or fluentbit
        options: list of strings
      mem_limit: string                  // Values specified without units default to bytes, as in docker run
      mem_reservation: string
      gpu: string
      init_process_enabled: boolean
      healthcheck:
        test: string or list of strings
        interval: string
        timeout: string
        retries: integer
        start_period: string
      logging:
        secret_options:
          - value_from: string
            name: string
      secrets:
        - value_from: string
          name: string
  docker_volumes:
    - name: string
      scope: string                      // Valid values: "shared" | "task"
      autoprovision: boolean             // only valid if scope = "shared"
      driver: string
      driver_opts:
        string: string
      labels:
        string: string
  placement_constraints:
    - type: string                      // Valid values: "memberOf"
      expression: string

run_params:
  network_configuration:
    awsvpc_configuration:
      subnets: array of strings          // These should be in the same VPC and Availability Zone as your instance
      security_groups: list of strings   // These should be in the same VPC as your instance
      assign_public_ip: string           // supported values: ENABLED or DISABLED
  task_placement:
    strategy:
      - type: string                     // Valid values: "spread"|"binpack"|"random"
        field: string                    // Not valid if type is "random"
    constraints:
      - type: string                     // Valid values: "memberOf"|"distinctInstance"
        expression: string               // Not valid if type is "distinctInstance"
  service_discovery:
    container_name: string
    container_port: integer
    private_dns_namespace:
      id: string
      name: string
      vpc: string
      description: string
    public_dns_namespace:
      id: string
      name: string
    service_discovery_service:
      name: string
      description: string
      dns_config:
        type: string
        ttl: integer
      healthcheck_custom_config:
        failure_threshold: integer
```

バージョンecs-params.ymlファイルに使用されているスキーマバージョン。現在、バージョン1のみをサポートしています。

task_definitionの下にリストされるタスク定義フィールドは、ECSタスク定義に含まれるフィールドに対応します。

- `ecs_network_mode`は、ECSタスク定義のNetworkModeに対応します（Docker Composeのnetwork_modeフィールドと混同しないでください）。サポートされる値は、なし、ブリッジ、ホスト、またはawsvpcです。指定しない場合、これはデフォルトでブリッジモードになります。ネットワーク構成でタスクを実行する場合は、このフィールドをawsvpcに設定する必要があります。

- `task_role_arn`は、IAMロールのARNである必要があります。注：この役割に適切な許可/信頼関係がない場合、upコマンドは失敗します。

- サービスは、Docker作成ファイルにリストされているサービスに対応し、service_nameは実行するコンテナの名前に一致します。そのフィールドは、ECSコンテナー定義にマージされます。
    - 必須フィールドが指定されていない場合、値はデフォルトのtrueになります。
    - Docker composeバージョン3を使用している場合、`cpu_shares`、`mem_limit`、および`mem_reservation`フィールドはオプションであり、composeファイルではなくECS paramsファイルで指定する必要があります。
    - Docker composeバージョン2では、`cpu_shares`、`mem_limit`、および`mem_reservation`フィールドは、composeまたはECS paramsファイルで指定できます。 ECS paramsファイルで指定されている場合、値は構成ファイルにある値をオーバーライドします。
    - イメージをプルするためにプライベートリポジトリを使用している場合、`repository_credentials`を使用すると、秘密リポジトリ資格情報を含む秘密の名前に`credential_parameter`としてAWS Secrets ManagerシークレットARNを指定できます。
    - `init_process_enabled`はLinux固有のオプションで、コンテナ内でinitプロセスを実行するように設定でき、シグナルを転送してプロセスを取得します。このパラメーターは、docker runの--initオプションにマップします。このパラメーターには、コンテナインスタンスでバージョン1.25以上のDocker Remote APIが必要です。

### Using Route53 Service Discovery
ECS CLIを使用すると、サービス検出にRoute53自動命名を使用するECSサービスを作成できます。サービス検出には、サービス検出サービスとDNS名前空間が必要です。それを念頭に置いて：
- ECS CLIでサービスディスカバリを有効にすると、CloudFormationを使用して常に新しいサービスディスカバリサービスが作成されます。
- DNSネームスペースについては、既存のパブリックまたはプライベートDNSネームスペースを使用するか、CloudFormationを使用してECS CLIにプライベートDNSネームスペースを作成させるオプションがあります。
- ECS CLIでは、パブリックDNS名前空間の作成はサポートされていません。
- Service Discoveryで使用できるDNS名前空間は1つだけです。
#### Enabling Service Discovery
##### Specifying Values

ECS-CLIは、ほとんどのフィールドにデフォルト値を提供すると同時に、最大限の構成可能性を提供することにより、サービス検出の使用を簡素化します。 ECS Params入力スキーマとともにリストされるデフォルト値と説明は次のとおりです。
```
version: 1
run_params:
  service_discovery:
    container_name: string            // Required if using SRV records
    container_port: string            // Required if using SRV records
    private_dns_namespace:
      id: string                      // Allows you to specify an existing namespace by ID
      name: string                    // DNS name for private namespace. Either used to specify an existing namespace, or if one does not exist with this name, the ECS CLI will create it
      vpc: string                     // Required if "id" is not specified
      description: string             // Only used if the namespace does not yet exist. Default = "Created by the Amazon ECS CLI"
    public_dns_namespace:
      id: string                      // Specify an existing public namespace by ID
      name: string                    // Or specify an existing public namespace by Name
    service_discovery_service:
      name: string                    // Default = Name of the your ECS Service
      description: string             // Default = "Created by the Amazon ECS CLI"
      dns_config:
        type: string                  // Valid values: A or SRV. SRV is required/the default when using bridge or host network mode. A is the default for the awsvpc network mode.
        ttl: integer                  // Default = 60
      healthcheck_custom_config:
        failure_threshold: integer    // Default = 1
```
###### Simple Workflow
Service Discoveryの簡単なシナリオを見て、それがECS CLIでどのように機能するかを見てみましょう。 Service Discovery構成値の多くはフラグで指定できます。フラグは、両方が存在する場合、ECS Paramsより優先されます。 ECS CLIでは、Compose Project Name（フラグを使用して特に指定しない限り、Docker Composeファイルを含むディレクトリの名前）がECSサービスの名前として使用されることに注意してください。

最初に、バックエンドという名前のサービスを作成し、VPCにプライベートDNS名前空間を作成します。ネットワークモードがawsvpcであるため、container_nameおよびcontainer_portの値は必要ないと仮定します。

```
$ ecs-cli compose --project-name backend service up --private-dns-namespace tutorial --vpc vpc-04deee8176dce7d7d --enable-service-discovery
INFO[0001] Using ECS task definition                     TaskDefinition="backend:1"
INFO[0002] Waiting for the private DNS namespace to be created...
INFO[0002] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
WARN[0033] Defaulting DNS Type to A because network mode was awsvpc
INFO[0033] Waiting for the Service Discovery Service to be created...
INFO[0034] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
INFO[0065] Created an ECS service                        service=backend taskDefinition="backend:1"
INFO[0066] Updated ECS service successfully              desiredCount=1 serviceName=backend
INFO[0081] (service backend) has started 1 tasks: (task 824b5a76-8f9c-4beb-a64b-6904e320630e).  timestamp="2018-09-12 00:00:26 +0000 UTC"
INFO[0157] Service status                                desiredCount=1 runningCount=1 serviceName=backend
INFO[0157] ECS Service has reached a stable state        desiredCount=1 runningCount=1 serviceName=backend
```
これで、2つのサービスはDNSを使用してVPCでお互いを見つけることができます。 DNSホスト名は、サービスディスカバリサービスの名前にDNSネームスペースの名前を加えたものになります。そのため、ECSサービスのフロントエンドはfrontend.tutorialにあり、バックエンドはbackend.tutorialにあります。これはプライベートDNS名前空間であるため、これらのドメイン名はVPC内でのみ解決できることに注意してください。

次に、フロントエンドのサービス検出設定の一部を更新しましょう。更新できる値は、DNS TTLとヘルスチェックのカスタム構成の失敗のしきい値（ECSによって管理されるヘルスチェックの失敗のしきい値です。これは、正常でないコンテナーのDNSレコードを削除するタイミングを決定します）。

```
$ ecs-cli compose --project-name frontend service up --update-service-discovery --dns-type SRV --dns-ttl 120 --healthcheck-custom-config-failure-threshold 2
INFO[0001] Using ECS task definition                     TaskDefinition="frontend:1"
INFO[0001] Updated ECS service successfully              desiredCount=1 serviceName=frontend
INFO[0001] Service status                                desiredCount=1 runningCount=1 serviceName=frontend
INFO[0001] ECS Service has reached a stable state        desiredCount=1 runningCount=1 serviceName=frontend
INFO[0002] Waiting for your Service Discovery resources to be updated...
INFO[0002] Cloudformation stack status                   stackStatus=UPDATE_IN_PROGRESS
```
次に、サービスとService Discoveryリソースを削除します。フロントエンドを削除すると、CLIは関連するサービス検出サービスを自動的に削除します。
```
$ ecs-cli compose --project-name frontend service down
INFO[0000] Updated ECS service successfully              desiredCount=0 serviceName=frontend
INFO[0001] Service status                                desiredCount=0 runningCount=1 serviceName=frontend
INFO[0016] Service status                                desiredCount=0 runningCount=0 serviceName=frontend
INFO[0016] (service frontend) has stopped 1 running tasks: (task 824b5a76-8f9c-4beb-a64b-6904e320630e).  timestamp="2018-09-12 00:37:25 +0000 UTC"
INFO[0016] ECS Service has reached a stable state        desiredCount=0 runningCount=0 serviceName=frontend
INFO[0016] Deleted ECS service                           service=frontend
INFO[0016] ECS Service has reached a stable state        desiredCount=0 runningCount=0 serviceName=frontend
INFO[0027] Waiting for your Service Discovery Service resource to be deleted...
INFO[0027] Cloudformation stack status                   stackStatus=DELETE_IN_PROGRESS
```

最後に、バックエンドとそれで作成されたプライベートDNS名前空間を削除します（CLIは、名前空間のCloudFormationスタックを、最初に作成されたECSサービスに関連付けるため、2つを一緒に削除する必要があります）。
```
$ ecs-cli compose --project-name backend service down --delete-namespace
INFO[0000] Updated ECS service successfully              desiredCount=0 serviceName=backend
INFO[0001] Service status                                desiredCount=0 runningCount=1 serviceName=backend
INFO[0016] Service status                                desiredCount=0 runningCount=0 serviceName=backend
INFO[0016] (service backend) has stopped 1 running tasks: (task 824b5a76-8f9c-4beb-a64b-6904e320630e).  timestamp="2018-09-12 00:37:25 +0000 UTC"
INFO[0016] ECS Service has reached a stable state        desiredCount=0 runningCount=0 serviceName=backend
INFO[0016] Deleted ECS service                           service=backend
INFO[0016] ECS Service has reached a stable state        desiredCount=0 runningCount=0 serviceName=backend
INFO[0027] Waiting for your Service Discovery Service resource to be deleted...
INFO[0027] Cloudformation stack status                   stackStatus=DELETE_IN_PROGRESS
INFO[0059] Waiting for your Private DNS Namespace resource to be deleted...
INFO[0059] Cloudformation stack status                   stackStatus=DELETE_IN_PROGRESS
```
### Viewing Running Tasks

PSコマンドを使用すると、実行中のタスクと最近停止したタスクを確認できます。クラスターで実行中のタスクを確認するには：
```
$ ecs-cli ps
Name                                            State    Ports                     TaskDefinition
37e873f6-37b4-42a7-af47-eac7275c6152/web        RUNNING  10.0.1.27:8080->8080/tcp  TaskNetworking:2
37e873f6-37b4-42a7-af47-eac7275c6152/lb         RUNNING  10.0.1.27:80->80/tcp      TaskNetworking:2
37e873f6-37b4-42a7-af47-eac7275c6152/redis      RUNNING                            TaskNetworking:2
40bedf31-d707-446e-affc-766eac4cfb85/mysql      RUNNING                            fargate:1
40bedf31-d707-446e-affc-766eac4cfb85/wordpress  RUNNING  54.16.93.6:80->80/tcp     fargate:1
```

ECS CLIによって表示されるIPアドレスは、クラスターの構成方法と使用される起動タイプによって異なります。タスクネットワーキングなしで起動タイプEC2でタスクを実行している場合、表示されるIPアドレスは、タスクを実行しているEC2インスタンスのパブリックIPです。パブリックIPが割り当てられていない場合、インスタンスのプライベートIPが表示されます。

EC2起動タイプでタスクネットワーキングを使用するタスクの場合、ECS CLIはタスクに接続されたENIのプライベートIPアドレスのみを表示します。

Fargateタスクの場合、ECS CLIは、Fargateタスクに接続されたENIに割り当てられたパブリックIPを返します。 `assign_public_ip`：ENABLEDがECS Paramsファイルに存在する場合、FargateタスクのENIにパブリックIPが割り当てられます。 ENIにパブリックIPがない場合、プライベートIPが表示されます。

`--desired-status`フラグを使用して、「STOPPED」または「RUNNING」コンテナをフィルタリングできます

### Viewing Container Logs

特定のタスクとコンテナのCloudWatch Logsを表示します。

```
ecs-cli logs --task-id 4c2df707-a160-475e-9c16-15dfb9df01cc --container-name mysql
```

Fargateタスクの場合、コンテナログをCloudWatchに送信することをお勧めします。注：Fargateタスクの場合、CloudWatch Logsを使用するには、ECS Paramsファイルでタスク実行IAMロールを指定する必要があります。次のように、作成ファイルでawslogsドライバーとログオプションを指定できます。

```
services:
  <My Service>:
    logging:
      driver: awslogs
      options:
        awslogs-group: <Log Group Name>
        awslogs-region: <Log Region>
        awslogs-stream-prefix: <Prefix Name>
```
ログストリームプレフィックスは技術的にオプションです。ただし、指定することを強くお勧めします。指定する場合は、`ecs-cli logs`コマンドを使用できます。 Logsコマンドを使用すると、タスクのログを取得できます。 logsコマンドには多くのオプションがあります。
```
OPTIONS:
--task-id value            Print the logs for this ECS Task.
--task-def value           [Optional] Specifies the name or full Amazon Resource Name (ARN) of the ECS Task Definition associated with the Task ID. This is only needed if the Task is using an inactive Task Definition.
--follow                   [Optional] Specifies if the logs should be streamed.
--filter-pattern value     [Optional] Substring to search for within the logs.
--container-name value     [Optional] Prints the logs for the given container. Required if containers in the Task use different log groups
--since value              [Optional] Returns logs newer than a relative duration in minutes. Cannot be used with --start-time (default: 0)
--start-time value         [Optional] Returns logs after a specific date (format: RFC 3339. Example: 2006-01-02T15:04:05+07:00). Cannot be used with --since flag
--end-time value           [Optional] Returns logs before a specific date (format: RFC 3339. Example: 2006-01-02T15:04:05+07:00). Cannot be used with --follow
--timestamps, -t           [Optional] Shows timestamps on each line in the log output.
```
### Using FIPS Endpoints
### Using Private Registry Authentication
### Checking for Missing Attributes and Debugging Reason Attribute Errors
### Running Tasks Locally
## Amazon ECS CLI Commands
## Contributing to the CLI