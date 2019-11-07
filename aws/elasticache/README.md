# Amazon ElastiCache
- 分散インメモリキャッシュ環境のセットアップ、管理、およびスケーリング、冗長構成等を容易に構築することができるサービス
- フルマネージド
  - キャッシュクラスタを数クリックで起動
- パフォーマンス
  - memcached or redis をサポート
- セキュリティ
  - セキュリティグループ、VPC対応、暗号化

## Amazon ElastiCache for memcached
- Cache Clusterという論理グループにCache Nodeを起動
- Cache Group全体のConfiguration EndpointとCache Node単体を表すNode Endpointの2種類のエンドポイントがある
- **バックアップ機能は無い**
- スケープアウトさせる場合はコンシステントハッシュなどを使用する必要がある
### Auto Discovery for memcached
- Auto Discovery用に対応した専用のライブラリがAWSから提供されている
  - PHP: ElastiCache Auto Discovery Client
- DNSエイリアスとして提供され稼働しているノードリストを表示する
- Auto Discoveryクライアント
  - 接続先として設定すると全ノードを自動取得・設定し、接続をする

## ElastiCache for Redis
- 複数のClaster Groupで構成されるReplicatiton Groupを構成
- 書き込み先を示すPrimary EndpointとCache Node単体を示すNodeEndPointの2種類のアクセス用エンドポイントがある
- Multi-AZ構成の自動フェイルオーバーにも対応
- **Snapshotベースでのバックアップ・リストアに対応**
- Redis Clasterを使うためのclaster-mode(3.2以降)
- クライアント認証、暗号化に対応
- 使えない機能
  - CONDIF,SLAVEOFなど一部コマンドは無効化されている
- クライアントライブラリはAWSからは提供していない
  - PHP: phpredis
  - Python: Redis-py
### Replication
- リードレプリカ
  - **耐障害性向上（ただし非同期レプリケーション）**
  - Read性能のスケールアウト
  - Replication Group内にマスター１台、レプリカ最大５台
  - ReplicaのReplicaは未対応
#### 構成例
- リードレプリカを複数のAZに配置可能
- 同一AZのリードレプリカを参照し高速なデータ取得が可能
- AZ障害時のデータ保全が可能
- フェイルオーバー
  - ノード障害時は自動フェイルオーバーがかかる
### バックアップ・リストア
- Snapshotを取得しS3へバックアップリストアが可能
- SnapshotからRedisのRDBファイルを生成し、S3にExportする事も可能
- Cache Claster作成時にSnapshotやRDBファイルを指定することも可能

### Redis Cluster
- データをシャード単位に分散保存することで最大15シャード、6TiBのデータが保存可能
- 最大2000万/秒の読み込み、450万/秒の書き込み性能を出せる
- 16384ハッシュスロット・クラスタ
- 1〜15シャード
  - 各シャード毎にプライマリーノードと最大５つのレプリカノードを持つ
- Redis cluster-mode 有効と無効の場合のまとめ
  
|機能|Enabled|Disabled|
|---|---|---|
|Filover|15-30sec(Non-DNS)|〜1.5mim(DNSベース)
|Failober risk|Writes影響は部分的、Readsは問題無し|Write全体影響あり、Readsは問題無し
|Performance|クラスタサイズに依存（90ノード-15ノードのプライマリ+0-5ノードのシャード毎のレプリカ|6ノード(1ノードのプライマリ+0-5ノードのレプリカ)
|Max connections|プライマリ(65,000x15)=975,000 レプリカ(65,000x75)=4,875,000|プライマリ：65,000 レプリカ：(65,000x5=325,000)
|Storage|6+ TiB|407GB
|Cost|小さいノードで並べることができるがお金はDisableよりかかる|大きなノードであればあるほどコストがかかる

- Redis Clusterはオンラインでリサイズすることができる
- Cloudwatchのアラームからオンラインでリサイズさせることができる
  
### CloudWatchによるElastiCacheの監視
- 主に監視する項目
  - CPUUtilization(CPU使用率)
    - Memcached:マルチコア対応なので90%超えでもOK
    - Redisはシングルコアのため、4コアだと25%が最大値
  - CacheHits/CacheMisses
  - Evictions
    - キャッシュメモリ不足起因のキャッシュアウト発生回数
  - SwapUsage
    - 低いほどいい
  - メモリ使用量
    - BytesUsagedForCacheItems(Memcached)
    - BytesUsagedForCache(redis)
  - Replica Log
    - レプリケーション遅延


## ユースケース
- セッション管理
- DBキャッシュ
- APIs
- IOT
- ストリームデータ分析
- Pub/Sub
- ソーシャルメディア
- 単体のDB
- リーダーボード

## 戦略
- 遅延読み込み戦略
  - 必要なときにのみキャッシュにデータを読み込むキャッシュ戦略です。 
  - Amazon ElastiCache はインメモリ key/value ストアであり、アプリケーションとそのアクセス先のデータストア (データベース) 間にあります。アプリケーションがデータをリクエストする場合は、常に ElastiCache キャッシュに最初にリクエストを行います。データがキャッシュにあり最新である場合、ElastiCache はアプリケーションにデータを返します。データがキャッシュに存在しないか、有効期限が切れている場合、アプリケーションはデータストアにデータをリクエストします。その後、データストアはアプリケーションにデータを返します。次に、アプリケーションはストアから受信したデータをキャッシュに書き込みます。これにより、次回のリクエスト時に、データをよりすばやく取得できます。
- 書き込みスルー戦略
  - データがデータベースに書き込まれると常にデータを追加するか、キャッシュのデータを更新します。
  - 欠点
    - ほとんどのデータは読み取られることがなくリソースの無駄になる

