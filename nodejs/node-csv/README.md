# node-csv

Node.js で csv を扱うことができるモジュール

## サンプルコード

- CSV を読み込んで、最初の列だけを別のファイルに出力する

```
import * as parse from 'csv-parse'
import { stringify } from 'csv-stringify'
import { transform } from 'stream-transform'
import fs from 'fs'

const parseOption: parse.Options = { delimiter: [',', '\t'], fromLine: 2 }
const readStream = fs.createReadStream('./csv/test.csv')
const writeStream = fs.createWriteStream('./reports/test.csv')
readStream
  .pipe(parse.default(parseOption))
  .pipe(
    transform((record: string[]) => {
      return record.map((val, index) => {
        if (index === 0) return val
      })
    }),
  )
  .pipe(stringify({ header: true, columns: { title: 'ページタイトル' } }))
  .pipe(writeStream)

writeStream.on('close', () => {
  console.log('書き込み終了')
})
```
