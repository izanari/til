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
ecs-cli configure --region ap-northeast-1 --cluster test-ecs-clister
INFO[0000] Saved ECS CLI cluster configuration default. 
```

- ECSクラスタを起動します

```
ecs-cli up --capability-iam --size 2 --instance-type t3.nano --keypair hogehoge
INFO[0000] Using recommended Amazon Linux 2 AMI with ECS Agent 1.32.0 and Docker version 18.06.1-ce 
INFO[0000] Created cluster                               cluster=test-ecs-clister region=ap-northeast-1
INFO[0001] Waiting for your cluster resources to be created... 
INFO[0001] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
```
- パラメーターを何も指定しないと、VPCやサブネットを自動で作成してくれます。何を作成されたか確認する場合は、CloudFormationのリソースを見るとわかります

## 削除する
- ECSクラスタを削除する
```
ecs-cli down
Are you sure you want to delete your cluster? [y/N]
y
```



## ヘルプ
### `ecs-cli up`
```
NAME:
   ecs-cli up - Creates the ECS cluster (if it does not already exist) and the AWS resources required to set up the cluster.

USAGE:
   ecs-cli up [command options] [arguments...]

OPTIONS:
   --capability-iam                  Acknowledges that this command may create IAM resources. Required if --instance-role is not specified. NOTE: Not applicable for launch type FARGATE or when creating an empty cluster.
   --empty, -e                       [Optional] Specifies that an ECS cluster will be created with no resources.
   --instance-role value             [Optional] Specifies a custom IAM Role for instances in your cluster. A new instance profile will be created and attached to this role. Required if --capability-iam is not specified. NOTE: Not applicable for launch type FARGATE.
   --keypair value                   [Optional] Specifies the name of an existing Amazon EC2 key pair to enable SSH access to the EC2 instances in your cluster. Recommended for EC2 launch type. NOTE: Not applicable for launch type FARGATE.
   --instance-type value             [Optional] Specifies the EC2 instance type for your container instances. If you specify the A1 instance family, the ECS optimized arm64 AMI will be used, otherwise the x86 AMI will be used. Defaults to t2.micro. NOTE: Not applicable for launch type FARGATE.
   --spot-price value                [Optional] If filled and greater than 0, EC2 Spot instances will be requested.
   --image-id value                  [Optional] Specify the AMI ID for your container instances. Defaults to amazon-ecs-optimized AMI. NOTE: Not applicable for launch type FARGATE.
   --no-associate-public-ip-address  [Optional] Do not assign public IP addresses to new instances in this VPC. Unless this option is specified, new instances in this VPC receive an automatically assigned public IP address. NOTE: Not applicable for launch type FARGATE.
   --size value                      [Optional] Specifies the number of instances to launch and register to the cluster. Defaults to 1. NOTE: Not applicable for launch type FARGATE.
   --azs value                       [Optional] Specifies a comma-separated list of 2 VPC Availability Zones in which to create subnets (these zones must have the available status). This option is recommended if you do not specify a VPC ID with the --vpc option. WARNING: Leaving this option blank can result in failure to launch container instances if an unavailable zone is chosen at random.
   --security-group value            [Optional] Specifies a comma-separated list of existing security groups to associate with your container instances. If you do not specify a security group here, then a new one is created.
   --cidr value                      [Optional] Specifies a CIDR/IP range for the security group to use for container instances in your cluster. This parameter is ignored if an existing security group is specified with the --security-group option. Defaults to 0.0.0.0/0.
   --port value                      [Optional] Specifies a port to open on the security group to use for container instances in your cluster. This parameter is ignored if an existing security group is specified with the --security-group option. Defaults to port 80.
   --subnets value                   [Optional] Specifies a comma-separated list of existing VPC Subnet IDs in which to launch your container instances. This option is required if you specify a VPC with the --vpc option.
   --vpc value                       [Optional] Specifies the ID of an existing VPC in which to launch your container instances. If you specify a VPC ID, you must specify a list of existing subnets in that VPC with the --subnets option. If you do not specify a VPC ID, a new VPC is created with two subnets.
   --extra-user-data value           [Optional] Specifies additional User Data for your EC2 instances. Files can be shell scripts or cloud-init directives and are packaged into a MIME Multipart Archive along with ECS CLI provided User Data which directs instances to join your cluster.
   --force, -f                       [Optional] Forces the recreation of any existing resources that match your current configuration. This option is useful for cleaning up stale resources from previous failed attempts.
   --tags value                      [Optional] Specify tags which will be added to AWS Resources created for your cluster. Specify in the format 'key1=value1,key2=value2,key3=value3'
   --region value, -r value          [Optional] Specifies the AWS region to use. Defaults to the region configured using the configure command
   --ecs-profile value               [Optional] Specifies the name of the ECS profile configuration to use. Defaults to the default profile configuration. [$ECS_PROFILE]
   --aws-profile value               [Optional] Use the AWS credentials from an existing named profile in ~/.aws/credentials. [$AWS_PROFILE]
   --cluster-config value            [Optional] Specifies the name of the ECS cluster configuration to use. Defaults to the default cluster configuration.
   --cluster value, -c value         [Optional] Specifies the ECS cluster name to use. Defaults to the cluster configured using the configure command
   --launch-type value               [Optional] Specifies the launch type. Options: EC2 or FARGATE. Overrides the default launch type stored in your cluster configuration. Defaults to EC2 if a cluster configuration is not used.
   --verbose, --debug                [Optional] Increase the verbosity of command output to aid in diagnostics.
   
   ```