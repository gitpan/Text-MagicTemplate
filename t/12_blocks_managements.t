#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;
BEGIN {  plan  }

our ($mt, $content, $new_content, $changed_content, $tmp, $new_tmp, );
$mt = new Text::MagicTemplate;
$new_tmp = 'text before{my_new_block}content of the new block{/my_new_block}text after';
$new_content = $mt->get_block ( \$new_tmp, 'my_new_block' );

$tmp = 'text before{my_old_block}content of the block{/my_old_block}text after';

$changed_content = $mt->set_block ( \$tmp, 'my_old_block', $new_content );

is($$changed_content, 'text before{my_new_block}content of the new block{/my_new_block}text after');
