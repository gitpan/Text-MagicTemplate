## 10

use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate;
$tmp = 'text before {my_sub}placeholder{/my_sub} text after';

sub my_sub { 'NOT USED VALUE' }
Text::MagicTemplate->subs_execution(0);

$content = $mt->output(\$tmp);
ok($$content, 'text before  text after');
