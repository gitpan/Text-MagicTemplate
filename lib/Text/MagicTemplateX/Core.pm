package Text::MagicTemplateX::Core;
$VERSION = 2.1;
__END__

=head1 NAME

Text::MagicTemplateX::Core - Core extensions for Text::MagicTemplate.

=head1 SYNOPSIS

    $mt = new Text::MagicTemplate;
    # that means
    $mt = new Text::MagicTemplate { -markers    => 'DEFAULT',
                                    -behaviours => 'DEFAULT' };
    # that explicitly means
    $mt = new Text::MagicTemplate { -markers    => [qw({ / })],
                                    -behaviours => [qw(SCALAR REF CODE ARRAY HASH)] };
    # with _EVAL_ behaviour
    $mt = new Text::MagicTemplate { -behaviours => [qw(DEFAULT _EVAL_)] };
    # with HTML comment-like markers
    $mt = new Text::MagicTemplate { -markers    => 'HTML' };


=head1 DESCRIPTION

Text::MagicTemplateX::Core is the core collection of behaviour extensions for Text::MagicTemplate. It includes all the 'DEFAULT' markers and behaviours extensions, plus the '_EVAL_' behaviour extension, all distributed with Text::MagicTemplate.

In order to fully understand this documentation, you should have already read:

=over

=item *

L<Text::MagicTemplate> (general documentation about the I<MagicTemplate> system)

=item *

L<Text::MagicTemplate::Tutorial|Text::MagicTemplate::Tutorial>

=item *

L<Text::MagicTemplateXl|Text::MagicTemplateX>

=back

=head1 CORE MARKERS

=over

=item DEFAULT

The default markers:

    START MARKER:  {
    END_MARKER_ID: /
    END_MARKER:    }

Example of block:

    {identifier} content of the block {/identifier}

=item HTML

HTML-comment-like markers. If your output is a HTML text - or just because you prefer that particular look - you can use it instead of using the default markers.

    START MARKER:  <!--{
    END_MARKER_ID: /
    END_MARKER:    }-->

Example of block:

    <!--{identifier}--> content of the block <!--{/identifier}-->

Usage:

    $mt = new Text::MagicTemplate { markers => 'HTML' }

The main advantages to use it are:

=over

=item *

You can add labels and blocks and the template will still be a valid HTML file.

=item *

You can edit the HTML template with a WYSIWYG editor, keeping a consistent preview of the final output

=item *

The normal HTML comments will be preserved in the final output, while the labels will be wiped out.

=back

If you want to use the HTML behaviours extension too, you should install Text::MagicTemplateX::HTML. See L<Text::MagicTemplateX::HTML> for details.

=back

See also L<Redefine Markers|Text::MagicTemplate::Tutorial/"Redefine Markers">

=head1 CORE BEHAVIOURS

=over

=item DEFAULT

This is the shortcut for the default collection of behaviour extensions that defines the following behaviours:

    SCALAR REF CODE ARRAY HASH

All the default values are based on a condition that check the found value.

B<Examples of default behaviours>:

    The same template: '{block}|before-{label}-after|{/block}'

    ... with these values...               ...produce these outputs
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >
    $block = undef;
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  NEW CONTENT
    $block = 'NEW CONTENT';
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  |before-THE VALUE-after|
    $block = {};
    ------------------------------------------------------------------------
    $label = undef;                  >  |before--after|
    $block = {};
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  |before-NEW VALUE-after|
    %block = (label=>'NEW VALUE');
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  |before-NEW VALUE-after|
    $block = {label=>'NEW VALUE'};
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  NEW CONTENT|before-THE VALUE-after|
    @block = ('NEW CONTENT',            |before-NEW VALUE-after|
              {},
              {label=>'NEW VALUE'});
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  NEW CONTENT|before-THE VALUE-after|
    $block = ['NEW CONTENT',            |before-NEW VALUE-after|
              {},
              {label=>'NEW VALUE'}];
    ------------------------------------------------------------------------
    sub label { scalar localtime }   >  |before-Tue Sep 10 14:52:24 2002-
    $block = {};                        after|
    ------------------------------------------------------------------------
    $label = 'THE VALUE';            >  |BEFORE-{LABEL}-AFTER|
    sub block { uc shift }
    ------------------------------------------------------------------------

Different combinations of I<values> and I<zones> can easily produce complex ouputs. See the L<Text::MagicTemplate::Tutorial/"HOW TO...">.

=item SCALAR

=over

=item Condition

a I<SCALAR> value

=item Action

replacement of the I<zone> with the value

=back

=item REF

=over

=item Condition

a I<REFERENCE> value (SCALAR or REF)

=item Action

dereferencing of the value and C<apply_behaviour> method with the dereferenced value

=back

=item CODE

=over

=item Condition

a I<CODE> value

=item Action

code execution and C<apply_behaviour> method with the returned value. The subroutine will receive the I<zone object> as a parameter.

=item Description

If you want to avoid the execution of subs, triggered by some identifier, just explicitly omit this behaviour:

    $mt = new Text::MagicTemplate { -behaviours => [qw(SCALAR REF ARRAY HASH)] };

See L<Avoid unwanted executions|Text::MagicTemplate::Tutorial/"Avoid unwanted executions"> for details. See also L<Pass parameters to a subroutine|Text::MagicTemplate::Tutorial/"Pass parameters to a subroutine">

=back

=item ARRAY

=over

=item Condition

an I<ARRAY> value

=item Action

C<apply_behaviour> method with each item of the array, and replacement of the zone with the joined results.

=item Description

This behaviour generates a loop, merging each value in the array with the I<zone content> and replacing the I<zone> with the sequence of the outputs. See L<Build a loop|Text::MagicTemplate::Tutorial/"Build a loop"> and L<Build a nested loop|Text::MagicTemplate::Tutorial/"Build nested a loop"> for details.

=back

=item HASH

=over

=item Condition

a I<HASH> value

=item Action

parse method with the I<zone content> using the hash as temporary lookup.

=item Description

A B<HASH> value type will set that HASH as a B<temporary lookup> for the I<zone>. Text::MagicTemplate first uses that hash to look up the identifiers contained in the block; then, if unsuccessful, it will search into the other elements of the C<-lookups> constructor array. This behaviour is usually used in conjunction with the ARRAY behaviour to generate loops. See L<Build a loop|Text::MagicTemplate::Tutorial/"Build a loop"> and L<Build a nested loop|Text::MagicTemplate::Tutorial/"Build nested a loop"> for details.

=back

=item _EVAL_

=over

=item Condition

I<zone identifier> equal to '_EVAL_'

=item Action

perl eval function with the I<zone content> and C<apply_behaviour> method with the returned value

=item Description

For obvious reasons you should use this behaviour ONLY if you are the programmer AND the designer. In order to use it, you have to explicitly include this behaviour, because the 'DEFAULT' behaviour collection doesn't include it.

    $mt = new Text::MagicTemplate { -behaviours => ['DEFAULT', '_EVAL_'] };

B<WARNING>: Since the result of the eval() will be passed to the C<apply_behaviour> method, you must include this behaviour as the last element in the C<-behaviours> constructor array, or your code will go in an infinite loop.

=back

=back

=head1 SEE ALSO

L<Text::MagicTemplate|Text::MagicTemplate>, L<Text::MagicTemplate::Tutorial|Text::MagicTemplate::Tutorial>, L<Text::MagicTemplateX|Text::MagicTemplateX>, L<Text::MagicTemplateX::HTML|Text::MagicTemplateX::HTML>.

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Text::MagicTemplateX::Core.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.