package Text::MagicTemplate::Zone ;
our $VERSION = 3.04               ;
use 5.005                         ;
use strict                        ;
our $AUTOLOAD                     ;

sub new { bless $_[1], $_[0] }

sub mt
{
  my ($az) = my ($z) = @_ ;
  until ( $az->level == -1 ){ $az = $az->container }
  $az->{mt}
}

sub merge
{
  my ($z) = @_ ;
  my ($S, $I, $E, $A, $ID) = @{$z->mt->{-markers}};
  my ($nz, $pos);
  ZONE: while ( $z->{content} =~ / ( (?: (?! $S$ID$A$E) . )* )
                                   $S($ID)($A)$E
                                   (?:
                                     ( (?: (?! $S\2$A$E) (?! $S$I\2$E) . )* )
                                     $S$I\2$E
                                   )? /xgs )
        {
          $pos = pos $z->{content} ;
          $z->text_process($1)     ;
          $nz = ref($z)->new ( { id         => $2            ,
                                 attributes => $3            ,
                                 content    => $4            ,
                                 container  => $z            ,
                                 level      => $z->level + 1 } ) ;
          $nz->zone_process                               ;
          $nz->lookup         if (not defined $nz->value) ;
          $nz->value_process  if     (defined $nz->value) ;
        }
  $z->text_process(substr $z->{content}, $pos) ;
}
                                        
sub lookup
{
  my ($z) = @_ ;
  for ( my $az=$z ; $az->container ; $az=$az->container )
      { next unless my $zl = $az->zone_lookup ;
        return if defined ($z->value = $z->_lookup($zl)) }
  for ( @{$z->mt->{-lookups}} )
      { return if defined ($z->value = $z->_lookup($_))  }
}

sub _lookup
{
  my ($z, $l) = @_ ;
  $z->location = $l ;
  if (ref $l eq 'HASH') { $l->{$z->id} }
  else
  {
    local *S = '*'.(ref $l||$l).'::'.$z->id ;
    if    (defined ${*S}    ) { ${*S}     }
    elsif (defined *S{CODE} ) { *S{CODE}  }
    elsif (defined *S{ARRAY}) { *S{ARRAY} }
    elsif (defined *S{HASH} ) { *S{HASH}  }
    else                      { undef     }
  }
}

sub AUTOLOAD :lvalue
{
  (my $n = $AUTOLOAD) =~ s/.*://;
  no strict 'refs';
  if (my ($w) = $n=~/^(\w+)_process$/) # process
  { *$AUTOLOAD = sub { my $ch = $_[0]->mt->{"-${w}_handlers"} or return;
                       HANDLER: for (@$ch) {$_->(@_)} } }
  else # property
  { *$AUTOLOAD = sub:lvalue{ $_[0]->{$n}=$_[1] if defined $_[1];$_[0]->{$n} } }
  goto &$AUTOLOAD ;
  my $dummy ; # to make :lvalue work in AUTOLOAD
}

sub DESTROY { $_[0]->post_process }

1;

__END__

=head1 NAME

Text::MagicTemplate::Zone - The Zone object

=head1 VERSION 3.04

=head1 DESCRIPTION

Since 2.1 version, Text::MagicTemplate uses the Text::MagicTemplate::Zone objects to internally represent zones. A reference to the I<Zone object> is passed as a parameter to each handler and is passed to your subroutines whenever an identifier trigger their execution.

Unless you plan to write an extension, you will find useful just the L<"attributes"> and L<"content"> properties, that you can use to retrieve parameters from your subroutines. (see L<Text::MagicTemplate/"Pass parameters to a subroutine">).

=head1 ZONE OBJECT METHODS

B<Note>: If you plan to write your own extension, please, feel free to ask for more support: the documentation in this distribution is not yet complete for that purpose.

With Text::MagicTemplate the output generation is so flexible and customizable, because it can be changed DURING THE PROCESS by several factors coming both from the code I<(for example: the type of value found by the C<lookup()>)>, or from the template I<(for example: the literal id of a zone)>, or whatever combination of factors you prefer.

It's important to understand that - for this reason - the output generation is done recursively by several processes (all customizable by the user) that are executed zone-by-zone, step-by-step, deciding the next step by evaluating the handlers conditions.

This is a sloppy code to better understand the whole process:

    ZONE: while ($zone = find_and_create_the_zone)
          {
            foreach $process (@all_the_process)
            {
              HANDLER: foreach $handler (@$process)
                       {
                         $handler->($zone)
                       }
            }
          }

As you can see, the HANDLER loop is nested inside the ZONE loop, not vice versa. This avoids unneeded recursions in zones that could be wiped out by some handler, thus allowing a faster execution. (for example when the C<value> property of a zone is undefined the zone is deleted).

These are the processes that are executed for any single zone:

  merge
    parse
    new zone creation
      zone process
      lookup
      value process
      text & output processes
    post process

As general rule, a C<*_process> is a method that executes in sequence the handlers contained in C<*_handlers> constructor array. In details, these process executes the handlers contained in these constructor arrays:

    zone_process()    zone_handlers
    value_process()   value_handlers
    text_process()    text_handlers
    output_process()  output_handlers
    post_process()    post_handlers

=head2 merge()

This method starts (and manage) the output generation: it first parses the zone content, using the C<markers> constructor array to find new zones, it creates each new zone object and apply the appropriate process on the new zones.

B<Note>: You can change the way of parsing by customizing the I<-marker> constructor array. You can change the resulting output by customizing the other constructor arrays.

=head2 zone_process()

The scope of this method is organizing the Zone object.

As other process methods, this process simply calls in turn all the handlers in the C<zone_handlers> constructor array (change that to change this process). This method is executed inside 2 nested loops: the outer ZONE labeled loop and the inner HANDLER labeled loop, so you can control the iteration by using statements as: C<'next ZONE'> to end the merge method for the current zone, or C<'last HANDLER'> to end the C<zone_process()> itself and pass to the next processes.

B<Note>: Since it is called first, and just after the creation of each new zone object, this is a very powerful method that allows you to manage the output generation before any other process. With this method you can even bypass or change the way of calling the other processes.

=head2 lookup()

The C<lookup()> method try to match a zone identifier with a code identifier. If it find a match it sets the I<zone value> property to the value of the found identifier. You can customize the lookup by changing the items in the C<lookups> constructor array.

B<Note>: it is called by default IF the I<zone value> property is undefined.

=head2 value_process()

The scope of this method is finding out a scalar value from the code to pass to the C<output_process()>.

As other process methods, the C<value_process()> simply calls in turn all the handlers in the C<value_handlers> constructor array (change that to change this process). This method is executed inside 2 nested loops: the outer ZONE labeled loop and the inner HANDLER labeled loop, so you can control the iteration by using statements as: C<'next ZONE'> to end the merge method for the current zone, or C<'last HANDLER'> to end the C<value_process()> itself and pass to the next processes.

B<Note>: it is called by default IF the zone value property is defined.

=head2 text_process()

The scope of this method is processing only the text that comes from the template and that goes into the output (in other words the template content between zones).

As other process methods, the C<text_process()> simply calls in turn all the handlers in the C<text_handlers> constructor array (change that to change this process). This method is executed inside 2 nested loops: the outer ZONE labeled loop and the inner HANDLER labeled loop, so you can control the iteration by using statements as: C<'next ZONE'> to end the merge method for the current zone, or C<'last HANDLER'> to end the C<text_process()> itself and pass to the next processes.

B<Note>: If the C<text_handlers> constructor array is undefined (as it is by default) the text will be processed by the C<output_process()> instead. Use this method only if you need to process the text coming from the template in some special way, different by the text coming from the code.

=head2 output_process()

The scope of this method is processing the text that comes from the code. It is usually used to process the text coming from the template as well (if the C<text_process()> is not used).

As other process methods, the C<output_process()> simply calls in turn all the handlers in the C<output_handlers> constructor array (change that to change this process). This method is executed inside 2 nested loops: the outer ZONE labeled loop and the inner HANDLER labeled loop, so you can control the iteration by using statements as: C<'next ZONE'> to end the merge method for the current zone, or C<'last HANDLER'> to end the C<output_process()> itself and pass to the next processes.

=head2 post_process()

This method is called from the C<DESTROY> method of each I<zone object>. It is not used by default. Use it to clean up or log processes as you need.

As other process methods, the C<post_process()> simply calls in turn all the handlers in the C<post_handlers> constructor array (change that to change this process).

=head2 AUTOLOAD()

The Zone package has a convenient C<AUTOLOAD> method that allows you to retrive or set a propery of the I<zone object>.

All the properties are :lvalue methods, that means that you can use the property as a left value :

    # to set classical way (it works anyway)
    $z->value('whatever')   ;
    
    # to set new way (lvalue stype)
    $z->value  = 'whatever' ;
    
    $the_value = $z->value  ; # to retrive

If you plan to customize the behaviours of Text::MagicTemplate, you will find useful the C<AUTOLOAD> method. You can automatically set and retrieve your own properties by just using them. The following example shows how you can add a custom 'my_attributes' property to the I<zone object>

B<Note>: Since the AUTOLOAD method is used to address all the C<*_process> methods as well, you should avoid property names that ends with '_process'.

In the template zone 'my_zone':

    text {my_zone attr1 attr2 attr3} content {/my_zone} text

These are the properties right after the parsing:

    $zone->id is set to the string 'my_zone'
    $zone->attributes is set to the string ' attr1 attr2 attr3'
    $zone->content is set to the string ' content '

If you want to have your own 'my_attributes' property, structured as you want, you could do this:

    # creates a 'my_attributes' property
    # and set it to an array ref containing one word per element
    $zone->my_attributes = [ split /\s+/,  substr( $zone->attributes, 1) ]

From now on you can retrieve the attributes your way:

    # retrieves the second attribute
    print $zone->my_attributes->[1]
    
    # would print
    attr2

=head1 PROPERTIES

The following are the properties that Text::MagicTemplate uses to do its job: they all are left value autoloaded properties (see L<"AUTOLOAD()">).

=head2 mt

The C<mt> property allows you to access the B<Text::MagicTemplate object>.

B<Note>: this is a read only property.

=head2 id

The C<id> property allows you to access and set the B<zone identifier>.

=head2 attributes

The C<attributes> property allows you to access and set the B<attributes string>. This string contains everything between the end of the label IDENTIFIER and the END_LABEL marker.

=head2 param

This property is added by the C<_EVAL_ATTRIBUTES_> zone handler (if you explicitly use it), and - in that case - holds the B<evalued attributes structure>. You can use this property to hold your favorite structure: just create it with a simple zone handler as C<_EVAL_ATTRIBUTES_>.

=head2 content

The C<content> property allows you to access and set the B<zone content>

=head2 container

This property holds the reference to the B<container zone>.

B<Note>: It is undefined only if the zone is the I<main template zone>.

=head2 level

This property holds the number of nesting level of the zone. -1 for the I<main template zone>, 0 for the zones at the template level, 1 for the zone nested in a zone at the template level and so on. In other words ($z->level < 0) for the I<main template zone> and ($z->level > 0) if the zone is nested.

=head2 location

This property holds the package name, the blessed object or the hash reference from which comes the I<matching identifier> at that particular moment of the process.

Usually you don't need to set this property, but you could find it very useful, for example, to access the object methods of a lookup element from inside an extension. I<(more documentation to come)>

=head2 zone_lookup

This property holds the B<zone lookup> (usually set by the C<HASH> I<value handler>).

B<Note>: this is the same concept of the C<lookups> constructor array: it's just the private lookups array where the C<lookup_process()> looks up first.

=head2 value

This propery holds the value of the I<matching identifier> at that particular moment of the I<output generation>.

It's important to understand that the C<value_process()> implies a recursive assignation to this property (not to mention that other processes could set the property as well). That means that the C<value> property will return different values in different part of that process. For example: if you have this simple template:

    text {my_id_label} text

and this simple code where Text::MagicTemplate is looking up:

    $scalar = 'I am a simple string';
    $reference = \$scalar;
    $my_id_label = $reference;

At the beginning of the process, the C<value> property will return a reference, then (after passing through the other value handlers) it will be dereferenced and so the C<value> property, at that point, will return 'I am a simple string'.

B<Note>: In order to make it work, if the found value is a SCALAR or a REFERENCE it must be set the C<value> property 'as is'; if it is anything else, it must be set as a reference. For example:

    found values          value of $zone->value
    ------------------------------------
    'SCALAR'              'SCALAR'
    (1..5)                [1..5]
    [1..5]                [1..5]
    (key=>'value')        {key=>'value'}
    {key=>'value'}        {key=>'value'}
    ------------------------------------


=head2 output

This property holds the B<output string> coming from the code.

=head1 SEE ALSO

=over

=item * L<Text::MagicTemplate|Text::MagicTemplate>

=item * L<HTML::MagicTemplate|HTML::MagicTemplate>

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
