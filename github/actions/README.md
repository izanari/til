# GitHub Actions

## 参考リソース

- [リファレンス](https://docs.github.com/ja/actions/reference)
- [GitHub Actions のコンテキストおよび式の構文](https://docs.github.com/ja/actions/reference/context-and-expression-syntax-for-github-actions)
- [環境変数の利用](https://docs.github.com/ja/actions/configuring-and-managing-workflows/using-environment-variables)
- [Github Actions の個人的ユースケース備忘録](https://dev.classmethod.jp/articles/github-actions-usecase-myself/)
- [GitHub Actions](https://nju33.com/github-actions)

## サンプル

- [GoogleCloudPlatform/github-actions](https://github.com/GoogleCloudPlatform/github-actions)
- [公式の action](https://github.com/actions)
- [actions/starter-workflows](https://github.com/actions/starter-workflows)

## 環境変数とコンテキスト

- デフォルトの環境変数とコンテキストがある

### デフォルトの環境変数

- デフォルトの環境変数は全て大文字の変数
  - https://docs.github.com/ja/github-ae@latest/actions/learn-github-actions/environment-variables#default-environment-variables

### コンテキスト

- コンテキストは、`gitubコンテキスト`や`envコンテキスト`などがある。
  - https://docs.github.com/ja/github-ae@latest/actions/learn-github-actions/contexts
- コンテキストを dump する方法：https://docs.github.com/ja/github-ae@latest/actions/learn-github-actions/contexts#example-printing-context-information-to-the-log

```
name: Context testing
on: push

jobs:
  dump_contexts_to_log:
    runs-on: ubuntu-latest
    steps:
      - name: Dump GitHub context
        id: github_context_step
        run: echo '${{ toJSON(github) }}'
      - name: Dump job context
        run: echo '${{ toJSON(job) }}'
      - name: Dump steps context
        run: echo '${{ toJSON(steps) }}'
      - name: Dump runner context
        run: echo '${{ toJSON(runner) }}'
      - name: Dump strategy context
        run: echo '${{ toJSON(strategy) }}'
      - name: Dump matrix context
        run: echo '${{ toJSON(matrix) }}'
```

#### コンテキストの使い方

- if / run の中で使う

```
      - name: DEBUG for if
        if: ${{ github.event_name == 'workflow_dispatch' }}
        run: |
          echo ${{ github.event_name }}
```

## Expressions

- [Expressions](https://docs.github.com/ja/github-ae@latest/actions/learn-github-actions/expressions)

### よく使う記述

- 環境変数を利用する

```
      - name: set env
        if: github.event_name == 'workflow_dispatch'
        run: |
          echo "EVENT=${{ github.event_name }}" >> $GITHUB_ENV
      - name: output env
        run: |
          echo ${{ env.EVENT }}
```

- ブランチ/タグ名を環境変数にセットする

```
      - name: set branch
        run: |
          echo "BRANCH=${GITHUB_REF##*/}" >> $GITHUB_ENV
      - name: output branch
        run: |
          echo ${{ env.BRANCH }}
```

### よく間違う記述

- step.env で設定した env はその step のみで有効
- もし、次の step でも使いたい場合は、`$GITHUB_ENV`を使いましょう

```
jobs:
  test-jobs:
    env:
      EVENT: dummy
    steps:
      - name: set env
        run: echo '${{ env.EVENT }}'  # test
        env:
          EVENT: test
      - name: echo env
        run: |
          echo '${{ env.EVENT }}' # dummy
```

### デバッグ

- `secret`に設定する
  - `ACTIONS_RUNNER_DEBUG`を**true**にする
    - ログ・ファイルをダウンロードすることができる
  - `ACTIONS_STEP_DEBUG`を**true**にする
    - Actions の画面でデバッグログが表示される
