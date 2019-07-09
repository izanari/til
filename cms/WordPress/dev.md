# WordPressの開発環境を作る
- [Dockerfile](./docker/Dockerfile.debug)を作成する
- [dokcer-compose.yml](./docker-compose.yml)を作成する
- vscodeの`PHP Debug`をインストールする
  - launch.json は以下とする。`pathMappings`以外はデフォルト設定です。
```
{
	// IntelliSense を使用して利用可能な属性を学べます。
	// 既存の属性の説明をホバーして表示します。
	// 詳細情報は次を確認してください: https://go.microsoft.com/fwlink/?linkid=830387
	"version": "0.2.0",
	"configurations": [
		{
			"name": "Listen for XDebug",
			"type": "php",
			"request": "launch",
			"port": 9000,
			"pathMappings": {
				"/var/www/html":"/PC上のパス/html"
			}
		},
		{
			"name": "Launch currently open script",
			"type": "php",
			"request": "launch",
			"program": "${file}",
			"cwd": "${fileDirname}",
			"port": 9000
		}
	]
}
```
## はまるポイント
- `docker-compose.yml`のファイル名を変更すると、うまく動作しなくなる
- `Docker`ファイル内にログを出力先を記述すると、entrypoint.shで`sed`のエラーが発生しコンテナが起動しません
## 参考URL
- https://qiita.com/gigosa/items/90431be7a6a79db78480