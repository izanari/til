import os
import boto3


def lambda_handler(event, context):
    """
    S3にオブジェクトがPUTされたらメタデータを追加する
    追加メタデータ:
        Cache-Control: public, max-age=10800
    """

    try:
        # 対象のBuketチェック
        if os.environ['AWS_S3_BUKET_NAME'] != event['Records'][0]['s3']['bucket']['name']:
            raise Exception("[Error]対象のBuketではありません。")

        key = event['Records'][0]['s3']['object']['key']

        # Buketのオブジェクトを取得
        s3 = boto3.resource('s3')
        obj = s3.Object(os.environ['AWS_S3_BUKET_NAME'], key)

        # オブジェクトのkeyに対して、CacheControlが追加されているかをチェック
        if obj.cache_control == 'public, max-age=10800':
            raise Exception("[Info]{}には、既にCacheControlが付与されています。".format(key))

        # keyに対してCacheControlを追加
        obj.put(
            CacheControl='public, max-age=10800'
        )

    except Exception as e:
        print(e)
