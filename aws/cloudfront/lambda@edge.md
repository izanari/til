# lambda@ege
- node6.10 or 8.10 でしか動作しない
## CloudFrontから渡ってくるevent
### リクエストビューワーの場合
S3をオリジンにした場合です
- event.Records[0]の中身
```
{ config: 
{ distributionDomainName: '＊＊＊＊＊＊.cloudfront.net',
distributionId: '*****',
eventType: 'origin-request' },
request: 
{ clientIp: 'xxx.xxx.xxx.x',
headers: [Object],
method: 'GET',
origin: [Object],
querystring: '',
uri: '/test/index.html' } } }
```
- headers オブジェクトの中身
```
[ { key: 'If-Modified-Since',
value: 'Thu, 28 Feb 2019 10:51:30 GMT' } ],
'if-none-match': 
[ { key: 'If-None-Match',
value: '"**********"' } ],
'user-agent': [ { key: 'User-Agent', value: 'Amazon CloudFront' } ],
via: 
[ { key: 'Via',
value: '2.0 xxxxxxxxxx.cloudfront.net (CloudFront)' } ],
'x-forwarded-for': [ { key: 'X-Forwarded-For', value: 'xxx.xxx.xx.x } ],
host: 
[ { key: 'Host',
value: '*******.s3.amazonaws.com' } ] }
```
- origin オブジェクトの中身
```
{ authMethod: 'origin-access-identity',
customHeaders: {},
domainName: '*****.s3.amazonaws.com',
path: '',
region: 'ap-northeast-1' } }
```
## URLを書き換えるサンプル
```
const util = require('util');

exports.handler = async(event, context, callback) => {
    
    var request = event.Records[0].cf.request;
    var url = request.uri;
    var urls = url.split('/');
    
    console.log(util.inspect(urls));
    
    var changedURL = "";
    var changedQS = "";
    
    for( let i in urls ){
        
        if ( urls[i] == ""){
            continue;
        }
        
        if (i==1) {
            changedURL = "/" + urls[1]+'.html';
        }else{
            changedQS += "param" + i + "=" + urls[i] + "&";
        } 
    }
    
    request.uri = changedURL;
    request.querystring = changedQS;
    console.log(util.inspect(request));
    
    callback(null, request);
};
```
## ハマるポイント
- CloudWatchのロググループは、`/aws/lambda/us-east-1.FunctionName`というように、lambda@edgeが実行されたリージョンがfunctionnameの前に付与されます。
  - [AWS Lambda@Edgeのログはどこ？AWS Lambda@Edgeのログ出力先について](https://dev.classmethod.jp/cloud/aws/where-is-the-lambda-edge-log/) を参照ください
  - Lambda をコンソールからテストをすると、us-east-1のCloudWatch Logsに出力されるため、そのままログを見ていると出力されねーってことになります。ここ要注意です。
## 参考すべきページ
- [5分で読む！Lambda@Edge 設計のベストプラクティス](https://dev.classmethod.jp/cloud/aws/lambda-edge-design-best-practices/)
- [Amazon CloudFrontとAWS Lambda@EdgeでSPAのBasic認証をやってみる](https://dev.classmethod.jp/cloud/aws/cloudfront-lambdaedge-basic-spa/)
- [Lambda@Edge で URLパスを書き換える](https://dev.classmethod.jp/cloud/aws/lambdaedge-rewrite-url-path/)

### キャッシュ時間について
- [【新機能】Amazon CloudFrontに「Maximum TTL / Default TTL」が設定できるようになりました！](https://dev.classmethod.jp/cloud/aws/introduction-to-max-ttl-on-cloudfront/)
- [Amazon CloudFrontのキャッシュ期間をコントロールする(2015年6月版](https://dev.classmethod.jp/cloud/cloudfront-cache-control/)
- [コンテンツがエッジキャッシュに保持される期間の管理 (有効期限)](https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/Expiration.html)