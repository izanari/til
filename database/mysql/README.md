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
mysql> grant all on testdb.* to scott@'%' identified by 'tiger';
```
## ユーザー一覧を表示する
```
select Host,User from mysql.user;
+----------------------------------------------+--------+
| Host                                         | User   |
+----------------------------------------------+--------+
| 127.0.0.1                                    | root   |
| ::1                                          | root   |
| localhost                                    |        |
| localhost                                    | scott  |
| localhost                                    | root   |
+----------------------------------------------+--------+
```
## 権限の確認をする
```
MariaDB [(none)]> SHOW GRANTS FOR root@localhost;
+---------------------------------------------------------------------+
| Grants for root@localhost                                           |
+---------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |
+---------------------------------------------------------------------+
```
