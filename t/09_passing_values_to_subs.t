use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


our ($mt, $char, $num, $content, $tmp);
$mt = new Text::MagicTemplate;
$tmp = 'text before {perl_eval}$char x ($num+1){/perl_eval} text after';

$char = 'W';
$num = 5;
sub perl_eval { eval shift()->content }

$content = $mt->output(\$tmp);
ok($$content, 'text before WWWWWW text after');


