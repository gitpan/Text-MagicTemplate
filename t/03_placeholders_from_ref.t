use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

our ($mt, $scalar_test, $content, $tmp);

$mt = new Text::MagicTemplate {-value_handlers => 'DEFAULT_VALUE_HANDLERS'};
$scalar_test = 'SCALAR';
$tmp = 'text from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
ok ($$content, 'text from template SCALAR, end text.');
