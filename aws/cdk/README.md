# cdk
- [aws/aws-cdk](https://github.com/aws/aws-cdk)
  - [aws-samples/aws-cdk-examples](https://github.com/aws-samples/aws-cdk-examples)
- [CDKで使えるパッケージ](https://github.com/aws/aws-cdk/tree/master/packages/%40aws-cdk)
- [AWS CDK](https://docs.aws.amazon.com/cdk/api/latest/)
  - [AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html)
- [WorkShop](https://cdkworkshop.com/)
    - [日本語版WorkShop](http://bit.ly/cdkworkshopjp)
      - リソースのダウンロードが始まります

## 使い方
- 初期化する
  ```
  cdk init app --language=python
  ```
  - サンプルアプリのファイルを含みたい場合
    ```
    cdk init sample-app --language=python
    ```
- deploy

### pyenvを使う時
- VSCodeを使って開発することが多いと思う。その際、pyenvすると、pyenv後にインストールしたモジュールが読み込めなくなります。これは、VSCode起動後のpythonとpyenvしたpythonが異なるためです。VSCodeがpyenvしたpythonを使うよう設定しましょう。
  - `.vscode/settings.json`
    ```
        {
            "python.pythonPath": "${workspaceFolder}/.env/bin/python"
        }
    ```


### app.py以外を使い方場合
- 方法は２通り
    - `-a`で渡す
        ```
        cdk -a 'python3 hoge.py' deploy
        ```
    - `cdk.json`で定義する
        ``` json
        {
            "app": "python3 hoge.py"
        }
        ```
### パラメータを渡す
- 方法は２種類あります。併用することも可能です。
#### ファイルを使う場合
- `cdk.json`で定義しておく
```
{
    "app": "python3 app.py",
    "context": {
        "author":"Yoshinari Izawa",
        "dev": {
            "BucketName": "dev.cdk-sample"
        },
        "stage": {
            "BucketName": "stage.cdk-sample"
        },
        "prod": {
            "BucketName": "prod.cdk-sample"
        }
    }
}
```

- ソース内では以下のように取得する
```
runmode = app.node.try_get_context("mode")
params = app.node.try_get_context(runmode)
print( params["BucketName"] )
```

#### 引数で渡す
```
cdk -c mode=stage deploy
```


## 参考サイト
- [【AWS CDK】CDK標準の3種類のConstructを使って、AWSリソースをデプロイしてみた](https://dev.classmethod.jp/cloud/aws/aws-cdk-construct-explanation/)
- [AWS Cloud Development Kit (AWS CDK)でECS環境を構築してみた](https://dev.classmethod.jp/cloud/aws/aws-cdk-getting-ecs/)
- 