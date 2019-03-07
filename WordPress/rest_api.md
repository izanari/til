# WordPressのREST API
## APIを禁止したい
- APIを禁止にしないと、`http://**/wp-json/wp/v2/users/1`といったアクセスに対してユーザー情報を返してしまう。ここから管理者のIDがわかってしまう場合があるので注意が必要。

``` function.php
// REST APIのアクセスを404に
function deny_rest_api_except_specific_plugins( $result, $wp_rest_server, $request ){
    // どんなリクエストがあるか覗きたい場合は、$requestの中身をログに出してみると良い（古典的デバッグ…）
    //error_log(print_r($request, true));

    $namespaces = $request->get_route();

    // redirectionプラグインの除外
    //if( strpos( $namespaces, 'redirection/' ) === 1 ){
    //   return $result;
    //}

    // REST APIの非許可処理（非許可というか、401が変えるので認証資格不足）
	return new WP_Error('REST API が無効化されています.', array( 'status' => rest_authorization_required_code() ) );

}
add_filter( 'rest_pre_dispatch', 'deny_rest_api_except_specific_plugins', 10, 3);

```
- ここを参考にしましょう
  - [WordPressのREST API周りのfilter hook / action hook のまとめと、一部のREST APIを開放する方法](https://qiita.com/TanakanoAnchan/items/f4fc11f66e9cf2d7490e)