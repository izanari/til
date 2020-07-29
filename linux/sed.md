# sed
## 文字列を置換する
- mac版
  - 参考：[Macの（BSD版）sed での上書き保存](https://qiita.com/catfist/items/1156ae0c7875f61417ee)
```
sed -i '.bak' 's/1/hogehoge/' test.txt 
```

- 指定した行の文字列を置換する
```
sed -i -e "286 s/AllowOverride None/AllowOverride All/" /usr/local/apache2/conf/httpd.conf
```
- 指定した行のコメントアウトを解除する
```
sed -i -e "199 s:^#::" /usr/local/apache2/conf/httpd.conf
```
- 文字列を含む行の先頭に#を入れる
  - この例は、proxy_ajp_modulesという前置しているのが検索条件となる
```
sed -i -e '/proxy_ajp_module/s/^/#/' hoge.conf
```

- Apache confのコメント行を削除する
```
sed -i -e '/^# [A-Za-z<"0-9]/d' httpd.conf
sed -i -e '/^#$/d' httpd.conf
sed -i -e '/^ .#/d' httpd.conf
sed -i -e '/^    #/d' httpd.conf
sed -i -e '/^$/d' httpd.conf

```

## 参考サイト
- [sedでこういう時はどう書く?](https://qiita.com/hirohiro77/items/7fe2f68781c41777e507)