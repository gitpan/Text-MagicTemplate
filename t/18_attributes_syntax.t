#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;

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
                return undef ;
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
is ($$content, $expected);
