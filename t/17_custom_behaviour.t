use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

$mt = new Text::MagicTemplate { -behaviours => sub{ $_[1]->id eq '_custom_' && uc $_[1]->content } };

my $t = 'text {_custom_}text{/_custom_} text {id} text';
$content = $mt->output(\ $t);
ok ($$content, 'text TEXT text  text');
