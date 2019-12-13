# Apache
## 設定Tips
### セキュリティ対策
```
  ServerSignature Off
  Header append X-Frame-Options SAMEORIGIN
  Header append X-Content-Type-Options nosniff
  Header append X-XSS-Protection "1; mode=block"
```
### ローカルホストからのアクセスを許可する
```
<Directory /var/www/html>
    Options -Indexes +Includes +FollowSymLinks
    AllowOverride All
    <RequireAll >
      Require method GET POST
      <RequireAny >
        Require ip 127.0.0.1
      </RequireAny>
    </RequireAll>
</Directory>
```
### 基本認証
```
  <Directory /var/www/html/hogehoge>
    AuthType Basic
    AuthName "hogehoge"
    AuthUserFile /var/www//etc/.htpasswd
    <RequireAll >
      <RequireAny >
        Require user foo
      </RequireAny>
    </RequireAll>
  </Directory>
```
### キャッシュを無効にする
```
  <Location "/no-cache-contents/">
    Header set Cache-Control "private, no-store, no-cache, must-revalidate"
    Header set Expires "Mon, 26 Jul 1997 05:00:00 GMT"
    Header set Pragma "no-cache"
  </Location>
```
### ブラウザにキャッシュをさせる
```
  ExpiresActive On
  <LocationMatch "/cache-on-contents/(.*)\.(css|png|js|gif)$">
    ExpiresDefault "access plus 60 minutes"
  </LocationMatch>
```

### コンテンツを圧縮して配信する
#### Apache2.2の場合
```
        <IfModule mod_deflate.c>
                #SetOutputFilter DEFLATE
                AddOutputFilterByType DEFLATE text/html
                AddOutputFilterByType DEFLATE text/css
                AddOutputFilterByType DEFLATE text/javascript
        </IfModule>
```
よく`SetOutputFilter DEFLATE`を記述しているサイトがあるが、これを記述するとMIMEタイプに関係なくすべてが圧縮されてしまいます。html/css/jsだけを圧縮したい場合は上記のように記述しましょう

### リダイレクト
- [RewriteRuleのフラグと、RewriteCondの変数一覧](https://qiita.com/tsukaguitar/items/e37245260f0b1407341d)
```
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
# index.php は何もしない。ハイフンは何もしない
# [L]はそこで終了
RewriteRule ^index\.php$ - [L]
# ファイルが実在すれば除外
RewriteCond %{REQUEST_FILENAME} !-f
# ディレクトリがあれば除外
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
```

- 上記でリダイレクトしても`REQUEST_URI`ではリダイレクトする前のリクエストURIを取得することができます

### 証明書の確認方法
- [保存した証明書ファイルの内容を確認する方法](https://jp.globalsign.com/support/faq/07.html)
- 証明書ファイルの内容を確認
  ```
  openssl x509 -text -noout -in /[FilePath]/[CertFile]
  ```
- 秘密鍵ファイルの内容を確認
  ```
  openssl rsa -text -noout -in /[FilePath]/[KeyFile]
  ```
- CSRファイルの内容を確認
  ```
  openssl req -text -noout -in /[FilePath]/[CSRFile]
  ```