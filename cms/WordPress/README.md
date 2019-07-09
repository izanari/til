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