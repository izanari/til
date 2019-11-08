# AWS Key Management Service
- 暗号の技術は、アルゴリズムと鍵
  - 鍵の使い方
    - 対象鍵暗号
    - 公開鍵暗号
    - 非対称暗号
- 暗号の常識として秘密の暗号アルゴリズムを使用してはいけない
- 用語と英語表記
  - 平文：plaintext
  - 暗号化：encrypt
  - 暗号文：ciphertext
  - 複合化：decrypt
  - アルゴリズム：algorithum
  - 鍵：key
## 概要
- 暗号鍵の作成、管理、運用のためのサービス
  - マスターキーはFIPS 140-2 検定済暗号化モジュールによって保護されている
- AWSサービスとの統合
  - S3,EBS,RedShift,RDS,Snowballなど
- SDKとの連携でお客様の独自アプリケーションデータも暗号できる
- AWS CloudTrailと連動したログの生成による組み込み型監査
## AWS KMSで使用する用語
- CMK = Customer Master Key
  - 暗号鍵の頂点に位置するKMS上のAES256ビットの鍵
  - Customer Key -> Data Key -> データ
    - サービス個別のデータキーによるユーザーデータの暗号化
    - AWS KMS マスターキーによるデータキーの暗号化
- CDK = Customer Data Key
  - 実際の暗号化対象オブジェクトの暗号化・復号化に使用されるAES256ビットの鍵
  - KMSで生成され、CMKで暗号化された状態で保存される
- Envelope Encryption
  - マスターキーをデータ暗号化に直接利用するのではなく、マスターキーで暗号化した暗号キーで対象オブジェクトを暗号/複合する
## KMSでできること・できないこと
### できること
- 暗号鍵の生成と安全な保管
- 鍵利用の権限管理
- 鍵利用の監査
- 対象鍵暗号
- **最大4KBのデータ暗号化**
- AWSサービスとのインテグレーション
- 鍵のインポート

### （現時点で）できないこと
- シングルテナント
- 非対象鍵暗号
- 4KBを超えるデータの直接的な暗号化
- 鍵のエクスポート

## マスターキー
### マスターキーでできる管理作業
- マスターキーの作成、説明、一覧表示 ・マスターキーの有効化と無効化
- マスターキーにアクセス許可ポリシーを作成し、アクセス権限を表示する
- マスターキーの暗号化マテリアルの自動ローテーションの有効化と無効化
- AWS KMS マスターキーに暗号化マテリアルをインポート
- 素早い識別、分類および追跡のためのマスターキーのタグ付け
- マスターキーに関連付けられるフレンドリ名としてのエイリアスの作成、削除、一覧表示、更新 ・マスターキーを削除してキーのライフサイクルを完了する 

### 実行できる暗号関数
- データの暗号化、復号、再暗号化 プレーンテキストでサービスからエクスポートできるデータ暗号化キー、またはサービスから持ち出せないマスターキーで暗号化されたデータ暗号化キーの生成

## API
### 鍵管理API
- CreateKey
- CreateAlias
- EnableKeyRotation
- PutKeyPolicy
- ListKeys
- DescribeKey

### データAPI
- Encrypt
- Decrypt
- GenerateDataKey
  ```
  aws kms generate-data-key --key-id 2d89b038-6329-4ac8-b66e-xxxxxxxxx --key-spec AES_256
  (出力)
    {
        "CiphertextBlob": "AQIDAHhY5QWG9E2b2pLnETCLcrVnZeDcwXOYeOYbIkss34BOawEaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "Plaintext": "xxxxxxxxxxxxxxxxxxxxxxxx/xxxx",
        "KeyId": "arn:aws:kms:ap-northeast-1:xxxxxxxx:key/xxxxxxxxxxxxxxx"
    }
  ```

## 暗号鍵管理機能
- 鍵の生成
  - 単一のエイリアスおよび説明を付けたCMKの作成
- 鍵のアクセス管理
  - 鍵を管理するIAMユーザーおよびロールの定義
  - 鍵を使用できるIAM
  - 22ページ

## 参考サイト
- [AWS Key Management Service の概念](https://docs.aws.amazon.com/ja_jp/kms/latest/developerguide/concepts.html)
- 
