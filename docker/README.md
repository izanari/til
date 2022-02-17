# Docker

## リソース

- [Reference documentation](https://docs.docker.com/reference/)

## コマンド

- イメージのビルド
  - `-t`は`name:tag`でイメージの名前とタグをつける

```
docker build -t imgname:0.1 .
```

- コンテナの起動

```
docker run -p hostport:containerport --name containername imgname:0.1
```

- 実行しているコンテナを表示する

```
docker ps
```

- コンテナにログインする
  - `-it`フラグで、pseudo-tty を割り当てて stdin を開いたままにしてコンテナとやりとりができる

```
docker exec -it コンテナID bash
```

- docker 内でのメタデータを調べる

```
docker inspect コンテナID
```

- 特定のフィールドを調査する

```
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' [コンテナ ID]
```

## よくやる設定

### php-apache

- apche のリダイレクトを有効にする
- php から mysql に接続できるようにする

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

```
docker commit exitedしたコンテナID 適当なコンテナ名
docker run --rm -it 適当なコンテナ名 sh
```

## Dockerfile の書き方サンプル

### echo した結果をファイルに出力する

```
RUN { \
	echo '<IfModule mod_rewrite.c>'; \
	echo 'RewriteEngine On'; \
	echo 'LogLevel alert rewrite:trace4'; \
	echo '</IfModule>'; \
	} > /etc/apache2/mods-available/rewrite.conf ;
```

### 設定ファイルを sed で書き換える

```
RUN set -x && \
	sed -i -e 's/^<\/VirtualHost>/<Directory \/var\/www\/html>\n  AllowOverride All\n<\/Directory>\n<\/VirtualHost>/g' /etc/apache2/sites-available/000-default.conf;
```

### 指定した行数を置換する

```
RUN sed -i -e '346s/common/combined/g' /usr/local/apache2/conf/httpd.conf
```

## コンテナから自分のホストを参照するには？

- `host.docker.internal` で参照することができます
  - 参照 URL: https://docs.docker.com/docker-for-mac/networking/
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

- Name が`always`になっていると起動されてしまいます。そこで、このコマンドで変更をかけます。

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

## alipine Linux にログインする

- `-q`は ID だけを表示してくれる

```
docker pull alpine:3.12.0
docker run -itd --rm --name "alpine" alpine:3.12.0
docker stop $(docker ps -q)
```
