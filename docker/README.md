# Docker

## たまに使うコマンド
### コンテナが起動しないときにイメージを消す
```
docker images | awk '/<none/{print $3}' | xargs docker rmi
```
### 起動しないコンテナにログインする
- 参考URL
  - https://gendosu.jp/archives/2838
  - https://qiita.com/ryurock/items/d1372e9b4d561343a308

## Dockerfileの書き方サンプル
### echoした結果をファイルに出力する
```
RUN { \
	echo '<IfModule mod_rewrite.c>'; \
	echo 'RewriteEngine On'; \
	echo 'LogLevel alert rewrite:trace4'; \
	echo '</IfModule>'; \
	} > /etc/apache2/mods-available/rewrite.conf ; 
```

### 設定ファイルをsedで書き換える
```
RUN set -x && \
	sed -i -e 's/^<\/VirtualHost>/<Directory \/var\/www\/html>\n  AllowOverride All\n<\/Directory>\n<\/VirtualHost>/g' /etc/apache2/sites-available/000-default.conf;
```

### コンテナから自分のホストを参照するには？
- `host.docker.internal` で参照することができます
  - 参照URL: https://docs.docker.com/docker-for-mac/networking/
  - サンプル：`echo 'xdebug.remote_host=host.docker.internal'; `

