# Docker

## よくやる設定
### php-apache
- apcheのリダイレクトを有効にする
- phpからmysqlに接続できるようにする
```
FROM php:7.3-apache

RUN \
  { apt-get update; \
    apt-get install -y zlib1g-dev libzip-dev; \
    docker-php-ext-install zip; \
    docker-php-ext-install mysqli; \
    docker-php-ext-configure zip; \
    docker-php-ext-configure mysqli ; \
    ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load; \
  }
```

## たまに使うコマンド
### コンテナが起動しないときにイメージを消す
- 古いやり方
```
docker images | awk '/<none/ {print $3}' | xargs docker rmi
```
- 最近のやり方
```
docker image prune
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


## その他
### Docker を起動した時に、勝手にコンテナが起動されてしまうのをとめる
- まずは調べる
```
docker inspect コンテナID | grep -A 3 RestartPolicy
            "RestartPolicy": {
                "Name": "always",
                "MaximumRetryCount": 0
            },
```
- Nameが`always`になっていると起動されてしまいます。そこで、このコマンドで変更をかけます。
```
 docker update --restart=no コンテナID
 ```
- 確認します
```
docker inspect dfb274ab1b7d | grep -A 3 -i "restartpolicy"
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
```
