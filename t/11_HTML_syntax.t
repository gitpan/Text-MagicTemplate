## 11

use Test;
use Text::MagicTemplate::HTML;
BEGIN {  plan tests => 1 }

$mt = new Text::MagicTemplate::HTML;

$tmp = '<p><hr>Name: <b><!--{name}-->John<!--{/name}--></b><br>Surname: <b><!--{surname}-->Smith<!--{/surname}--></b><hr></p>';

$name = 'Domizio';
$surname = 'Demichelis';

$content = $mt->output(\$tmp);

ok($$content, '<p><hr>Name: <b>Domizio</b><br>Surname: <b>Demichelis</b><hr></p>');
