# PHP

## macOS + VSCode + Vagrant + docker + PHP 構成時の XDebug の設定

- Windows の VSCode + Ubunts + docker + PHP でも動作していることは確認済です。VSCode の`Remote - WSL`という機能拡張が必要らしいです。

- PHP 側の設定

```
yum -y install php-pear php-devel gcc gcc-c++ make
pecl install xdebug
cat << EOS > /etc/php.d/99-xdebug.ini
zend_extension=/usr/lib64/php/modules/xdebug.so
[xdebug]
xdebug.mode=debug
xdebug.start_with_request=yes
xdebug.discover_client_host=true
xdebug.log=/var/log/php-fpm/xdebug.log
xdebug.client_port=9003
EOS
```

- VSCode の launch.json の設定
  - `pathMappings`は各自の環境に応じて修正してください

```
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "stopOnEntry": false,
      "log": true,
      "pathMappings": {
        "/var/www/app": "${workspaceRoot}/app"
      }
    },
  ]
}
```

### 参考 URL

- [Xdebug 2 から 3 へのアップグレード](https://xdebug.org/docs/upgrade_guide/ja)
- [Vagrant(+Docker) 上の PHP アプリをデバッグ実行する](https://qiita.com/xanagi/items/b127ed3e5476cfd8eda7)
