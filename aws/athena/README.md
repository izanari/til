# Athena
## Apache logs
- 集計query
  - カウントと転送量を集計する
```
SELECT count(response) , sum( try_cast(bytes as BIGINT) ) 
FROM 
 "default"."hogehoge" 
 where request like '/img/%'
```
