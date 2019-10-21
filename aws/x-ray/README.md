# X-Ray
- X-Rayを使用できるAWSサービス
  - 手動インストール   
    - Amazon EC2
    - Amazon ECS
  - 自動で有効化（設定変更によって）
    - AWS Elastic Beanstalk
      - ソフトウェアの設定を変更するだけ。アプリケーションにX-Ray SDKを組み込む作業は必要
    - AWS Lambda 
      - コードレベルの修正は不要
      - 多少のメモリ消費量の増加あり
- デフォルトではサンプリングされる
  - 100%トレースする設定も可能ではだが、料金とパフォーマンスそれぞれへの影響を事前に確認する
- データの完全性は保証されない
  - 監査やコンプライアンスのツールとしては使用できない
- 直近30日間のトレースデータが保存される
  - 直近30日間の追跡データに対してクエリを実行可能
  - BatchGetTraces APIでトレースデータの取り出しが可能
  - BatchGetTraces のレスポンスをPutTraceSegments APIに使用する場合は、データの加工が必要となる
## X-Ray概念
- サンプリング
  - トレースを取得するリクエストを絞ること。また、その取得割合。
  - [AWS X-Ray コンソールでのサンプリングルールの設定](https://docs.aws.amazon.com/ja_jp/xray/latest/devguide/xray-console-sampling.html)
    - 制限
      - リザーバーサイズを50、固定レートを10%にした場合、1秒あたり100件のリクエストがルールに一致した場合、サンプリングされるリクエスト総数は？
        - reservoir size + ( (incoming requests per second - reservoir size) * fixed rate)の計算式から55
        - 固定レートは、リザーバーのサイズを超えた後で許可するレート
- トレース
  - 単一のリクエストに関するサービスをまたいだEnd-to-endのデータ
- セグメント
  - トレースの構成要素であり、個々のサービスに対応
- サブセグメント
  - セグメントの構成要素であり、個々のリモートコールやローカル処理に対応
- アノテーション
  - トレースをフィルタする際に利用可能なビジネスデータ
  - Key:Value型のデータ
- メタデータ
  - トレースに追加可能なビジネスデータ。トレースにフィルタには使用できない。
  - Consle画面では、JSON形式で表示される
- エラー
  - 正規化されたエラーメッセージとスタックトレース   

## X-Ray API
- トレースデータを送信、フィルタ、検索するためのAPIセットを提供
- SDKを利用しなくてもAWS X-Rayサービスに対して直接トレースデータを送信することも可能
- ローデータの取得も可能なので、収集されたデータを使った独自のアプリの構築も可能

## X-Ray SDK
- 単純なX-Ray APIへの操作はAWS SDKで提供
- X-Ray SDKを使えば、リクエストに関するメタデータを記録するためのコードを手動で実装する必要はない
- 以下の呼び出しに対するメタデータを自動でキャプチャするフィルタ機能を提供
  - AWS SDKを利用したAWSサービス呼び出し
  - HTTP(S)によるAWS以下のサービス呼び出し
  - DBアクセス（MySQL,PostgresSQL,DynamoDB)
  - キュー(Amazon SQS)
- ソースコード
  - Python: [aws/aws-xray-sdk-python](https://github.com/aws/aws-xray-sdk-python)
## X-Ray デーモン
- UDPでX-Ray SDKからのトラフィックを受信し、未加工のセグメントデータを収集
- 受信したデータを一定時間バッファしたのち、AWS X-Ray APIに送信する
- X-Rayデーモンがサポートされている環境
  - Linux
  - OS X
  - Windows
  - AWS Lambda
### インストール
#### パッケージのインストール
```
curl https://s3.dualstack.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-3.x.rpm -o ./xray.rpm
yum install -y ./xray.rpm
```
- ログの出力先は、`/var/log/xray/xray.log`です

#### IAMロールを設定する
- `AWSXRayDaemonWriteAccess`を追加する
#### モジュールをインストールする
```
pip3 install -r requirements.txt

cat requirements.txt
---
boto3
aws_xray_sdk
---
```
#### テストコードを実行してみる
- test.pyとして以下を記載する
  - これを実行してX-Rayのコンソールで表示されることを確認できる
  ```
  from aws_xray_sdk.core import xray_recorder

  xray_recorder.begin_segment('Xray test start')
  print('test message')
  sleep(1)
  xray_recorder.end_segment()
  ```
- boto3以外にも、対応しているモジュールがあります
  - すべてに対応させる
    ```
    from aws_xray_sdk.core import patch
    patch_all()
    ```
  - 一部のモジュールのみに対応させる
    ```
    from aws_xray_sdk.core import patch

    libs_to_patch = ('boto3', 'mysql', 'requests')
    patch(libs_to_patch)
    ```
- 注釈、メタデータを使う
  ```
  subsegment = xray_recorder.begin_subsegment('sub segment')
  print('test sub message')
  requests.get('https://www.google.com')

  dict={"a":1,"b":2,"c":3}
  subsegment.put_metadata('key', dict, 'namespace')
  subsegment.put_annotation('key', 'value')
  xray_recorder.end_subsegment()
  ```
## 参考ページ
- https://docs.aws.amazon.com/ja_jp/xray/latest/devguide/xray-concepts.html
- 