# ファイル
## SHIFT_JISのファイルを1行づつ読み込む
```
const fs = require('fs');
const readline = require('readline');
const config = require('config');
const iconv = require('iconv-lite');

const stream = fs.createReadStream(config.CsvFilename, { encoding: "binary" });
const reader = readline.createInterface(stream);

reader.on('line', (lineData) => {
  const buffer = new Buffer.from(lineData, 'binary');
  const utf8LineString = iconv.decode(buffer, "Shift_JIS");
});
```