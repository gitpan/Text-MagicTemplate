#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;

our ($mt, $scalar_test, $content, $tmp);

$mt = new Text::MagicTemplate {-value_handlers => 'DEFAULT_VALUE_HANDLERS'};
$scalar_test = 'SCALAR';
$tmp = 'text from template {scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';
$content = $mt->output(\$tmp);
is ($$content, 'text from template SCALAR, end text.');



