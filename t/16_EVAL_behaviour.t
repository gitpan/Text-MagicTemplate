use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate { -behaviours => [qw(DEFAULT _EVAL_)] };
$ident = 'III';
$content = $mt->output(*DATA);
ok ($$content, 'text WWWWW text III');

__DATA__
text {_EVAL_} 'W' x 5 {/_EVAL_} text {ident}