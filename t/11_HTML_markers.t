use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 2 }

our ($mt1, $mt2, $name, $surname, $content, $tmp);
$mt1 = new Text::MagicTemplate  markers     => 'HTML' ;
$mt2 = new Text::MagicTemplate { -markers     => [qw(<!--{ / }-->)] };

$tmp = '<p><hr>Name: <b><!--{name}-->John<!--{/name}--></b><br>Surname: <b><!--{surname}-->Smith<!--{/surname}--></b><hr></p>';

$name = 'Domizio';
$surname = 'Demichelis';

$content = $mt2->output(\$tmp);

ok($$content, '<p><hr>Name: <b>Domizio</b><br>Surname: <b>Demichelis</b><hr></p>');

$content = $mt1->output(\$tmp);

ok($$content, '<p><hr>Name: <b>Domizio</b><br>Surname: <b>Demichelis</b><hr></p>');

