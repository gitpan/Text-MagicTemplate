use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

our ( $mt, $content, $expected, $tmp );

$mt = new Text::MagicTemplate ;

$tmp = 'A nested loop:{my_nested_loop}|Date: {date} - Operation: {operation} - Details:{details} - {quantity} {item}{/details} - {/my_nested_loop}|';

$expected = << '__EOS__';
my_nested_loop:
    date:
    operation:
    details:
        quantity:
        item:
    /details:
/my_nested_loop:

__EOS__

$mt->ID_list('    ');
$content = $mt->output(\$tmp);
ok($$content."\n", $expected);
