# HTML
## ページ速度計測サイト
- [GTmetrix](https://gtmetrix.com/)
- [WEBPAGETEST](https://www.webpagetest.org/)
- [PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/)

## ページの読み込みを理解する
- [<script> タグに async / defer を付けた場合のタイミング](https://qiita.com/phanect/items/82c85ea4b8f9c373d684)
- [スクリプトの非同期読み込み(async, deferの違い)](https://www.wakuwakubank.com/posts/614-javascript-async-defer/)
## CSS
### 特定のブラウザの時に要素を隠す
- 要jQuery
```
    <script>
      const ua = navigator.userAgent;
      const isIOS = ua.indexOf("iPhone");
      //console.log( isIOS );
      if ( isIOS > 0 ){
        $('div.sa-slideshow').css('display','none');
      }
    </script>
```

## 高速化するためには
### 参考サイト
- [WEB ページの読み込み時間を短くしよう](https://qiita.com/tomochan154/items/2e2dc7b6eca006b41afb)