# CloudFormation
## リファレンス
- [パラメーター](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)
- [疑似パラメーター](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html)
- 
## 気をつけるところ
- `AWS::CertificateManager::Certificate`を`ValidationMethod: DNS `した時、すぐに承認されないとロールバックされてリクエストが消されてしまいます。ロールバックは180分までしか設定できないから、手動で作成したほうが無難。