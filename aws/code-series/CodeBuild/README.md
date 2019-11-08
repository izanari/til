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