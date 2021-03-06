# git

## ローカルディレクトリをgit pushする
1. リモートリポジトリを作成しておく
1. PC上で以下のコマンドを実行する
```
git init
git add .
git commit -m 'first commit'
git remote add origin クローンURL
git push origin master 
```

- addする時に、`origin`ではなく、名前を変えることもできる。例えば、originからpullしたものを別のリポジトリに追加したい時は名前をつけることで簡単にpushできる。


- `git push origin master` はブランチ指定、もし、すべてのブランチをpushしたい時は、`git push -u origin --all` とする。

## 差分を見る
```
git log origin/master..master
```

## リモートリポジトリを追加する
- リモートリポジトリを作成します。この時、Clone-URLを控えておきます
- `remote add`でリポジトリを追加します
- `push`でローカルのmasterブランチをリモートリポジトリに反映しています
```
git remote add github Clone-URL 
git push -u github master 
```
## git push -f はやめておこう
- [git push -f をやめて --force-with-lease を使おう](https://qiita.com/wMETAw/items/5f47dcc7cf57af8e449f)
  - ```
    git push --force-with-lease origin master
    ```

## git push を取り消す（歴史を書き換える）
- ローカルの変更を取り消す
    ```
    git reset --hard HEAD^
    ```
- 強制的にpushする
    ```
    git push -f origin master
    ```
- 参考URL
  - http://www-creators.com/archives/2020

## リモートのブランチを指定してpushする
- ローカル:master --> remote:remotebranch へpushしたい場合
    ```
    git push remote master:remotebranch
    ```


## 設定を確認する
```
git config --system --list
```
`--system`部は、`--global`、`--local`にすることでそれぞれの設定を確認することができる

## よく使うコマンド
### ブランチ編
- リモートブランチを表示する
    ```
    git remote
    git remote -v
    ```
- ローカルとリモートのブランチを一覧表示する
    ```
    git branch -a
    ```
- リモートリポジトリでは削除したのにブランチ表示されるとき
    ```
    git remote show origin
    git remote prune origin
    ```