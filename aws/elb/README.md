# ELB
## Application Load Balancer
### リスナー
#### サポートしているプロトコル,ポート
- プロトコル
  - HTTP,HTTPS
- ポート
  - 1から65535
- WebSocket
  - HTTP,HTTPSの両方で利用することができる
- HTTP/2
  - HTTPSリスナーがネイティブでサポートする
  - ALBはHTTP/2で受けて、HTTP/1.1のリクエストに変換し、ターゲットグループの正常なターゲットにこれを分配します。HTTP/2のサーバpush機能は利用することができない