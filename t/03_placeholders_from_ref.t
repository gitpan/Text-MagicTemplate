## 3

use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate;
$scalar_test = 'SCALAR';
$tmp = 'text from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
ok ($$content, 'text from template SCALAR, end text.');
