package HTML::MagicTemplate ;
$VERSION = 3.44             ;

; use 5.006
; use strict
; use base 'Text::MagicTemplate'

; BEGIN
   { *NEXT_HANDLER           = *Text::MagicTemplate::NEXT_HANDLER
   ; *LAST_HANDLER           = *Text::MagicTemplate::LAST_HANDLER
   ; *EXPORT_OK              = *Text::MagicTemplate::EXPORT_OK
   ; *DEFAULT_VALUE_HANDLERS = *Text::MagicTemplate::HTML_VALUE_HANDLERS
   ; *DEFAULT_MARKERS        = *Text::MagicTemplate::HTML_MARKERS
   }
   
; 1

__END__
      
=head1 NAME

HTML::MagicTemplate - HTML handlers for Text::MagicTemplate used in a HTML environment.

=head1 VERSION 3.44

=head1 SYNOPSIS

    $mt = new HTML::MagicTemplate ;
    
    # that means
    $mt = new Text::MagicTemplate
              markers        => 'HTML' ,
              value_handlers => 'HTML' ;
              
    # that explicitly means
    $mt = new Text::MagicTemplate
              markers        => [ qw( <!--{ / }--> ) ],
              value_handlers => [ qw( SCALAR
                                      REF
                                      CODE
                                      TableTiler
                                      ARRAY
                                      HASH
                                      FillInForm ) ] ;

=head1 DESCRIPTION

HTML::MagicTemplate is a collection of handlers for Text::MagicTemplate useful when used in a HTML environment. It adds a couple of magic HTML specific value handlers to Text::MagicTemplate default value handlers. Just create and use the MagicTemplate object as usual, to have a trasparent interface to HTML::TableTiler and HTML::FillInForm too.

Other interesting readings about how to use this collection are in:

=over

=item *

L<Text::MagicTemplate> (general documentation about the I<MagicTemplate> system)

=item *

L<Text::MagicTemplate::Zone>

=back

=head1 HTML VALUE HANDLERS

=over

=item HTML

This is the shortcut for the complete HTML collection of handlers that defines the following value handlers:

    SCALAR
    REF
    CODE
    TableTiler
    ARRAY
    HASH
    FillInForm

See L<Text::MagicTemplate/"standard value handlers"> for details about I<SCALAR> I<REF> I<CODE> I<ARRAY> and I<HASH> handlers.

=item TableTiler

=over

=item Condition

a bidimensional array value

=item Action

magic generation of HTML table. No need to create and use a HTML::TableTiler object: this handler will manage it magically.

=item Description

The bidimensional array:

    $matrix_generating_a_table = [ [1..3], 
                                   [4..6], 
                                   [7..9] ];

The template could be as simple as a simple label with the same identifier of the bidimensional array:

    <p>paragraph text</p>
    <!--{matrix_generating_a_table}-->
    <p>other paragraph</p>

so the output will be a generic table including the array data:

    <p>paragraph text</p>
    <table>
    <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
    </tr>
    <tr>
        <td>4</td>
        <td>5</td>
        <td>6</td>
    </tr>
    <tr>
        <td>7</td>
        <td>8</td>
        <td>9</td>
    </tr>
    </table>
    <p>paragraph text</p>


or the template could be a complete table I<Tile> included in a block with the same identifier of the bidimensional array, and with the optional ROW and COL TableTiler modes, passed as label attributes:

    <p>paragraph text</p>
    <!--{matrix_generating_a_table H_TILE V_TILE}-->
    <table border="1" cellspacing="2" cellpadding="2">
    <tr>
        <td><b><i>?</i></b></td>
        <td>?</td>
    </tr>
    <tr>
        <td>?</td>
        <td><b><i>?</i></b></td>
    </tr>
    </table>
    <!--{/matrix_generating_a_table}-->
    <p>other paragraph</p>

so the output will be a complete tiled table including the array data:

    <p>paragraph text</p>
    <table border="1" cellspacing="2" cellpadding="2">
    <tr>
        <td><b><i>1</i></b></td>
        <td>2</td>
        <td><b><i>3</i></b></td>
    </tr>
    <tr>
        <td>4</td>
        <td><b><i>5</i></b></td>
        <td>6</td>
    </tr>
    <tr>
        <td><b><i>7</i></b></td>
        <td>8</td>
        <td><b><i>9</i></b></td>
    </tr>
    </table>
    <p>paragraph text</p>

See L<HTML::TableTiler> for details about this module.

Note: if your template don't need this specific handler you can avoid its loading by explicitly omitting it:

    $mt = new HTML::MagicTemplate
              value_handlers => [ qw( SCALAR
                                      REF
                                      CODE
                                      ARRAY
                                      HASH
                                      FillInForm ) ] ;

B<Warning>: since this handler checks for a bidimensional ARRAY, it must be checked BEFORE the ARRAY value handler in order to work.

=back

=item FillInForm

=over

=item Condition

a CGI query object value (or by a blessed object that has a param() method)

=item Action

magic fill in of a HTML form with the parameter in the CGI object

=item Description

The CGI object in your code:

    $my_query = new CGI;

If you want to fill a form with the param in the $my_query, just transform the form into a block giving it the same identifier.

    <!--{my_query}-->
    <form action="my.cgi">
    ...
    </form>
    <!--{/my_query}-->

One useful application of this handler is when a user submits an HTML form without filling out a required field. FillInForm handler will magically redisplay the form with all the form elements (input, textarea and select tags) filled with the submitted info ($my_query), without any other statement in your code. (No need to create and use a HTML::FillInForm object: this handler will manage it magically).

You can use this handler to fill the form with default values too, To do this, just create a new query object and fill it with the default param that you want in the form:

    $query = new CGI;
    $query->param( name    => 'John', 
                   surname => 'Smith', ...);

See L<HTML::FillInForm> for details about this module.

Note: if your template don't need this specific handler you can avoid its loading by explicitly omitting it:

    $mt = new HTML::MagicTemplate
              value_handlers => [ qw( SCALAR
                                      REF
                                      CODE
                                      TableTiler
                                      ARRAY
                                      HASH ) ] ;

=back

=back

=head1 SEE ALSO

=over

=item * L<Text::MagicTemplate|Text::MagicTemplate>

=item * L<Text::MagicTemplate::Zone|Text::MagicTemplate::Zone>

=item * L<HTML::TableTiler|HTML::TableTiler>

=item * L<HTML::FillInForm|HTML::FillInForm>

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?HTML::MagicTemplate.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.
