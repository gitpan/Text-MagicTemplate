#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;

our ($mt, $zero_string, $tmp, $content) ;
$mt = new Text::MagicTemplate ;
$zero_string = '0';
sub sub_zero_string {'0'}
$tmp = 'text from template {zero_string} placeholder {/zero_string}{zero_string} end text.';
$content = $mt->output(\$tmp);
is ($$content, 'text from template 00 end text.');


