use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

our ($id, $mt, $tmp, $expected, $content) ;
$id = 15;
$mt = new Text::MagicTemplate
        { -zone_handlers =>
            sub
            {
              my ($z) = @_;
              if ($z->id eq '_custom_')
              {
                $z->value = $z->attributes;
              }
            }
        };

$tmp = <<'EOS';
text {_custom_ 
        key => value, value2}text{/_custom_} text {id} text
EOS

$expected = <<'EOE';
text  
        key => value, value2 text 15 text
EOE

$content = $mt->output(\$tmp);
ok ($$content, $expected);
