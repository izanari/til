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

- `git push origin master` はブランチ指定、もし、すべてのブランチをpushしたい時は、`git push -u origin --all` とする。
