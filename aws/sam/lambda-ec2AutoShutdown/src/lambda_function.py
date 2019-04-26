import boto3
import logging

logger = logging.getLogger()
logger.setLevel( logging.INFO )

def lambda_handler(event, context):
    client = boto3.client('ec2', event['region'])

    # region内の全インスタンス取得する
    all_instanceids = []
    response = client.describe_instances()
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            logger.debug( instance['InstanceId'] )
            logger.debug( instance['State']['Name'])
            all_instanceids.append( instance['InstanceId'] )
    logger.debug( response )

    # 停止させないタグが付与されているインスタンスを取得する
    nostop_instanceids = []
    response = client.describe_instances(
            Filters=[{'Name':'tag:autostop', 'Values': ['false']}]
    )
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            logger.debug( instance['InstanceId'] )
            nostop_instanceids.append( instance['InstanceId'] )

    # 停止させてもいいインスタンスIDを取得する
    targetids = set(all_instanceids) - set(nostop_instanceids)
    
    # 停止させる
    client.stop_instances(InstanceIds=list(targetids))
