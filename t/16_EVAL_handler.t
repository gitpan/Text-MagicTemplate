#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;

our ($mt, $ident, $content) ;
$mt = new Text::MagicTemplate
          zone_handlers => '_EVAL_' ;
$ident = 'III';
$content = $mt->output(\*DATA);
is ($$content, "text WWWWW text III\n");

__DATA__
text {_EVAL_} 'W' x 5 {/_EVAL_} text {ident}
