package Text::MagicTemplate::Utilities;
$VERSION = 2.2;
use Exporter ();
push @ISA, qw( Exporter );
@EXPORT_OK =  qw( parse );

use strict;

## set_identifier_output

sub parse
{
    my ($s, $content, $ref) = @_;
    my $output = "IDENTIFIERS LIST";
    $output .= _extract( $s, $$content );
    $output .=  ': ';
    \$output;
}

sub _extract
{
    my ($s, $content, $level, $output) = @_;
    my ($S, $I, $E, $A, $ID) = @{$s->{-markers}};
    $output .=  _label($s, $1, $2, $3, $level) while $content =~ / $S($ID)$A$E  (?: ( (?: (?! $S\1$A$E) (?! $S$I\1$E) . )* )  $S($I\1)$E )?/xgs ;
    $output;
}

sub _label
{
    my($s, $start_lab, $content, $end_lab, $level, $output ) = @_;
    my ($S, $I, $E, $A, $ID) = @{$s->{-markers}};
    $output .=  ": \n". "\t" x $level . $start_lab;
    $output .= _extract( $s, $content, $level+1 ) if $content;
    if    ($end_lab and $content =~ /$S $ID $A $E/x ) { $output .= ": \n" }
    elsif ($end_lab) { $output .= '...' }
    $output .= "\t" x $level . $end_lab if $end_lab;
    $output;
}

## end set_identifier_output


1;

__END__

=head1 NAME

Text::MagicTemplate::Utilities - method redefinitions for Text::MagicTemplate

=head1 DESCRIPTION

Text::MagicTemplate::Utilities is a module that implements some method redefinition internally used by Text::MagicTemplate and its subclasses. It is not intended to be used directly.

Please, refer to the documentation of L<Text::MagicTemplate>.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.


