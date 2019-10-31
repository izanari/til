# Movable Type
## テンプレートタグ
### パスをルート相対にする
- 変数をウェブサイトのモジュールで定義しておく
```
<mt:SetVars>
site_url=<$mt:WebSiteUrl$>
rootpath=<$mt:WebSiteRelativeUrl$>
</mt:SetVars>
```
- モジュールを読み込み、replaceで置換する
```
<$mt:include module="共通モジュール" parent="1">

<li><a href="<mt:EntryPermalink with_index="0" replace="$site_url","$rootpath">"><mt:EntryTitle /></a></li>

```