# CodeDeploy
## ログ・ファイル
- 各ステージで実行しているシェルの結果
  - `/opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log`に記録されている
    - stdoutがそのまま記録されるため、シェルの中で、`set -x`しておいたほうがよい