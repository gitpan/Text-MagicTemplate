use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$my_hash = {scalar_test => 'SCALAR FROM HASH'};
$mt = new Text::MagicTemplate { -lookups => $my_hash };
$scalar_test = 'SCALAR';
$tmp = 'text from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
ok ($$content, 'text from template SCALAR FROM HASH, end text.');

