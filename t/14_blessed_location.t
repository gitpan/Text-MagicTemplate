#!perl -w
use strict;
use Test::More tests => 1;
use Text::MagicTemplate;


package Local::foo;

sub new
{
  my $c = shift;
  my $t = 'text before {method}placeholder{/method} text after';
  my $s = bless { tmp=> \ $t}, $c;
  $s->{mt} = new Text::MagicTemplate {-lookups=> $s };
  $s;
}

sub method
{
  my $s = shift;
  $s->method_2(shift()->content);
}

sub method_2
{
  my $s = shift;
  uc shift;
}
sub my_output
{
  my $s = shift;
  $s->{mt}->output($s->{tmp});
}

package main;

our ($scalar, $f, $content) ;
$scalar = 'SCALAR';
$f = new Local::foo;
$content = $f->my_output();
is($$content, 'text before PLACEHOLDER text after');
