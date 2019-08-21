import boto3
import requests
#from aws_xray_sdk.core import patch_all
#patch_all()
from aws_xray_sdk.core import patch
patch(('botocore','boto3','requests'))

def lambda_handler(event,context):
    response = requests.get('https://www.github.com')
    print( response.status_code )
    print( response.text )