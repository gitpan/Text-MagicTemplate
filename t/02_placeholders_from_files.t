use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


our ($mt, $scalar_test, $content);
$mt = new Text::MagicTemplate;
$scalar_test = 'SCALAR';
$content = $mt->output('t/template_test_02');
ok ($$content, 'text from template SCALAR, end text.');
