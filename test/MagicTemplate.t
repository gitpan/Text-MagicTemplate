use test::Harness qw( $verbose );
$verbose=1;
use Test;
BEGIN { plan tests => 10 }

use Text::MagicTemplate;

$scalar_test = 'SCALAR';
$mt = new Text::MagicTemplate;


## 1
print ++$testid, ": Testing nested templates inclusion (from files)...\n";

$content = $mt->output('test/template_test_01');
ok ($$content, 'text from template SCALAR, text from included_test_01 with SCALAR, text from included_test_02 with SCALAR.');


## 2
print ++$testid, ": Testing placeholders and simulated areas (from files)...\n";

$content = $mt->output('test/template_test_02');
ok ($$content, 'text from template SCALAR, end text.');


## 3
print ++$testid, ": Testing placeholders and simulated areas (from reference)...\n";

$tmp = 'text from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
ok ($$content, 'text from template SCALAR, end text.');


## 4
print ++$testid, ": Testing private lookups...\n";

$my_hash = {scalar_test => 'SCALAR FROM HASH'};
$mt = new Text::MagicTemplate $my_hash;

$content = $mt->output(\$tmp);
ok ($$content, 'text from template SCALAR FROM HASH, end text.');


$mt = new Text::MagicTemplate;


## 5
print ++$testid, ": Testing simple loops...\n";

$tmp = 'A loop:{my_loop}|Date: {date} - Operation: {operation}{/my_loop}|';

$my_loop = [
             { date => '8-2-02', operation => 'purchase' },
             { date => '9-3-02', operation => 'payment' }
           ] ;

$content = $mt->output(\$tmp);
ok ($$content, 'A loop:|Date: 8-2-02 - Operation: purchase|Date: 9-3-02 - Operation: payment|');


## 6
print ++$testid, ": Testing nested loops...\n";

$tmp = 'A nested loop:{my_nested_loop}|Date: {date} - Operation: {operation} - Details:{details} - {quantity} {item}{/details} - {/my_nested_loop}|';

$my_nested_loop = [
                     {
                        date      => '8-2-02',
                        operation => 'purchase',
                        details   => [
                                        {quantity => 5, item => 'balls'},
                                        {quantity => 3, item => 'cubes'},
                                        {quantity => 6, item => 'cones'}
                                     ]
                     },
                     {
                        date      => '9-3-02',
                        operation => 'payment',
                        details   => [
                                        {quantity => 2, item => 'cones'},
                                        {quantity => 4, item => 'cubes'}
                                     ]
                      }
                  ] ;

$content = $mt->output(\$tmp);
ok($$content, 'A nested loop:|Date: 8-2-02 - Operation: purchase - Details: - 5 balls - 3 cubes - 6 cones - |Date: 9-3-02 - Operation: payment - Details: - 2 cones - 4 cubes - |');


## 7
print ++$testid, ": Testing if-else conditions...\n";

$tmp = '{OK_condition}This is the OK block, containig {scalar_test}{/OK_condition}{NO_condition}This is the NO block{/NO_condition}';
$OK++;
$OK ? $OK_condition={} : $NO_condition={};

$content = $mt->output(\$tmp);

ok($$content, 'This is the OK block, containig SCALAR');


## 8
print ++$testid, ": Testing switch conditions...\n";

$tmp = '{type_A}type A block with {a_scalar_1}{/type_A}{type_B}type B block with {a_scalar_2}{/type_B}{type_C}type C block with {a_scalar_1}{/type_C}{type_D}type D block with {a_scalar_2}{/type_D}';

$a_scalar_1 = 'THE SCALAR 1';
$a_scalar_2 = 'THE SCALAR 2';
$type       = 'type_D';
$$type      = {};

$content = $mt->output(\$tmp);

ok($$content, 'type D block with THE SCALAR 2');


## 9
print ++$testid, ": Testing Text::MagicTemplate::HTML syntax...\n";

use Text::MagicTemplate::HTML;

$mt = new Text::MagicTemplate::HTML;

$tmp = '<p><hr>Name: <b><!--{name}-->John<!--{/name}--></b><br>Surname: <b><!--{surname}-->Smith<!--{/surname}--></b><hr></p>';

$name = 'Domizio';
$surname = 'Demichelis';

$content = $mt->output(\$tmp);

ok($$content, '<p><hr>Name: <b>Domizio</b><br>Surname: <b>Demichelis</b><hr></p>');


## 10
print ++$testid, ": Testing blocks management...\n";

$new_tmp = 'text before{my_new_block}content of the new block{/my_new_block}text after';
$new_content = Text::MagicTemplate->get_block ( \$new_tmp, 'my_new_block' );

$tmp = 'text before{my_old_block}content of the block{/my_old_block}text after';

$changed_content = Text::MagicTemplate->set_block ( \$tmp, 'my_old_block', $new_content );

ok($$changed_content, 'text before{my_new_block}content of the new block{/my_new_block}text after');
