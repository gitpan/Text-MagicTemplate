use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate { -behaviours => sub{ $_[1]->id eq '_custom_' && $_[1]->attributes } };

$tmp = <<'EOS';
text {_custom_ 
	key => value, value2}text{/_custom_} text {id} text
EOS

$expected = <<'EOE';
text  
	key => value, value2 text  text
EOE

$content = $mt->output(\$tmp);
ok ($$content, $expected);
