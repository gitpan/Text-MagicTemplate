package Text::MagicTemplate::Utilities;
$VERSION = '0.04';
use Exporter ();
push @ISA, qw( Exporter );
@EXPORT_OK =  qw( _block );

use strict; no strict "refs";

## set_identifier_output

sub _block
{
    my ($s, $content, $ref) = @_;
    my $output = "IDENTIFIERS LIST";
    $output .= _extract( ref($s), $content );
    $output .=  ': ';
    $output;
}

sub _extract
{
    my ($c, $content, $level, $output) = @_;
    my ($S, $I, $E) = $c->syntax;
    $output .=  _label($c, $1, $2, $3, $level) while $content =~ /$S (\w+) $E (?: (.*?) $S ($I \1 ) $E )?/xgs ;
    $output;
}

sub _label
{
    my($c, $start_lab, $content, $end_lab, $level, $output ) = @_;
    my ($S, $I, $E) = $c->syntax;
    $output .=  ": \n". "\t" x $level . $start_lab;
    $output .= _extract( $c, $content, $level+1 ) if $content;
    if    ($end_lab and $content =~ /$S \w+ $E/x ) { $output .= ": \n" }
    elsif ($end_lab) { $output .= '...' }
    $output .= "\t" x $level . $end_lab if $end_lab;
    $output;
}

## end set_identifier_output




1;