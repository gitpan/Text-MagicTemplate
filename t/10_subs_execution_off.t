#!perl -w
use strict;
use Test::More tests => 1 ;
use Text::MagicTemplate;

our ($mt, $content, $tmp);
$mt = new Text::MagicTemplate {-value_handlers => [qw(SCALAR REF ARRAY HASH)]};
$tmp = 'text before {my_sub}placeholder{/my_sub} text after';

sub my_sub { 'NOT USED VALUE' }

$content = $mt->output(\$tmp);
is($$content, 'text before  text after');
