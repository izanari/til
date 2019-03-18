# pip
## よく使用するコマンド
### pip のバージョンを確認する
``` shell
pip --version
```

### pip自身をアップデートする
``` shell
pip install --upgrade pip
```
### pip でインストールしたパッケージを表示する
``` shell
pip list
```
### パッケージの情報を表示する
``` shell
pip show パッケージ名
```
### パッケージを検索する
``` shell
pip search 検索文字
```
### requirements.txt の内容に従って、パッケージをインストールする
- インストール先の指定も行う

``` shell
pip install -r requirements.txt -t インストール先ディレクトリ
```
### 現在の環境からrequirements.txtを生成する
```shell
pip freeze > requirements.txt
```
### パッケージをアンインストールする
``` shell
pip uninstal パッケージ名
```
### パッケージをアップグレードする
``` shell
pip install -U パッケージ名
```