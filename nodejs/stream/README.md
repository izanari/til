# Stream

## Transform

### アルファベットを大文字する変形する Transform を実装する

- [Node.js: Stream をパイプと Transform で変形する方法](https://qiita.com/suin/items/8bf63cd457d75b709530)より

```
import { Transform, TransformCallback, Readable } from 'stream'

const noop = new Transform({
  transform(chunk: string | Buffer, encoding: string, done: TransformCallback): void {
    this.push(chunk.toString().toUpperCase())
    done()
  },
})

const stream = Readable.from(['Hello', ' ', 'World', '\n'])
stream.pipe(noop).pipe(process.stdout)
```
