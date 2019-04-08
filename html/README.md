# HTML
## CSS
### 特定のブラウザの時に要素を隠す
- 要jQuery
```
    <script>
      const ua = navigator.userAgent;
      const isIOS = ua.indexOf("iPhone");
      //console.log( isIOS );
      if ( isIOS > 0 ){
        $('div.sa-slideshow-route').css('display','none');
      }
    </script>
```