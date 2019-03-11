# mysql
## コマンドの出力をファイルに出力する
```
mysql -u root -p -e "show variables;" > show_val.txt
```
## ファイルに書いたSQLを実行する
```
mysql> source hogehoge.sql
```