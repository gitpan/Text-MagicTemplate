package Text::MagicTemplate::Zone;
$VERSION = 2.21;
use 5.005;
use Carp qw ( croak );
use strict;

our $AUTOLOAD;

sub id;
sub attributes;
sub content;
sub value;
sub container;
sub location;
sub lookup_element { &location }

sub new
{
    my ($c, $z) = shift;
    @$z{qw(id attributes content container)} = @_;
    bless $z, $c;
}

sub _set_to_container_value
{
    my $z = shift; 
    my @k = qw(container location value);
    @$z{@k} = @{$z->{container}}{@k};
    $z;
}

sub AUTOLOAD
{
    my ($z, $v) = @_;
    (my $k = $AUTOLOAD) =~ s/.*://;
    if (defined $v) { $z->{$k} = $v; $z }
    else { $z->{$k} }
}

1;

__END__

=head1 NAME

Text::MagicTemplate::Zone - The Zone object

=head1 DESCRIPTION

Since 2.1 version, Text::MagicTemplate uses the Text::MagicTemplate::Zone objects to internally represent zones. A reference to the I<Zone object> is passed as a parameter to each behaviour subroutine and is passed to your subroutines whenever an identifier trigger their execution.

=head1 ZONE OBJECT METHODS

Unless you plan to write an extension, you will find useful just the attributes() and content() methods, that you can use to retrieve parameters from your subroutines. (see L<Text::MagicTemplate::Tutorial/"Pass parameters to a subroutine">).

If you plan to write your own extension, please, feel free to ask for more support: the documentation in this distribution is not yet complete for that purpose.

=head2 AUTOLOAD

Each method loaded by the AUTOLOAD sub, allows you to retrive or set a propery of the I<Zone object>. Used without parameter each method returns the value of the property, while used with a parameter it sets the value of the propery and returns a reference to the modified I<Zone object>. 

If you plan to change the behaviours of Text::MagicTemplate, you will find useful the I<AUTOLOAD> sub. You can automatically create methods on the fly to set and retrieve your own properties by just using them. The following example shows how you can add a custom 'my_attributes' property to the I<Zone object>

In the template zone 'my_zone':

    text {my_zone attr1 attr2 attr3} content {/my_zone} text

These are the properties right after the parsing:

    $zone->id is set to the string 'my_zone'
    $zone->attributes is set to the string ' attr1 attr2 attr3'
    $zone->content is set to the string ' content '

If you want to have your own 'my_attributes' property, structured as you want, you could do this:

    # creates a 'my_attributes' property
    # and set it to an array ref containing one word per element
    $zone->my_attributes( [ split /\s+/,  substr( $zone->attributes, 1) ] )

From now on you can retrieve the attributes your way:

    # retrieves the second attribute
    print $zone->my_attributes->[1]
    
    # would print
    attr2

The following are the methods that Text::MagicTemplate uses to do its job: if you use these methods in extensions you must know that they are autoloaded but predeclared (to make the UNIVERSAL::can happy).

=head2 id ( [value] )

The id() method allows you to access and set the B<zone identifier>.

=head2 attributes ( [value] )

The attributes() method allows you to access and set the B<attributes string>. This string contains everything between the end of the label IDENTIFIER and the END_LABEL marker.

=head2 content ( [value] )

The content() method allows you to access and set the B<zone content>


=head2 value ( [value] )

The value() method allows you to access and set the B<value> property of the I<Zone object>. This propery holds the value of the I<matching identifier> at that particular moment of the I<merger process>.

It's important to understand that the I<merger process> implies a recursive assignation to this property. That means that the $zone->value will return different values in different part of that process. For example: if you have this simple template:

    text {my_id_label} text

and this simple code where Text::MagicTemplate is looking up:

    $scalar = 'I am a simple string';
    $reference = \$scalar;
    $my_id_label = $reference;

At the beginning of the process, the $zone->value method will return a reference, then (after passing through the other behaviours) it will be dereferenced and so the $zone->value method, at that point, will return 'I am a simple string'.

B<Note>: In order to make it work, if the found value is a SCALAR or a REFERENCE it must be passed to the $zone->value 'as is'; if it is anything else, it must be passed as a reference. For example:

    found values          value of $zone->value
    ------------------------------------
    'SCALAR'              'SCALAR'
    (1..5)                [1..5]
    [1..5]                [1..5]
    (key=>'value')        {key=>'value'}
    {key=>'value'}        {key=>'value'}
    ------------------------------------

=head2 location ( [value] )

The location() method allows you to access and set the B<location> property of the I<zone object>. This property holds the package name, the blessed object or the hash or code reference from which comes the I<matching identifier> at that particular moment of the process.

Usually you don't need to set this property, but you could find it very useful, for example, to access the object methods of a lookup element from inside an extension. I<(more documentation to come)>

=head2 container ( [value] )

The container() method allows you to access and set the B<container> property. This property holds the reference to the container block (or zone) in a nested block or is undefined if the zone is not nested.

=head2 lookup_element ( [value] )

Obsolete method: use location() method instead.

=head1 SEE ALSO

=over

=item * L<Text::MagicTemplate|Text::MagicTemplate>

=item * L<Text::MagicTemplate::Tutorial|Text::MagicTemplate::Tutorial>

=item *  L<Text::MagicTemplateX|Text::MagicTemplateX>

=item * L<Text::MagicTemplateX::Core|Text::MagicTemplateX::Core>

=item * L<Text::MagicTemplateX::HTML|Text::MagicTemplateX::HTML>

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Text::MagicTemplate::Zone.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.





