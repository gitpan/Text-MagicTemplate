use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

our ($mt, $ident, $content) ;
$mt = new Text::MagicTemplate
          zone_handlers => '_EVAL_' ;
$ident = 'III';
$content = $mt->output(*DATA);
ok ($$content, "text WWWWW text III\n");

__DATA__
text {_EVAL_} 'W' x 5 {/_EVAL_} text {ident}
