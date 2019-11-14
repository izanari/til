# sed
## 文字列を置換する
- mac版
  - 参考：[Macの（BSD版）sed での上書き保存](https://qiita.com/catfist/items/1156ae0c7875f61417ee)
```
sed -i '.bak' 's/1/hogehoge/' test.txt 
```

## 指定した行の文字列を置換する
```
sed -i -e "286 s/AllowOverride None/AllowOverride All/" /usr/local/apache2/conf/httpd.conf
```

## 指定した行のコメントアウトを解除する
```
sed -i -e "199 s:^#::" /usr/local/apache2/conf/httpd.conf
```

## 参考サイト
- [sedでこういう時はどう書く?](https://qiita.com/hirohiro77/items/7fe2f68781c41777e507)