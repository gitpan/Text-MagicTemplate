use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate {-behaviours => [qw(SCALAR REF ARRAY HASH)]};
$tmp = 'text before {my_sub}placeholder{/my_sub} text after';

sub my_sub { 'NOT USED VALUE' }

$content = $mt->output(\$tmp);
ok($$content, 'text before  text after');
