# WordPress 
- [タクソノミーとターム](http://learning.ccc-labo.net/2015/11/tax_term/)

## Tips
### パーマリンクを書き換えたい場合
- パーマリンクの変更は可能
- これとは別にurl_rewriteは必要になる
```
function post_type_link_filter( $post_link, $post, $leavename, $sample )
{ 
	if ( $post->post_type === 'blog' ) {
		$post_link=str_replace("?blog=","blog/",$post_link);
		$post_link .= "/";
		$post_link .= "#debug1";
	}
	return $post_link;
}
```

### DBにログインできるけど、WordPressのID/PWがわからない場合
- sql文で管理IDを登録してしまう
```
insert into wbkofp_users(user_login, user_nicename, user_pass, user_email, user_registered) 
values('hoge','hoge',MD5('hogehoge'),'yourmailaddress','2019-07-18 10:00:00');

テーブルの接頭辞が設定されている場合は、wp_を設定値に置き換えてください
insert into wp_usermeta(user_id, meta_key, meta_value) values(2, 'wp_capabilities', 'a:1:{s:13:”administrator”;s:1:”1″;}');
insert into wp_usermeta(user_id, meta_key, meta_value) values(2, 'wp_user_level', '10');

```

### 管理画面の設定を間違えたとき
- WordPressのwp-config.phpで設定をする
```
define('WP_SITEURL','http://localhost/');
```

### tinyMCEのスタイルを追加したいとき
```
function initialize_tinymce_styles($init_array)
{
    $style_formats = array('title'=>'カスタム', 'items'=>array(
                        array(
                            'title' => 'リンク（外部サイト）',
                            'inline' => 'a',
                            'classes' => 'link external',
                            'attributes' => array(
                                'href' => 'https://'
                            )
                        ),
                        array(
                            'title' => 'ブロック(a)',
                            'block' => 'div',
                            'classes' => 'block type-a'
                        ),
                        array(
                            'title' => 'カスタムデータ属性',
                            'inline' => 'p',
                            'attributes' => array(
                                'data-color'=>'red'
                            )
                        )
                    )
        );
    $init_array['style_formats']=json_encode($style_formats);
    $init_array['style_formats_merge']=true;
    
    return $init_array;
}

add_filter('tiny_mce_before_init', 'initialize_tinymce_styles', 10);
```
- オリジナルのスタイルは、```wp-includes/js/tinymce/themes/inlite/theme.js```で定義されている

## セキュリティ対策
### プラグイン
- Wordfence
  - https://ja.wordpress.org/plugins/wordfence/
  - 機能
    - MFA
      - MFAをバイパスさせるIPアドレスを指定できます
- SiteGuard WP Plugin
  - https://ja.wordpress.org/plugins/siteguard/
- All In One WP Security & Firewall
  - https://ja.wordpress.org/plugins/all-in-one-wp-security-and-firewall/
