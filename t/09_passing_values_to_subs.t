#!perl -w
use strict;
use Test::More tests => 1 ;
use Text::MagicTemplate;

our ($mt, $char, $num, $content, $tmp);
$mt = new Text::MagicTemplate;
$tmp = 'text before {perl_eval}$char x ($num+1){/perl_eval} text after';

$char = 'W';
$num = 5;
sub perl_eval { eval shift()->content }

$content = $mt->output(\$tmp);
is($$content, 'text before WWWWWW text after');


