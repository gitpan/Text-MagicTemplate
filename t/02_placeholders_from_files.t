#!perl -w
use strict;
use Test::More tests => 1 ;
use Text::MagicTemplate;

our ($mt, $scalar_test, $content);
$mt = new Text::MagicTemplate;
$scalar_test = 'SCALAR';
$content = $mt->output('t/template_test_02');
is ($$content, 'text from template SCALAR, end text.');
