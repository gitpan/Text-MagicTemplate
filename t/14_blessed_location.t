use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

$scalar = 'SCALAR';

package Local::foo;

sub new
{
	my $c = shift;
	my $s = bless { tmp=> \ 'text before {method}placeholder{/method} text after'}, $c;
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
$f = new Local::foo;
$content = $f->my_output();
ok($$content, 'text before PLACEHOLDER text after');