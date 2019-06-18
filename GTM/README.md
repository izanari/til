# GTM
## GTMのカスタムイベントを使う
### GTMの設定
- トリガーの設定
  - タイプ：カスタムイベント
  - イベント名：ckickChange （ここは適切な名前をつける)
  - 発生場所：PageURL等、適切な場所とします
- 変数の設定
  - イベントアクション、イベントカテゴリ、イベントラベルを変数のタイプ：データレイヤー変数でセットする
  - イベント名をそのままイベントカテゴリにしたい時は、変数のタイプ：カスタムイベントを設定する
- ソースコード
```
                    window.dataLayer = window.dataLayer || [];
                    dataLayer.push({ 'event':'clickChange', 'mycategroy':'hogehoge', 'myaction':'fugafuga',  'mylabel':'kocyokocyo' });
```
何かのイベントに返納して、このようなJSを出力します。