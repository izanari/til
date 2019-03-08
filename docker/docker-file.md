# Docker ファイルの書き方サンプル

## echoした結果をファイルに出力する
```
RUN { \
	echo '<IfModule mod_rewrite.c>'; \
	echo 'RewriteEngine On'; \
	echo 'LogLevel alert rewrite:trace4'; \
	echo '</IfModule>'; \
	} > /etc/apache2/mods-available/rewrite.conf ; 
```

## 設定ファイルをsedで書き換える
```
RUN set -x && \
	sed -i -e 's/^<\/VirtualHost>/<Directory \/var\/www\/html>\n  AllowOverride All\n<\/Directory>\n<\/VirtualHost>/g' /etc/apache2/sites-available/000-default.conf;
```