use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate;
$scalar_test = 'SCALAR';
$content = $mt->output('t/template_test_01');
ok ($$content, 'text from template SCALAR, text from included_test_01 with SCALAR, text from included_test_02 with SCALAR.');
