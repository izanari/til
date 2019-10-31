# IAM
- AWSリソースをセキュアに操作するために、認証・認可の仕組みを提供するマネージドサービス
## ルートユーザー
- 極力ルートユーザーは使用しない
- コンソールへはメールアドレスとパスワードでサインインする
- IAMで設定するアクセスポリシーではアクセス許可を制御できない
  - AWS Organizationsのサービスコンソールポリシー（SCP)によってサービスを制限可能
### ルートユーザーが必要なAWSタスク例
- ルートユーザーのメールアドレスやパスワードの変更
- IAMユーザーによる課金情報へのアクセスのActivate/Deactivate
- 支払いオプションの変更
- AWSサポートプランの変更
- IAMユーザーへのアクセス許可のリストア
- 無効な制約を設定したAmazon S3バケットポリシーの修正
- 脆弱性診断フォームの提出
- 逆引きDNS申請
- CloudFrontキーペアの作成
- AWSアカウントの解約
## アクセスキー
- AWSアカウントのルートユーザーまたはIAMユーザーの長期的な認証情報
- アクセスキーを用いてAWS CLIやSDKからリクエストに署名
- アクセスキーID/シークレットアクセスキーで構成される
- 安全なローテーションのために最大２つのアクセスキーを持つことができる
### ルートユーザーのアクセスキー
- 削除すること
- 他者に開示したりプログラムに埋め込んだりしない
## IAMユーザー
- AWSで作成するエンティティ
- 名前と認証情報で構成される
- IAMユーザーを識別する方法
  - ユーザーのフレンドリ名（ユーザー作成時に指定する）
    - Aliceとaliceは同一ユーザーと見なされ作成できない
  - ユーザーのARN(Amazon Resource Name)：リソースポリシーのPrincipal要素で指定
  - ユーザー一意の識別子
    - AIxxxxxxx
- 個々のIAMユーザーを作成するメリット
  - 認証情報を個別に変更できる
  - アクセス許可をいつでも変更、無効化できる
  - Amazon CloudTrailログからアクションを追跡できる
### 強力なパスワードポリシー
- AWSアカウントのルートユーザーのパスワードポリシーには適用されない
- ポリシーの一部
  - 最小文字数
  - パスワード再利用禁止の世代数
  - 管理者による期限切れパスワードのリセット
## MFA
- パスワードやアクセスキーによる認証に追加してセキュリティを強化する
- サポートするMFAメカニズム
  - 仮想MFAデバイス
  - U2Fセキュリティキー
  - ハードウェアMFAデバイス
- ルートユーザー、IAMユーザーの各IDに個別のMFA設定が可能
- MFA条件を指定したポリシーを関連付けできる対象
  - IAMユーザーまたはIAMグループ
  - Amazon S3バケット、Amazon SQSキュー、Amazon SNSトピック等のリソース
  - IAMロールの信頼ポリシー
- CLIからMFAする場合
  ```
  aws sts get-session-token --serial-number arn:aws:iam::0123456789012:mfa/IAMユーザー名 --token-code 000000 --output json
  ```
  - 取得した後に環境変数に設定する
    ```
    export AWS_ACCESS_KEY_ID=xxxxxxx
    export AWS_SECRET_ACCESS_KEY=yyyyyyy
    export AWS_SESSION_TOKEN=zzzzzz
    ```
  - ワンライナーでクレデンシャルを設定する方法
    - 参照URL: [AWS CLIでMFAを使う](https://qiita.com/kter/items/9663457d4d27a3941655)
    ```
    eval `aws sts get-session-token --serial-number (登録MFAのARN) --token-code (MFAコード) | awk ' $1 == "\"AccessKeyId\":" { gsub(/\"/,""); gsub(/,/,""); print "export AWS_ACCESS_KEY_ID="$2 } $1 == "\"SecretAccessKey\":" { gsub(/\"/,""); gsub(/,/,""); print "export AWS_SECRET_ACCESS_KEY="$2 } $1 == "\"SessionToken\":" { gsub(/\"/,""); gsub(/,/,""); print "export AWS_SESSION_TOKEN="$2 } '`
    ```
## ポリシー
- IAMアイデンティティやAWSリソースに関連づけることによってアクセス許可を定義することができるオブジェクト
- ポリシードキュメントは１つ以上のStatementブロックで構成
  - Statement
    - SID
    - Effect
    - Principal
    - Action
    - Resource
    - Condition Block
- ポリシータイプ
  - アイデンティティベースのポリシー
    - 管理ポリシー
      - 複数のIAMユーザー、IAMグループ、IAMロールに関連付け可能（最大１０個）
      - 再利用可能、一元化された変更管理
      - バージョニングとロールバック
      - 種類
        - AWS管理ポリシー
          - AWSにより事前定義された管理ポリシー
          - ユーザー側で編集不可
          - AWSにより更新される
        - カスタマー管理ポリシー
          - AWS管理ポリシーでは要件を満たせない場合等に適用する
    - インラインポリシー
      - 単一のIAMユーザー、IAMグループ、IAMロールに直接埋め込む
      - IAMエンティティに紐付いた固有のオブジェクト
      - IAMエンティティを削除するとインラインポリシーも削除される
      - IAMエンティティとポリシーとの厳密な１対１の関係を維持する必要がある場合等に適用する
      - ベストプラクティスでは、インラインポリシーの利用はできるだけ避けてくださいと書かれている
  - リソースベースのポリシー
    - IAMロールの信頼ポリシー
    - S3のバケットポリシー
    - SNSトピックのアクセス許可
    - SQSキューのアクセス許可
  - パーミッションバウンダリー
    - AWS IAMアクセス許可の境界
    - AWS Organizationsサービスコンソールポリシー
  - アクセスコンソールポリシー
    - Amazon S3のバケットACL
    - VPCサブネットのACL
  - セッションポリシー
- [IAM JSON ポリシーリファレンス](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies.html)
### 要素
#### Principal要素
- リソースベースのポリシーに記述する
  - バケットポリシーや信頼ポリシー等のこと
- AWSアカウント
  ```
  "Principal":{"AWS":"arn:aws:iam:[123456789012]/root"}
  ```
- IAMユーザー
  ```
  "Principal":{"AWS":"arn:aws:iam:[123456789012]/user/[Alice]"}
  ```
- IAMロール
  ```
  "Principal":{"AWS":"arn:aws:iam:[123456789012]/role/[s3ReadOnlyRole]"}
  ```
- 引き受けたロールユーザー
  ```
  "Principal":{"AWS":"arn:aws:sts:[234567890123]:assumed-role/[role-name]/[role-session-name]"}
  ```
- 匿名ユーザー
  ```
  "Principal":"*"
  "Principal":{"AWS":"*"}
  ```
  - []内は環境に応じて置き換える
- IAMグループの指定はできない
- 大文字小文字は区別される
- ユーザーを指定する際にすべてのユーザーを意味でのワイルドカードは指定できない
  - AWSカウントを指定する
- Principal要素に指定したIAMユーザーとIAMロールを削除すると信頼関係は壊れる
  - 同じ名前で再作成してもプリンシプルIDが異なるため、同じ名前で再作成してもロールの編集が必要
- 参照ドキュメント
  - [AWS JSON ポリシーの要素:Principal](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_principal.html)

### Action要素
- 許可・拒否される特定のアクションを指定する
- Statement要素にはAction/NotAction要素が必須
- 記述例
  - ```"Action":"ec2:StartInstances"```
  - ```"Action":["sqs:SendMessage","sqs:ReceiveMessage"]```
  - ```"Action":"iam:*Accesskey"```
  - ```"Action":"IAM:listaccesskeys"```
- ワイルドカード使用可能、大文字小文字の区別はなし
- [IAM JSON ポリシーの要素:Action](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_action.html)
### Resource要素
- Action要素の対象となる特定リソースをARN形式で記述する
- Resource/NotResource要素が必須
- 記述例
  - 特定のSQSキュー
    - ```"Resource":"arn:aws:sqs:ap-northeast-1:123456789012:queue1"```
  - /accountingというパスを持つ全てのIAMユーザーを示しています
    - ```"Resource":"arn:aws:iam::123456789012:user/accounting/*"```
  - 特定のS3バケット
    - ```"Resource":"arn:aws:s3:::s3bucketname/*"```
  - 複数指定する場合
    - ```
      "Resource":[
        "arn:aws:dynamodb:ap-northeast-1::table/book_table",
        "arn:aws:dynamodb:ap-northeast-1::table/magazine_table"
      ]
      ```

- 複数のリソースを指定可能、ワイルドカードを使用可能、JSONポリシー変数を指定可能
  - [IAM ポリシーエレメント: 変数およびタグ](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_variables.html)
- [IAM JSON ポリシーの要素:Resource](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_resource.html)

### Condition要素
- ポリシーが有効になるタイミングの条件を指定する
- Condition要素はオプション
- 記述形式
  - ```"Condition":{条件演算子:{条件キー:条件値}}```
  - `条件演算子`
    - 条件比較のタイプ（文字列条件、数値条件、IPアドレス条件等）を指定する
    - 条件キーごとに使用できる条件演算子の種類が決まっている
  - `条件キー`
    - AWSグローバル条件コンテキストキー("aws:"で始まる)
    - AWSサービス固有のキー
    - IAM条件のコンテキストキー
- 記述例
  - 文字列条件演算子
    ```
    "Condition":{"StringEquals":{"s3:prefix":"projects"}}
    "Condition":{"StringEquals":{"aws:username":"hogehoge"}
    "Condition":{"StringEquals":{"ec2:ResourceTag/tagkey":"tagvalue"}}
    ```
  - 数値条件演算子
    ```
    "Condition": {"NumericLessThanEquals": {"s3:max-keys": "10"}}
    ```
  - 日付条件演算子
    ```
    "Condition": {"DateLessThan": {"aws:CurrentTime": "2013-06-30T00:00:00Z"}}
    ```
  - ブール条件演算子
    ```
     "Condition": {"Bool": {"aws:SecureTransport": "true"}}
    ```
  - バイナリ条件演算子
    ```
      "Condition" : {
        "BinaryEquals": {
          "key" : "QmluYXJ5VmFsdWVJbkJhc2U2NA=="
        }
      } 
    ```
  - IP アドレス条件演算子
    ```
    "Condition": {"IpAddress": {"aws:SourceIp": "203.0.113.0/24"}}
    ``` 
  - ARN条件演算子
    ```
     "Condition": {"ArnEquals": {"aws:SourceArn": "arn:aws:sns:REGION:123456789012:TOPIC-ID"}}
    ```
- [IAM JSON ポリシーの要素:Condition](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_condition.html)
- 
#### AND条件とOR条件
- AND条件
  ```
  "Condition":{
    "DateGreaterThan":{
      "aws:CurrentTime":"2019-01-29T12:0000Z"
    },
    "DataLessThan":{
      "aws:CurrentTime":"2019-01-29T15:00:000Z"
    }
  }
  ```
- OR条件
  ```
  "Condition":{
    "IpAddress":{
      "aws:SourceIP":["192.168.1.0/24,"192.168.2.0/24]
    }
  } 
  ```
## 決定ロジック
- 全てのアクセスはデフォルトDeny(暗黙的なDeny)
- アクセス権限にAllow条件があった場合、アクセス許可
- ただしアクセス権限に１つでもDenyの条件があった場合、アクセス拒否（明示的なDeny)
- 暗黙的なDeny < 明示的なAllow < 明示的なDeny
- アイデンティティベースのポリシーは、管理ポリシーとインラインポリシーのそれぞれで許可されているものが有効となる（OR条件）
- アクセス許可の境界とアイデンティティベースのポリシーの両方で許可されているものが有効な権限となる（AND条件）
- AWS Organization サービスコントロールポリシー（SCP）
- リソースベースのポリシーは、アイデンティティベースのポリシーとそれぞれで許可されているものが有効となる（OR条件）
- クロスアカウントの場合
  - リソースベースポリシー
    - リソースベースポリシーとアイデンティティポリシーの両方で許可されているものが有効となる（AND条件）

## IAM グループ
- グループの入れ子はできない
- IAMロールもグループに所属させることはできない
- IAMユーザーは複数のIAMグループに所属させることができる（最大１０）

## 一時的なセキュリティ認証情報
- 有効期限付きのアクセスキーID、シークレットアクセスキー、セキュリティトークンで構成
  - 短期的な有効期限
  - 認証情報が不要になった時にローテーションしたり明示的に取り消す必要がないのでより安全
  - ユーザーのリクエストによってSTSが動的に作成する
### AWS Security Token Service（STS）
- 一時的なセキュリティ認証情報を生成するサービス
  - 期限付きのアクセスキー・シークレットアクセスキー・セッショントークンが払い出される
  - トークンのタイプにより有効期限は様々
- 発行した認証情報の期限の変更はできない
- エンドポイントは全リージョンで使用可能
  - デフォルトではグローバル・サービスとして利用
- 各リージョンのSTSエンドポイントでアクティベート可能
- オレゴンリージョンのみ　PrivateLinkに対応する
- API
  - AssumeRole
  - AssumeRoleWithWebIdentity
  - AssumeRoleWithSAML
  - GetSessionToken
  - GetFederationToken
- IAMロールにより認証情報はAWSが自動的にローテーションする
- AWS SDKによって認証情報取得と有効期限切れ前の再取得を自動的に実施可能
- AWS CLIもIAMロールに対応済み
- [一時的なセキュリティ認証情報のリクエスト](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_credentials_temp_request.html#stsapi_comparison)

### APIオプションの比較
|AWS STS API|呼び出し元|有効期限（min,max,default)|MFAサポート|セッションポリシーのサポート|認証情報に対する制限|
|---|---|---|---|---|---|
|AssumeRole|IAM ユーザー、または既存の一時的なセキュリティ認証情報を持つユーザー|15分,DurationSeconds,1時間|あり|あり|GetFederationToken または GetSessionToken を呼び出せません。|
|AssumeRoleWithSAML|任意のユーザー。呼び出し元は、既知の ID プロバイダーからの認証を示す SAML 認証レスポンスを渡す必要があります。|同上|なし|あり|同上|
|AssumeRoleWithWebIdentity|任意のユーザー。呼び出し元は、既知の ID プロバイダーからの認証を示すウェブ ID トークンを渡す必要があります。|同上|なし|あり|同上|
|GetFederationToken|IAM ユーザーまたは AWS アカウントのルートユーザー|IAMユーザー：15分,36時間,12時間 root:15分,1時間,1時間|なし|あり|IAM API オペレーションを直接呼び出せません。<br>GetCallerIdentity を除く AWS STS API オペレーションを呼び出せません。<br>コンソールへの SSO は許可されています。|
|GetSessionToken|IAM ユーザーまたは ルートユーザー|同上|あり|なし|リクエストに MFA 情報が含まれていない場合は、IAM API オペレーションを呼び出せません。<br>AssumeRole または GetCallerIdentity を除く AWS STS API オペレーションを呼び出せません。<br>コンソールへの SSO は許可されていません。|

### コマンド例
- AssumeRole
  ```
  aws assume-role --role-arn --role-session-name hoge
  ```


#### ユースケース
- IAMロールによるクロスアカウントアクセス
- 開発用アカウントから本番アカウントのS3バケットにputする場合
  - 開発アカウント側の設定
    - バケットを操作するユーザーへのポリシー
      - ```
        {
          "Statement":[
            {
              "Effect":"Allow",
              "Action":"sts:AssumeRole",
              "Resource":"arn:aws:iam::本番アカウントID:role:/s3-role"
            }
          ]
        }
        ```
  - 本番アカウント側の設定
    - s3-roleに付与されているポリシー
      - ```
        {
          "Statement":[
            {
              "Effect":"Allow",
              "Action":"s3:*",
              "Resource":"*"
            }
          ]
        }
        ```  
    - s3-roleの信頼ポリシー
      - ```
        {
          "Statement":[
            {
              "Effect":"Allow",
              "Principal":
                {
                  "AWS":"arn:aws:iam::開発アカウントID:root"
                },
              "Action":"sts:AssumeRole"
            }
          ]
        }
      ``` 
- 参照URL
  - http://blog.serverworks.co.jp/tech/2016/05/18/sts/
  - https://christina04.hatenablog.com/entry/assume-role
 
## フェデレーション
- [外部で認証されたユーザー（ID フェデレーション）へのアクセスの許可](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_roles_common-scenarios_federated-users.html)

## 参照ドキュメント
- [AWS Identity and Access Management (IAM) Part1](https://www.slideshare.net/AmazonWebServicesJapan/20190129-aws-black-belt-online-seminar-aws-identity-and-access-management-iam-part1)
- [AWS Identity and Access Management (IAM) Part2](https://www.slideshare.net/AmazonWebServicesJapan/20190130-aws-black-belt-online-seminar-aws-identity-and-access-management-aws-iam-part2)