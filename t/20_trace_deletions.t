use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

our ( $mt, $scalar_test, $empty, $content, $expected, $tmp );

$mt = new Text::MagicTemplate {-zone_handlers => 'TRACE_DELETIONS'};
$scalar_test = 'SCALAR';
$empty = '';

$tmp = 'text {empty} from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';

$expected = << '__EOS__';
text <<empty found but empty>> from template SCALAR,<<simulated_area not found>> end text.
__EOS__

$content = $mt->output(\$tmp);
ok($$content."\n", $expected);
