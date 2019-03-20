# Code Build
## buildspec.yml
- Code Build におけるビルドタスクは、`buildspec.yml`に記述する
- 各フェーズ
  - install
    - ビルド環境のパッケージインストールがある場合は、そのコマンドを実行する
  - pre_build
    - ECRにサインインする、npmの依存関係をインストールする
  - build
  - post_build
    - DockerイメージをECRにpushする
    - SNSのビルド通知を送信する
  - finally:
    - commandsブロックが実行された後に実行される
    - commandsブロックが失敗しても実行される

## 参照ドキュメント
- [CodeBuild のビルド仕様に関するリファレンス](https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/build-spec-ref.html)
- [CodePipeLineを使ってLambdaへの自動デプロイ](https://qiita.com/RyujiKawazoe/items/38411271230f9e112253)