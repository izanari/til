# python
## 参考になるサイト/ページ
- [わかっちゃいるけど、やめられない - Pythonあるある凡ミス集](https://qiita.com/tag1216/items/3db4d58b2f4e58c86103)
- [入門系記事にはない、実践/現場のPythonスクレイピング流儀【2019年最新】](https://qiita.com/ryuta69/items/c84501993635c72540a7)
- [Google Python スタイルガイド](http://works.surgo.jp/translation/pyguide.html)
##  `if __name__ == '__main__':`のこと
- python hogehoge.py から実行した時だけtrueになる式
- import された場合はfalseになる

## デコレーター
- [Pythonのデコレータについて](https://qiita.com/mtb_beta/items/d257519b018b8cd0cc2e)
- [Python デコレータ再入門　 ~デコレータは種類別に覚えよう~](https://qiita.com/macinjoke/items/1be6cf0f1f238b5ba01b)
## ゲッター、セッター
```
class Test(object):
    def __init__(self):
        self._x = None

    @property
    def x(self):
        print "property x."
        return self._x

    @x.setter
    def x(self, value):
        print "setter x."
        self._x = value

    @x.deleter
    def x(self):
        print "deleter x."
        del self._x

if __name__ == "__main__":
    test = Test()

    test.x = 1
    test.x
    del test.x

```