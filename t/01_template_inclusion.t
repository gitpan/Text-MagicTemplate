#!perl -w
use strict;
use Test::More tests => 2 ;
use Text::MagicTemplate;

our ($mt, $mt2, $mt3, $tmp2, $tmp3, $scalar_test, $content, $content2, $content3);
$mt = new Text::MagicTemplate;
$scalar_test = 'SCALAR';
$content = $mt->output('t/template_test_01');
is ($$content, "text from template SCALAR, text from included_test_01 with SCALAR, text from included_test_02 with SCALAR.");

$mt3 = new Text::MagicTemplate zone_handlers=>'INCLUDE_TEXT';
$tmp3 = 'text from template {scalar_test}, {INCLUDE_TEXT t/text_file}' ;
$content3 = $mt3->output(\$tmp3);
is ($$content3, 'text from template SCALAR, text from file');
