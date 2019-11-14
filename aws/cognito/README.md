# Cognito
## 構成
### Amazon Cognito ID プール(フェデレーティッドアイデンティティ)
- Amazon Cognito ID プール (フェデレーテッドアイデンティティ) では、ユーザーの一意の ID を作成し、ID プロバイダーで連携させることができます。ID プールを使用すると、権限が制限された一時的な AWS 認証情報を取得して、他の AWS サービスにアクセスできます。 Amazon Cognito ID プールは次の ID プロバイダをサポートします。
  - Amazon Cognitoユーザープール
  - OpenID
  - SAML
  - Amazon
  - Facebook
  - Google
 
### Amazon Cognito ユーザープール
- ユーザプールは Amazon Cognito のユーザディレクトリです。ユーザープールを使用すると、ユーザーは Amazon Cognito を通じてウェブまたはモバイルアプリにログインできます。
- ユーザーは Google、Facebook、Amazon などのソーシャル ID プロバイダー、および SAML ベースの ID プロバイダー経由でユーザープールにサインインすることもできます。ユーザーが直接またはサードパーティを通じてサインインするかどうかにかかわらず、ユーザープールのすべてのメンバーには、SDK を通じてアクセスできるディレクトリプロファイルがあります。

### Amazon Cognito Sync

## サーバーベースの認証が有効な場合
- ユーザー登録（サインアップ）しても、確認をしないとサインイン（ログイン）することができません
- 以下に記載しているshellはサーバ上で実行していることを想定しています
### サインアップ
- ユーザープールを作成後、以下のようにサインアップする
```
#!/bin/sh

AWSPROFILE=********
CLIENT_ID=****************
USER_EMAIL=$1
PASSWD=$2

if [ $# -ne 2 ]; then
        echo "引数が足りません"
        exit 1
fi

aws cognito-idp sign-up \
        --client-id ${CLIENT_ID} \
        --username ${USER_EMAIL} \
        --password ${PASSWD} \
        --user-attribute "Name=email,Value=${USER_EMAIL}" \
        --profile ${AWSPROFILE}
```
- 実行結果
```
{
    "UserConfirmed": false,
    "CodeDeliveryDetails": {
        "Destination": "y***@f***.jp",
        "DeliveryMedium": "EMAIL",
        "AttributeName": "email"
    },
    "UserSub": "************"
}
```
- Your verification code というメールが送信されてくる
### コンファームサインアップ
- メールアドレスとverification codeを使ってサインアップします
```
#!/bin/sh

AWSPROFILE=************
CLIENT_ID=******************
USER_EMAIL=$1
CONFCODE=$2

if [ $# -ne 2 ]; then
        echo "引数が足りません"
        exit 1
fi

aws cognito-idp confirm-sign-up \
        --client-id ${CLIENT_ID} \
        --username ${USER_EMAIL} \
        --confirmation-code ${CONFCODE} \
        --profile ${AWSPROFILE}
```
- これでサインインすることができるようになります
#### サインイン
- IDとパスワードでログインします
```
#!/bin/sh

AWSPROFILE=**********
CLIENT_ID=**********
POOL_ID=**************
USER_EMAIL=$1
PASSWD=$2

if [ $# -ne 2 ]; then
        echo "引数が足りません"
        exit 1
fi

aws cognito-idp admin-initiate-auth \
        --client-id ${CLIENT_ID} \
        --user-pool-id ${POOL_ID} \
        --auth-flow ADMIN_NO_SRP_AUTH \
        --auth-parameters "USERNAME=${USER_EMAIL},PASSWORD=${PASSWD}" \
        --profile ${AWSPROFILE}

```
- ログインに成功すると３つのtokenが返ってきます
```
{
    "ChallengeParameters": {},
    "AuthenticationResult": {
        "AccessToken": "*****",
        "ExpiresIn": 3600,
        "TokenType": "Bearer",
        "RefreshToken": "*****",
        "IdToken": "*****"
    }
}
```
- Token部分は*でマスクしていますが、6バイトではありません
- 引数にパラメータを付与すると必要なtokenだけが返ってきます。何もつけないと３つ返ってきます。
  - ID token
    - `--query "AuthenticationResult.IdToken"`
  - Access token
    - `--query "AuthenticationResult.AccessToken"`
  - Refresh token
    - `--query "AuthenticationResult.RefreshToken"`
#### ID token,Access tokenの有効期限が切れた場合
- Refresh tokenを使って、新しいトークンを取得します
```
#!/bin/sh

AWSPROFILE=**********
CLIENT_ID=************
POOL_ID=********
REFTOKEN=$1

if [ $# -ne 1 ]; then
        echo "引数が足りません"
        exit 1
fi

aws cognito-idp admin-initiate-auth \
        --client-id ${CLIENT_ID} \
        --user-pool-id ${POOL_ID} \
        --auth-flow REFRESH_TOKEN_AUTH \
        --auth-parameters "REFRESH_TOKEN=${REFTOKEN}" \
        --profile ${AWSPROFILE} \
```
- `admin-initiate-auth`だけど、`auth-flow`が違います。また、username,passwordは不要で、refresh tokenのみで新しいトークンを取得できます。
  
### API Gatewayを利用する
- AWS API GatewayのオーソライザーにCognitoが指定されている場合は、有効期限が切れていないIDトークンが必要です
```
#!/bin/sh

set -ex

API_GATEWAY_URL=https://**********.execute-api.ap-northeast-1.amazonaws.com/test
ID_TOKEN=$1

curl -v -H "Authorization: ${ID_TOKEN}" ${API_GATEWAY_URL}/pets
```
- これでAPIの結果が返ってきます
- ID tokenが有効期限が切れていると、`{"message":"The incoming token has expired"}`というメッセージが返却されます


### ID tokenからクレーム（情報）を取得する
```
echo ${ID_TOKEN} | cur -d'.' -f 2 | base64 -D
```
これの結果が以下のようになります
```
{"sub":"**********","aud":"**************","email_verified":true,"event_id":"*****","token_use":"id","auth_time":1568965682,"iss":"https:\/\/cognito-idp.ap-northeast-1.amazonaws.com\/ap-northeast-**********","cognito:username":"************","exp":1568969282,"iat":1568965682,"email":"************"
```
- expはトークンの有効期限切れの日時になります
- iatはトークンの発行日時

### APIでユーザー情報を取得する
- アクセストークンがあれば取得できます
```
#!/bin/sh

AWSPROFILE=**********
ACCTOKEN=$1

if [ $# -ne 1 ]; then
        echo "引数が足りません"
        exit 1
fi

aws cognito-idp get-user \
        --access-token ${ACCTOKEN} \
        --profile ${AWSPROFILE} \
```
- 以下の結果が返ってきます
```
{
    "Username": "**********",
    "UserAttributes": [
        {
            "Name": "sub",
            "Value": "**********"
        },
        {
            "Name": "email_verified",
            "Value": "true"
        },
        {
            "Name": "email",
            "Value": "**********"
        }
    ]
}
```
## 参考サイト
- [Cognitoのサインイン時に取得できる、IDトークン・アクセストークン・更新トークンを理解する](https://dev.classmethod.jp/cloud/aws/study-tokens-of-cognito-user-pools/)
- [プログラミングせずにCognitoで新規ユーザー登録＆サインインを試してみる](https://dev.classmethod.jp/cloud/aws/sign-up-and-sign-in-by-cognito-with-awscli/)