use strict;
use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

our ($mt, $_custom_, $content) ;
$mt = new Text::MagicTemplate
          { -value_handlers => [
               sub
               {
                 my ($z) = @_;
                 if (ref $z->value eq 'ARRAY' )
                 {
                   $z->value = join '|', @{$z->value};
                   $z->value_process;
                   last HANDLER;
                 }
                },
                'SCALAR',
                'REF']
           };
$_custom_ = [ 1..5 ];
my $t = 'text {_custom_}n|n|n...{/_custom_} text {id} text';
$content = $mt->output(\$t);
ok ($$content, 'text 1|2|3|4|5 text  text');

