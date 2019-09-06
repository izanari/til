# GraphCMS
- https://graphcms.com/

## 各種設定
- モデル
  - 名前： informations 
  - 
## queryの書き方
- Publishedステータスの記事タイトルだけを取得する
    ```
     {"query": "query { informations( where: { status: PUBLISHED }) { title } }"} 
    ```
- タイトルと公開日だけを取得する
    ```
    {"query": "query { informations { title , publishdate } }"}
    ```