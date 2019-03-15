# CloudFormation
## 気をつけるところ
- `AWS::CertificateManager::Certificate`を`ValidationMethod: DNS `した時、すぐに承認されないとロールバックされてリクエストが消されてしまいます。ロールバックは180分までしか設定できないから、手動で作成したほうが無難。