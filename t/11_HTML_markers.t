use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 2 }

$mt2 = new Text::MagicTemplate { -markers     => [qw(<!--{ / }-->)] };
$mt = new Text::MagicTemplate { -markers     => 'HTML' };

$tmp = '<p><hr>Name: <b><!--{name}-->John<!--{/name}--></b><br>Surname: <b><!--{surname}-->Smith<!--{/surname}--></b><hr></p>';

$name = 'Domizio';
$surname = 'Demichelis';

$content = $mt2->output(\$tmp);

ok($$content, '<p><hr>Name: <b>Domizio</b><br>Surname: <b>Demichelis</b><hr></p>');

$content = $mt->output(\$tmp);

ok($$content, '<p><hr>Name: <b>Domizio</b><br>Surname: <b>Demichelis</b><hr></p>');

