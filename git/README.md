# git

## ローカルディレクトリをgit pushする
1. git リポジトリを作成しておく
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

## コマンド
### 設定を確認する
```
git config --system --list
```
`--system`部は、`--global`、`--local`にすることでそれぞれの設定を確認することができる