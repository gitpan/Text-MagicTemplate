#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;

our ($id, $mt, $tmp, $expected, $content) ;
$id = 15;
$mt = new Text::MagicTemplate
          markers       => 'HTML',
          zone_handlers => '_EVAL_ATTRIBUTES_' ;

$tmp = 'text <!--{my_param {a=>1,b=>2}}--> text <!--{id}--> text';

sub my_param
{
  my ($z) = @_ ;
  $z->param->{a} . $z->param->{b} ;
}

$expected = 'text 12 text 15 text';

$content = $mt->output(\$tmp);
is ($$content, $expected);
