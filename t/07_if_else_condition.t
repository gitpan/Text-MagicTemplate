use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

$mt = new Text::MagicTemplate;
$scalar_test = 'SCALAR';
$tmp = '{OK_condition}This is the OK block, containig {scalar_test}{/OK_condition}{NO_condition}This is the NO block{/NO_condition}';
$OK++;
$OK ? $OK_condition={} : $NO_condition={};

$content = $mt->output(\$tmp);

ok($$content, 'This is the OK block, containig SCALAR');
