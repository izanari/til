# mysql
## コマンドの出力をファイルに出力する
```
mysql -u root -p -e "show variables;" > show_val.txt
```
## ファイルに書いたSQLを実行する
```
mysql> source hogehoge.sql
```
## 現在ログインしているユーザを確認する
```
mysql> select current_user();
```
## データベースに作成してアクセスできるようにする
```
mysql> create database testdb default charset utf8;
mysql> grant all on testdb.* to scott@localhost identified by 'tiger';
mysql> grant all on testdb.* to scott@'%' identified by 'tiger';ß
```