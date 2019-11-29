# CodeBuild
## Buildspec
- Buildspec名は変更することができる
## アーティファクト
- 暗号化することができる
  - AWS KMSカスタマーキーを指定する。デフォルトはS3用のAWS管理のカスタマーキーになります
  - 指定は、```arn:aws:kms:<region-ID>:<account-ID>:key/<key-ID>```
- キャッシュ
  - キャッシュタイプは2種類ある
    - AmazonS3
    - ローカル
      - DockerLayerCache
      - SourceCache
      - CustomCache
        - 有効な場合、実行時にbuildspec.ymlから追加のキャッシュパスを読み取る
## 設定
- ログ
  - S3とCloudWatchに出力することができる
- キャッシング
  - [CodeBuild でキャッシングをビルドする](https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/build-caching.html)
  - 2種類のモードがある
    - S3
      - 小規模な中間ビルドアーティファクトに適したオプション
      - ネットワーク経由で転送するには長い時間がかかる場合があるため、大規模なビルドアーティファクトには適していません
    - ローカルキャッシュ
      - １つ以上を選択する
      - キャッシュモード
        - ソースキャッシュモード
          - Gitリポジトリのみ有効(Github,GHE,Bitbucket)
          - コミット間の変更のみをプルします
        - Dockerレイヤーキャッシュモード
          - 大きなDockerイメージを構築または取得するプロジェクトに適している
        - カスタムキャッシュモード
          - buildspecファイルで指定したディレクトリをキャッシュします
          - ソースキャッシュ・Dockerレイヤーキャッシュのいずれにも適していいない場合に使用される
          - ディレクトリのみ、個々のファイルは指定できない
- 通知
  - buildの失敗、成功は、CloudWatch Event+SNSで行う
    - [CodeBuild のビルド通知サンプル](https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/sample-build-notifications.html)