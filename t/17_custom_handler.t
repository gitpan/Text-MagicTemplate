#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;

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
                   return 1;
                 }
                },
                'SCALAR',
                'REF']
           };
$_custom_ = [ 1..5 ];
my $t = 'text {_custom_}n|n|n...{/_custom_} text {id} text';
$content = $mt->output(\$t);
is ($$content, 'text 1|2|3|4|5 text  text');

