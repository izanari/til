# curl
## 使い方
- ヘッダーを見る
```
curl -I https://hogehoge
```

- ヘッダーとボディを見る
```
curl -i https://hogehoge
```

- SSL証明書の警告を無視する
```
curl -k https://hogehoge
```

- 基本認証のユーザーを指定する
```
curl https://hogehoge -u foo
```
パスワードの指定まで行う場合は、foo:passとする

- HTTPヘッダーを付与してアクセスする
```
curl -H 'x-from-hogehoge: true' http://hogehoge
```