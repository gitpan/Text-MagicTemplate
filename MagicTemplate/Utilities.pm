package Text::MagicTemplate::Utilities;
$VERSION = '0.01';
use Exporter ();
push @ISA, qw( Exporter );
@EXPORT =  qw( _block );

use strict; no strict "refs";

sub _block
{
    my ($s, $content, $ref) = @_;
    my $output = "IDENTIFIERS LIST";
    $output .= _extract( ref($s), $content );
    $output .=  ':';
    $output;
}

sub _extract
{
    my ($c, $content, $level, $output) = @_;
    $output .=  _label($c, $1, $2, $3, $level) while $content =~ m!${$c.'::_START'}(\w+)${$c.'::_END'}(?:(.*?)${$c.'::_START'}(${$c.'::_END_ID'}\1)${$c.'::_END'})?!gs ;
    $output;
}

sub _label
{
    my($c, $start_lab, $content, $end_lab, $level, $output ) = @_;
    $output .=  ":\n". "\t" x $level . $start_lab;
    $output .= _extract( $c, $content, $level+1 ) if $content;
    if    ($end_lab and $content =~ m! ${$c.'::_START'}\w+${$c.'::_END'}!) { $output .= ": \n" }
    elsif ($end_lab) { $output .= '...' }
    $output .= "\t" x $level . $end_lab if $end_lab;
    $output;
}

1;