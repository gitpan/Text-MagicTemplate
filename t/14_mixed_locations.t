use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$my_hash = {scalar_test => 'SCALAR FROM HASH', P => 'PPP'};
$mt = new Text::MagicTemplate (  'main', $my_hash);
$scalar_test = 'SCALAR';
$tmp = 'text from {P} template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
ok ($$content, 'text from PPP template SCALAR, end text.');
