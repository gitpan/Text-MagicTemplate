use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


our ($mt, $content, $tmp);
$mt = new Text::MagicTemplate {-value_handlers => [qw(SCALAR REF ARRAY HASH)]};
$tmp = 'text before {my_sub}placeholder{/my_sub} text after';

sub my_sub { 'NOT USED VALUE' }

$content = $mt->output(\$tmp);
ok($$content, 'text before  text after');
