use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate;
$tmp = '{type_A}type A block with {a_scalar_1}{/type_A}{type_B}type B block with {a_scalar_2}{/type_B}{type_C}type C block with {a_scalar_1}{/type_C}{type_D}type D block with {a_scalar_2}{/type_D}';

$a_scalar_1 = 'THE SCALAR 1';
$a_scalar_2 = 'THE SCALAR 2';
$type       = 'type_D';
$$type      = {};

$content = $mt->output(\$tmp);

ok($$content, 'type D block with THE SCALAR 2');
