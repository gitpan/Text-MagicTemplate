package Text::MagicTemplateX;
$VERSION = 2.21;
__END__

=head1 NAME

Text::MagicTemplateX - namespace used by the extensions of Text::MagicTemplate

=head1 DESCRIPTION

Text::MagicTemplateX:: is the namespace used by the extensions of Text::MagicTemplate. This documentation cover the extension system in general: each extension collection is supposed to be documented with its own POD file.

Extensions are simple files that Text::MagicTemplate will include with the do() statement when it construct a new object. See L<Text::MagicTemplate/-markers> and L<Text::MagicTemplate/-behaviours> for details.

=head2 Naming Conventions and Namespaces

The Text::MagicTemplate package and all packages below it (Text::MagicTemplate::*) are reserved for Text::MagicTemplate. Collection of extensions use the B<Text::MagicTemplateX::> namespace. An B<extension collection> is a related collection of one or more B<markers extensions> and/or B<behaviours extensions>.

Core extensions names are all capitals (see L<Text::MagicTemplate::Core>), so, in order to avoid confusion, other extension names should just begin with a capital letter (same rules as modules name convenction).

Behaviours extensions that involve the use of reserved identifiers (as the '_EVAL_' core behaviour extension name), should be started and ended with the underscore character '_', to avoid confusion with user identifiers.

If you are planning to write your own extension, please, let me know the namespace you intend to use.

=head1 MARKERS EXTENSIONS

I<Markers extensions> are used just as a shortcut, to avoid to remember complicated markers. I<Markers extensions> are files that simply return a reference to a 3 element array of the I<markers> you want to use to define I<templates zones>.

I<Markers extension files> are stored in the Text::MagicTemplateX dir, and have '.m' suffix. For example, the 'Text/MagicTemplateX/HTML.m' file has this content:

    [qw(<!--{ / }-->)]

When you type:

    $mt = new Text::MagicTemplate { -markers => 'HTML' }

'HTML' is interpreted as the I<markers extension name> and the C<-markers> constructor array will be set to the result of the execution of the F<Text/MagicTemplateX/HTML.m> file. This has the identical effect of:

    $mt = new Text::MagicTemplate 
              { -markers => do 'Text/MagicTemplateX/HTML.m' }
    
    # that means
    $mt = new Text::MagicTemplate { -markers => [qw( <!--{ / }--> ) ] };

=head1 BEHAVIOURS EXTENSIONS

I<Behaviours extensions> are files stored in the Text::MagicTemplateX dir, and have '.b' suffix.

I<Behaviours extensions> may return a reference to an array of names of other I<behaviours extensions>, or a reference to a subroutine:

=over

=item reference to array

When you type:

    $mt = new Text::MagicTemplate;
    
    # this explicitly means
    $mt = new Text::MagicTemplate { -behaviours => 'DEFAULT' };

'DEFAULT' is interpreted as a I<behaviour extension name> and the F<Text/MagicTemplateX/DEFALT.b> file is executed with the do() statement. This has the same effect of:

    $mt = new Text::MagicTemplate 
              { -behaviours => do 'Text/MagicTemplateX/DEFALT.b' };

Since the 'Text/MagicTemplateX/DEFAULT.b' file returns a reference to an array of I<behaviours extension names>:

    [ qw( SCALAR REF CODE ARRAY HASH ) ]

the previous code line explicitly means:

    $mt = new Text::MagicTemplate { -behaviours => [ qw( SCALAR
                                                         REF
                                                         CODE
                                                         ARRAY
                                                         HASH   ) ] };

Since the C<-behaviour> constructor array is used to construct a switch-like condition, in the end, it must contain only references to callback subroutines, so the previous code will be interpreted this way:

    $mt = new Text::MagicTemplate 
              { -behaviours => [  do 'Text/MagicTemplateX/SCALAR.b',
                                  do 'Text/MagicTemplateX/REF.b',
                                  do 'Text/MagicTemplateX/CODE.b',
                                  do 'Text/MagicTemplateX/ARRAY.b',
                                  do 'Text/MagicTemplateX/HASH.b'   ] };

where each do() statement will return a reference to the sub contained in the I<behaviours extension file>.

=item reference to subroutine

The final goal of a I<behaviours extension> is to supply a callback subroutine capable of generate a conditional output. (see L<Text::MagicTemplate/-behaviours> for details).

The callback subroutine will receive the following parameters:

=over

=item * $_[0]

the B<magic template object> reference: used to execute object methods. (see L<PRIVATE METHODS>)

=item * $_[1]

the B<zone object> reference, used to access the zone methods. (see L<Text::MagicTemplate::Zone/"ZONE OBJECT METHODS">)

=back

The callback subroutine may use or ignore the received parameter, in order to setup the condition and generate the output.

See these examples:

=over

=item SCALAR (Core behaviour)

This code returns the found value ($z->value), IF it is not a reference (SCALAR), ELSE it returns undef.

    sub
    {
        my ($s, $z) = @_;
        if (!ref $z->value) { $z->value }
        else { undef }
    }

=item HASH (Core behaviour)

This code pass the zone object ($z) to the MagicTemplate object ($s) C<parse> method, IF the found value is a reference to HASH, ELSE it returns undef.

    sub
    {
        my ($s, $z) = @_;
        if (ref $z->value eq 'HASH') { ${$s->parse($z)} }
        else { undef }
    }

=item _EVAL_ (Core behaviour)

This code set the value of the zone object to the evaluated content and passes the zone object to the MagicTemplate object ($s) C<apply_behaviour> method, IF the I<zone identifier> is equal to '_EVAL_', ELSE it returns undef.

    sub
    {
        my ($s, $z) = @_;
        if ($z->id eq '_EVAL_')
        {
            $s->apply_behaviour($z->value(eval $z->content))
        }
        else { undef }
    }

=item TableTiler (Text::MagicTemplateX::HTML behaviour)

When included with the do() statement, this code loads L<HTML::TableTiler|HTML::TableTiler> module, then IF the I<value> is a reference to an array, it pass the I<value>, the I<zone content> (if it exists), and the I<zone attributes> to the HTML::TableTiler::tile_table funcion. The C<eval{...}> statement traps the possible errors and returns undef if it not succeed, or the tiled table if it succeed, ELSE it returns undef.

    use HTML::TableTiler ;
    
    sub
    {
        my ($s, $z) = @_;
        if (ref $z->value eq 'ARRAY')
        {
            eval
            {
                local $SIG{__DIE__};
                HTML::TableTiler::tile_table( $z->value, 
                                              $z->content && \$z->{content},
                                              $z->{attributes} )
            }
        }
        else { undef }
    }


=back

Check other behaviours files in the Text/MagicTemplateX dir in order to better understand the possibility of the extension system. See also the behaviours distributed with the Text::MagicTemplateX::HTML collection.

=head1 PRIVATE METHODS

This is a brief documentation of the privates methods you may need to use in order to write an extension. If you are planning to do so, please, feel free to ask me for additional support.

=head2 parse ( zone )

This method parses a template_string in order to find I<template zones>, calling the C<lookup> method each time a zone is found, thus generating the output relative to that template string. It returns the reference to the output.

=head2 lookup ( zone )

This method scans the C<-lookups> constructor array to found a value in the code, then it pass it to the C<apply_behaviour> method

=head2 apply_behaviour ( zone )

This method is pratically a switch conditions that calls in turn each behaviour fallback subroutine, present in the C<-behaviour> constructor array, searching for a defined value to return to the caller.

=head1 SEE ALSO

=over

=item * L<Text::MagicTemplate|Text::MagicTemplate>

=item * L<Text::MagicTemplate::Zone|Text::MagicTemplate::Zone>

=item * L<Text::MagicTemplate::Tutorial|Text::MagicTemplate::Tutorial>

=item * L<Text::MagicTemplateX::Core|Text::MagicTemplateX::Core>

=item * L<Text::MagicTemplateX::HTML|Text::MagicTemplateX::HTML>

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Text::MagicTemplateX.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.






