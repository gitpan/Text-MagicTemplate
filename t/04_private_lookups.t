#!perl -w
use strict ;
use Test::More tests => 1;
use Text::MagicTemplate;

our ($mt, $scalar_test, $content, $tmp, $my_hash);

$my_hash = {scalar_test => 'SCALAR FROM HASH'};
$mt = new Text::MagicTemplate { -lookups => $my_hash };
$scalar_test = 'SCALAR';
$tmp = 'text from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
is ($$content, 'text from template SCALAR FROM HASH, end text.');

