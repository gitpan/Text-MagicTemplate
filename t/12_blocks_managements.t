## 11

use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$new_tmp = 'text before{my_new_block}content of the new block{/my_new_block}text after';
$new_content = Text::MagicTemplate->get_block ( \$new_tmp, 'my_new_block' );

$tmp = 'text before{my_old_block}content of the block{/my_old_block}text after';

$changed_content = Text::MagicTemplate->set_block ( \$tmp, 'my_old_block', $new_content );

ok($$changed_content, 'text before{my_new_block}content of the new block{/my_new_block}text after');
