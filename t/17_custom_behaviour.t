use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate { -behaviours => sub{ $_[1]->{id} eq '_custom_' && uc $_[1]->{content}} };

$content = $mt->output(*DATA);
ok ($$content, 'text TEXT text ');

__DATA__
text {_custom_}text{/_custom_} text {id}