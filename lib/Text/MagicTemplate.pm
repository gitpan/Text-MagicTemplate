package Text::MagicTemplate;
$VERSION = 2.2;
use 5.005;
use Carp qw ( croak );
use strict;
use Text::MagicTemplate::Zone;

sub default_markers    { [ 'DEFAULT' ] }
sub default_behaviours { [ 'DEFAULT' ] }

sub new
{
    my ($c, $s) = @_;
    for (values %$s){ $_ = [$_] unless ref eq 'ARRAY' }
    $s->{-markers}    ||= $c->default_markers;
    $s->{-behaviours} ||= $c->default_behaviours;
    $s->{-lookups}    ||= [ (caller)[0] ];
    $s->{-markers}      = do "Text/MagicTemplateX/$s->{-markers}[0].m"
                          or croak 'Error opening markers extension: '
                                   .$s->{-markers}[0] . ": $^E"
                          unless @{$s->{-markers}}==3 ;
    $s->{-markers}      = [ map qr/$_/s, @{$s->{-markers}},
                                  '(?:(?!'.$s->{-markers}->[2].').)*', '\w+' ];
    $s->{-behaviours}   = [ $c->load_behaviours($s->{-behaviours}) ];
    bless $s, $c;
}

sub load_behaviours
{
    my ($c, $b) = @_;
    map { if    (ref eq 'CODE'){ $_ }
          elsif (!ref) { my $ref = do "Text/MagicTemplateX/$_.b"
                         or croak "Error opening behaviour extension: $_: $^E";
                         if    (ref $ref eq 'ARRAY') {$c->load_behaviours($ref)}
                         elsif (ref $ref eq 'CODE')  { $ref } } } @$b
}

sub get_block
{
    my ($s, $t, $id) = @_;
    $t = &read_temp unless ref $t eq 'SCALAR';
    $$t or croak 'The template content is empty'; 
    my ($S, $I, $E, $A) = @{$s->{-markers}};
    eval { $$t =~ s/ $S ('|") (.*?) \1 $E /${$s->get_block($2)}/xgse }; #include
           croak 'Modification of a read-only value attempted' if $@;
    if (defined $id) { ($$t) = $$t =~ /( $S$id$A$E 
                                       (?: (?! $S$id$A$E) (?! $S$I$id$E) . )*
                                       $S$I$id$E )/xs }
    $t;
}

sub read_temp
{
    local $_ = $_[1] || croak 'No template parameter passed';
    if (ref eq 'GLOB' || ref \$_ eq 'GLOB'){ $_ = do{local $/; <$_>} }
    elsif ($_ && !ref) { open _ or croak "Error opening template $_: $^E";
                         $_ = do{local $/; <_>}; close _ }
    else  { croak 'Wrong template parameter type: '. (ref||'UNDEF') }
    \$_;
}

sub set_block
{
    my ($s, $t, $id, $new) = @_;
    my ($S, $I, $E, $A) = @{$s->{-markers}};
    $t = $s->get_block($t);
    $$t =~ s/ $S$id$A$E 
              (?: (?! $S$id$A$E) (?! $S$I$id$E) . )* 
              $S$I$id$E
            /$$new||$new/xgse ;
    $t;
}

sub output { $_[0]->parse(&get_block) }

sub print
{
    my $s = shift;
    $s = $s->new( {-lookups => [ (caller)[0] ]} ) unless ref $s;
    print ${$s->output(@_)}
}

sub parse
{
    my ($s, $z) = @_;
    my $t = ref $z eq 'Text::MagicTemplate::Zone' ? \$z->content : $z;
    my ($S, $I, $E, $A, $ID) = @{$s->{-markers}};
    $$t =~ s/ $S($ID)($A)$E  
              (?: ( (?: (?! $S\1$A$E) (?! $S$I\1$E) . )* )
              $S$I\1$E  )?
            /$s->lookup( Text::MagicTemplate::Zone->new 
                ($1, $2, $3, ref $z eq 'Text::MagicTemplate::Zone' && $z))/xgse;
    $t;
}

sub lookup
{
    my ($s, $z) = @_;
    foreach ( $z->container && $z->container->value || @{$s->{-lookups}} )
    {
        $z->location($_);
        if    (ref eq 'HASH') { $z->value( $_->{$z->id} ) }
        elsif (ref eq 'CODE') { $z->value( $_->($s, $z) ) }
        else                  { $z->value( $s->_symbol_lookup($z, $_) ) }
        my $value = $s->apply_behaviour($z);
        return $value if defined $value ;
    }
    $s->lookup( $z->_set_to_container_value ) if $z->container;
}

sub _symbol_lookup
{
    my ($s, $z, $l) = @_;
    local *S = '*'.(ref $l||$l).'::'.$z->id;
    if    (defined ${*S}    ) { ${*S}     }
    elsif (defined *S{CODE} ) { *S{CODE}  }
    elsif (defined *S{ARRAY}) { *S{ARRAY} }
    elsif (defined *S{HASH} ) { *S{HASH}  }
    else                      { undef     }
}

sub apply_behaviour
{
    foreach ( @{$_[0]->{-behaviours}} )
    {
        my $value = $_->(@_); # <-- to make Mark happy ;-)
        return $value if defined $value
    }
    undef
}

sub ID_list
{
    require Text::MagicTemplate::Utilities;
    import Text::MagicTemplate::Utilities qw(parse) # redefine subs
}
sub set_ID_output { &ID_list }

1;

__END__

=head1 NAME

Text::MagicTemplate - magic merger of runtime values with templates

=head1 WARNING!

Starting with version 2.0, a few critical changes (that could break your old code based on versions < 2.0) have been introduced. 

Another very little change has been introduced in version 2.1 too. This could affect your code based on 2.05 ONLY if you was using your own custom behaviours OR lookups in subroutines.

You can maintain your old code whether adapting it to the new style (very easy job to do), or using an older compatible version (I hate this way :-(). See F<Warning> and F<History> files in this distribution for details.

=head1 SYNOPSIS

=over

=item the template

The template file F<'my_template_file'>... I<(this example uses plain text for clarity, but MagicTemplate works with any type of text file)>

    A scalar variable: {a_scalar}.
    A reference to a scalar variable: {a_ref_to_scalar}.
    A subroutine: {a_sub}
    A reference to subroutine: {a_ref_to_sub}
    A reference to reference: {a_ref_to_ref}
    A hash: {a_hash}this block contains a {a_scalar} and a {a_sub}{/a_hash}
    
    A loop:{an_array_of_hashes}
    Iteration #{ID}: {guy} is a {job}{/an_array_of_hashes}
    
    An included file:
    {'my_included_file'}
    
    ... and another template file F<'my_included_file'> 
    that will be included...
    
    this is the included file 'my_included_file'
    that contains a label: {a_scalar}

=item the code

... some variables and subroutines already defined somewhere in your code...

    $a_scalar           = 'THIS IS A SCALAR VALUE';
    $a_ref_to_scalar    = \$a_scalar;
    @an_array_of_hashes = ( { ID => 1, guy => 'JOHN SMITH',  job => 'PROGRAMMER' },
                            { ID => 2, guy => 'TED BLACK',   job => 'WEBMASTER' },
                            { ID => 3, guy => 'DAVID BYRNE', job => 'MUSICIAN' }  );
    %a_hash             = ( a_scalar => 'NEW SCALAR VALUE'
                            a_sub    => sub { 'NEW SUB RESULT' } );
    
    sub a_sub         { 'THIS SUB RETURNS A SCALAR' }
    sub a_ref_to_sub  { \&a_sub }
    sub a_ref_to_ref  { $a_ref_to_scalar }

Just add these 2 magic lines...

    use Text::MagicTemplate;
    Text::MagicTemplate->print( 'my_template_file' );

=item the output

I<(in this example Lower case are from templates and Upper case are from code)>:

    A scalar variable: THIS IS A SCALAR VALUE.
    A reference to a scalar variable: THIS IS A SCALAR VALUE.
    A subroutine: THIS SUB RETURNS A SCALAR
    A reference to subroutine: THIS SUB RETURNS A SCALAR
    A reference to reference: THIS IS A SCALAR VALUE
    A hash: this block contains a NEW SCALAR VALUE and a NEW SUB RESULT
    
    A loop:
    Iteration #1: JOHN SMITH is a PROGRAMMER
    Iteration #2: TED BLACK is a WEBMASTER
    Iteration #3: DAVID BYRNE is a MUSICIAN
    
    An included file:
    this is the included file 'my_included_file'
    that contains a label: THIS IS A SCALAR VALUE.

=back

=head1 DESCRIPTION

=head2 Quick overview

Text::MagicTemplate is a module that allows you to generate the output of your programs in a very easy way. The following is a very simple example only aimed to better understand how it works: obviously, the usefulness of Text::MagicTemplate comes up when the output become more complex.

Imagine you need an output that looks like this template file:

    City: {city}
    Date and Time: {date_and_time}

where {city} and {date_and_time} are just placeholder that you want to be replaced in the output by some real runtime values. Somewhere in your code you have defined a scalar and a sub to return the 'city' and the 'date_and_time' values:

    $city = 'NEW YORK';
    sub date_and_time { localtime }

you have just to add these 2 magic lines to the code:

    use Text::MagicTemplate;
    Text::MagicTemplate ->print( 'my_template_file' );

to generate this output:

    City: NEW YORK
    Date and Time: Sat Nov 16 21:03:31 2002

With the same 2 magic lines of code, Text::MagicTemplate can automatically look up values from I<scalars>, I<arrays>, I<hashes>, I<references> and I<objects> from your code and produce very complex outputs. The default settings are usually smart enough to do the right job for you, however if you need complete control over the output generation, you can fine tune them by controlling them explicitly. See new() method for details.

=head2 Concept

Text::MagicTemplate is a "magic" interface between programming and design. It makes "magically" available all the runtime values - stored in your variables or returned by your subroutines - inside a static template file. B<In simple cases there is no need to assign values to the object>. Template outputs are linked to runtime values by their I<identifiers>, which are added to the template in the form of simple I<labels> or I<blocks> of content.

    a label: {identifier}
    a block: {identifier} content of the block {/identifier}

From the designer point of view, this makes things very simple. The designer has just to decide B<what> value and B<where> to put it. Nothing else is required, no complicated new syntax to learn!

On the other side, the programmer has just to define variables and subroutines as usual and their values will appear in the right place within the output. The automatic interface allows the programmer to focus just on the code, saving him the hassle of interfacing code with output, and even complicated output - with complex switch branching and nested loops - can be easily organized by minding just a few simple concepts. See L<"How it works"> for details.

=head2 Policy

The main principle of Text::MagicTemplate is: B<keep the designing separated from the coding>, giving all the power to the programmer and letting designer do only design. In other words: while the code includes ALL the active and dynamic directions to generate the output, the template is a mere passive and static file, containing just placeholder (zones) that the code will replace with real data.

This philosophy keep both jobs very tidy and simple to do, avoiding confusion and enforcing clearness, specially when programmer and designer are 2 different people. But another aspect of the philosophy of Text::MagicTemplate is flexibility, something that gives you the possibility to easily B<bypass the rules>.

Even if I don't encourage breaking the main principle (keep the designing separated from the coding), sometimes you might find useful to put inside a template some degree of perl code, or may be you want just to interact DIRECTLY with the content of the template. See L<Using subroutines to rewrite links|Text::MagicTemplate::Tutorial/"Using subroutines to rewrite links"> and L<Embed perl into a template|Text::MagicTemplate::Tutorial/"Embed perl into a template"> for details.

Other important principles of Text::MagicTemplate are scalability and expandibility. The whole extension system is built on these principles, giving you the possibility of control the behaviour of this module by omitting, changing the orders and/or adding your own behaviours, without the need of subclassing the module. See L<new() method|"new ( [constructor_arrays] )"> and eventually L<Text::MagicTemplateX>.

=head2 Features

Since syntax and coding related to this module are very simple and mostly automatic, you should careful read this section to have the right idea about its features and power. This is a list - with no particular order - of the most useful features and advantages:

=over

=item * Simple, flexible and powerful to use

In simple cases, you will have just to use L<new()|"new ( [constructor_parameter] )"> and L<print(template)|"print ( template [, identifier] )"> methods, without having to pass any other value to the object: it will do the right job for you. However you can fine tune the behaviour as you need.

=item * Extremely simple and configurable template syntax

The template syntax is so simple and code-independent that even the less skilled webmaster will manage it without bothering you :-). By default Text::MagicTemplate recognizes labels in the form of simple identifiers surrounded by braces (I<{my_identifier}>), but you can easily use different markers (see L<Redefine Markers|Text::MagicTemplate::Tutorial/"Redefine Markers">).

=item * Automatic or manual lookup of values

By default, Text::MagicTemplate compares any I<label identifier> defined in your template with any I<variable> or I<subroutine identifier> defined in the caller namespace. However, you can explicitly define the lookup otherwise, by passing a list of package namespaces, hash references, blessed objects and/or code references to the C<-lookups> constructor array.

=item * Unlimited nested included templates

Sometimes it can be useful to split a template into differents files. No nesting limit when including files into files. (see L<Include a file|Text::MagicTemplate::Tutorial/"Include a file">)

=item * Branching

You can easily create simple or complex if-elsif-else conditions to print just the blocks linked with the true conditions (see L<Setup an if-else condition|Text::MagicTemplate::Tutorial/"Setup an if-else condition"> and L<Setup a switch condition|Text::MagicTemplate::Tutorial/"Setup a switch condition">)

=item * Unlimited nested loops

When you need complex outputs you can build any immaginable nested loop, even mixed with control switches and included templates (see L<Build a loop|Text::MagicTemplate::Tutorial/"Build a loop"> and L<Build a nested loop|Text::MagicTemplate::Tutorial/"Build a nested loop">)

=item * Scalable and expandable extensions system

You can load only the behaviour you need, to gain speed, or you can add as many behaviour you will use, to gain features. You can even write your own behaviour extension in just 2 or 3 lines of code, expanding its capability for your own purpose. (see L<new()|"new ( [constructor_arrays] )"> method and eventually L<Text::MagicTemplateX>)

=item * Perl embedding

Even if I don't encourage this approach, however you can very easily embed any quantity of perl code into any template. (see L<Embed perl into a template|Text::MagicTemplate::Tutorial/"Embed perl into a template">)

=item * Block management

When you need complex management of templates files, you have a couple of static methods to extract, mix and set blocks inside any template. (see L<get_block()|"get_block ( template [, identifier] )"> and L<set_block()|"set_block ( template, identifier, new_content )"> methods)

=item * Placeholders and simulated areas

Placeholders and simulated areas can help in designing the template for a more consistent preview of the final output. (see L<Setup placeholders|Text::MagicTemplate::Tutorial/"Setup placeholders"> and L<Setup simulated areas|Text::MagicTemplate::Tutorial/"Setup simulated areas">)

=item * Labels and block list

When you have to deal with a webmaster, you can easily print a pretty formatted output of all the identifiers present in a template. Just add your description of each label and block and save hours of explanations ;-)  (see L<ID_list()|"ID_list ()"> static method)

=item * Simple to maintain

Change your code and Text::MagicTemplate will change its behaviour accordingly. In most cases you will not have to reconfigure, either the object, or the template.

=item * Small footprint

F<MagicTemplate.pm> doesn't use any other module and its core code is just about 100 lines I<(easier to write that this documentation :-) )>

=back

See also L<Text::MagicTemplate::Tutorial> for more details.

=head2 How it works

I<(Please, read the L<"SYNTAX GLOSSARY"> section for definitions.)>

=head3 short explanation

=over

=item 1

The object parse the template and search for any I<labeled zone>

=item 2

When a I<zone> is found, the object looks into your code and search for any variable or sub with the same identifier (name)

=item 3

When a match is found the object replace the label or the block with the value returned by the variable or sub found into your code (dereferencing and/or executing code as needed)

=back

=head3 medium explanation

The MagicTemplate ouput generation has 3 basic aspects internally handled by the module: B<template parsing>, B<code lookup> and B<behaviour>:

=over

=item 1 The object parse the template to find I<zones>

Each I<zone> defines the area that will be replaced with the result of the I<behaviour>, and defines 3 parameter used by the object: an I<identifier> and optional I<attributes> and I<content>.

According to the default syntax, this is a minimum zone with no attributes and no content I<(a label)>:

    {my_identifier}

This is a more complex and complete I<zone> with attributes and content (a I<block> delimited by a I<label> and an I<end label>):

    {my_identifier attribute1 attribute2 attributeX} content of block {/identifier}

where  C<'my_identifier'> is the IDENTIFIER, C<' attribute1 attribute2 attributeX'> are the optional ATTRIBUTES and  C<' content of block '> is the optional CONTENT.

See the C<-markers> constructor array for details.

=item 2 When a I<zone identifier> is found, the object looks into your code to find a match

To do this, it uses the elements contained in the C<-lookups> constructor array, that can be I<package namespaces>, I<blessed objects>, I<references to hash> or  I<references to subroutines>.

If the element is a I<package namespace> or a I<blessed objects>, it compares the I<zone identifier> with each I<variable or subroutine identifier> defined in the package; if the element is a I<hash reference>, it compares the I<zone identifier> with each I<key> defined in the hash, if the element is a I<code reference> it just expects the result of the lookup from the subroutine. If no C<-lookups> constructor array is passed to the new() method, the package namespace of the caller will be used by default.

See the C<-lookups> constructor array for details.

=item 3 When a match is found, the object choose and execute the behaviour

To do this, it uses the elements contained in the C<-behaviours> constructor array. Each element of this array is a I<reference to sub> or a I<behaviour extension name> (resulting in one or more reference to sub), that conditionally returns a result. The object check in turn each element of the array, for a defined value: when the first defined value is returned by a behaviour, the object replaces the I<template zone> with the returned value and start again the process with the next parsed zone.

If no C<-behaviours> constructor array is passed, then the default behaviours will be applied: SCALAR, REF, CODE, ARRAY and HASH. These behaviours are triggered by the found I<value type>:

=over

=item *

A B<SCALAR> value type will B<replace> the I<zone> with the scalar value.

=item *

A B<REFERENCE> value will be B<dereferenced>, and the value returned will be checked again to apply an appropriate behaviour

=item *

A B<CODE> value type will be B<executed>, and the value returned will be checked again to apply an appropriate behaviour

=item *

An B<ARRAY> value type will B<generate a loop>, merging each value in the array with the I<zone content> and replacing the I<zone> with the sequence of the outputs.

=item *

A B<HASH> value type will set that HASH as a B<temporary lookup> for the I<zone>. Text::MagicTemplate first uses that hash to look up the identifiers contained in the block; then, if unsuccessful, it will search into the other elements of the C<-lookups> constructor array.

=item *

Finally, if no previous behaviour returned any value, the I<zone> will be B<deleted>.

=back

See the C<-behaviours> constructor array, and L<Text::MagicTemplateX::Core> for details.

=back

=head3 long explanation

This document plus:

=item * L<Text::MagicTemplate::Tutorial>

=item * L<Text::MagicTemplate::Zone>

=item * L<Text::MagicTemplateX::Core>

=item * L<Text::MagicTemplateX>.

=head1 INSTALLATION

=over

=item Prerequisites

    Perl version >= 5.005

=item CPAN

If you want to install Text::MagicTemplate plus all related extensions (L<Text::MagicTemplateX::HTML|Text::MagicTemplateX::HTML> and prerequisites), all in one easy step:

    perl -MCPAN -e 'install Bundle::Text::MagicTemplate'

=item Standard installation

From the directory where this file is located, type:

    perl Makefile.PL
    make
    make test
    make install

B<Note>: this installs just the main distribution and does not install L<Text::MagicTemplateX::HTML|Text::MagicTemplateX::HTML> and its prerequisites.

=item Manual installation

If your OS does not have any 'make' support, just copy the content of the /lib dir into perl installation site dir, maintaining the same hierarchy.

=back

=head2 Structure

This is the general three of the Text::MagicTemplate system (just in case you get lost :-) )

    Bundle
        Text
             MagicTemplate  a bundle to install everything in one step
    Text
        MagicTemplate       the main module (start from here)
            Zone            defines the zone object
            Tutorial        the tutorial (very useful)
            Utilities       used internally (don't worry about it)
        MagicTemplateX      extensions namespace (documentation for power users)
            Core            core extensions collection
            HTML            HTML extensions collection
    HTML
        MagicTemplate       wrapper for Text::MagicTemplate in HTML environment

=head1 METHODS

=head2 new ( [constructor_arrays] )

The new() method accepts one optional reference to a hash that can contain the following optionals constructor arrays: B<-markers, -lookups, -behaviours>.

If you don't pass any parameter to the constructor method, the constructor defaults are usually smart enough to do the right job for you, but if you need complete control over the output generation, you can fine tune them by controlling them explicitly.

If you use the defaults, and you have just to print a template, you can use the print() method as a static method, completely avoiding the new() method:

    use Text::MagicTemplate;
    Text::MagicTemplate->print('template');

B<Note>: all the constructor arrays should be array references, but if you have to pass just one element, you can pass it as a plain element as well:

    $mt = new Text::MagicTemplate { -lookups => [\%my_hash],
                                    -markers => ['HTML'] };
    
    # same thing less noisy
    $mt = new Text::MagicTemplate { -lookups => \%my_hash,
                                    -markers => 'HTML' };

=over

=item -markers

Use this constructor array to define the 3 I<label markers> - START_MARKER, END_MARKER_ID, END_MARKER - you want to use in your template. The C<-markers> constructor array can contain the name of 1 markers extension, or a reference to an array containing the 3 explicit markers.

If you want to use the default markers, just call the new() method without any C<-markers> constructor array:

    # default markers
    $mt = new Text::MagicTemplate;
    
    # same but explicit extension name
    $mt = new Text::MagicTemplate { -markers => 'DEFAULT' };
    
    # same but 3 explicit default markers
    $mt = new Text::MagicTemplate { -markers => [ '{', '/', '}' ] };
    
    # HTML markers extension name
    $mt = new Text::MagicTemplate { -markers => 'HTML' };
    
    # same but 3 explicit HTML markers
    $mt = new Text::MagicTemplate { -markers => [ qw( <!-- / --> ) ] };
    
    # custom explicit markers
    $mt = new Text::MagicTemplate { -markers => [ qw( __ END_ __ ) ] };

Since each element of the -markers array is parsed as a regular expression as: C<qr/element/>, you can extend the markers beyond a static string marker. This markers:

    # 3 weird explicit markers
    $mt = new Text::MagicTemplate { -markers => [ '\d{3}', '\W', '\d{3}' ] };

will match this blocks labeled 'identifier':

    235identifier690 content of block 563-identifier054
    123identifier321 content of block 000#identifier865

See L<Text::MagicTemplate::Tutorial/"Redefine Markers"> to have more details.

=item -lookups

Use this constructor array to explicitly define where to look up the values in your code. This array can contain B<package names>, B<blessed objects>, B<hash references> and B<code references>. If no -lookups construction array is passed, the package namespace of the caller will be used by default.

With B<packages names> the lookup is done with all the IDENTIFIERS (variables and subroutines) defined in the package namespace.

With B<blessed objects> the lookup is done with all the IDENTIFIERS (variables and methods) defined in the class namespace. B<Note>: Use this type of location when you want to call an object method from a template: the method will receive the blessed object as the first parameter and it will work as expected.

With B<hash references> the lookup is done with the KEYS existing in the hash.

With B<code references> the whole lookup process is passed to the referenced sub that should do a lookup on its own and return the found value. The code called will receive 2 paramenters:  the Text::MagicTemplate object and the Zone object. B<Note>: Use this type of lookup to take-over the whole lookup process and only if you know exactly what you are doing. 

If you want to make available all the identifiers of your current package, just call the constructor without any C<-lookups> parameter:

    # default lookup in the caller package
    $mt = new Text::MagicTemplate ;
    
    # same thing but explicit
    $mt = new Text::MagicTemplate { -lookups => __PACKAGE__ };

If you want to keep unavailable some variable or subroutine from the template, you can pass just the reference of some hash containing just the identifiers used in the template. This is the best method to use the module IF you allow untrustworthy people to edit the template AND if you have any potentially dangerous subroutine in your code. (see L<Allow untrustworthy people to edit the template|Text::MagicTemplate::Tutorial/"Allow untrustworthy people to edit the template">).

    # lookup in %my_hash only
    $mt = new Text::MagicTemplate { -lookups => \%my_hash } ;

You can also define an arbitrary list of packages, references to hashes and blessed object as the lookup: the precedence of the lookup will be inherited from the order of the items passed, and the first found mach will return the value.

B<Note>: If you have multiple symbols in your code that maches the label id in your template, don't expect any warning: to be fast, Text::MagicTemplate does not check your errors and consider OK the first symbol it founds.

    # lookup in several locations
    $mt = new Text::MagicTemplate { -lookups => [\%my_hash, 'main', \%my_other_hash] } ;

In this example, the lookup will be done in C<%my_hash> first - if unsuccessful - it will be done in the C<'main' package> and - if unsuccessful - it will be done in C<%my_other_hash>.

If you use Text::MagicTemplate inside another module, you can pass the blessed object as the location:

    use Text::MagicTemplate;
    package Local::foo;
    sub new
    {
        my $s = bless {data=>'THE OBJECT DATA'}, shift;
        $s->{mt} = new Text::MagicTemplate {-lookups => $s};
        $s;
    }
    
    sub method_triggered_by_lookup
    {
        my $s = shift; # correct object passed
        ...
        $s->{data};
    }

so that if some I<zone identifier> will trigger 'I<method_triggered_by_lookup>', it will receive the blessed object as the first parameter and it will work as expected.

=item -behaviours

Use this constructor array to explicitly define or modify the behaviour of the object. This constructor array can contain B<code references> and/or B<behaviour extension names> (resulting in one or more code references: see L<Text::MagicTemplateX> for details).
The code referenced in the array, must be a I<conditional behaviour> (or just a 'I<behaviour>' for short), that simply means: code that will be executed only if a condition is true. This is the typical structure of a I<behaviour>:

    $behaviour = sub { if (condition_that_apply) { do_something }
                       else                      { undef }        }

The object will use the I<behaviours> in this array to construct a switch case condition similar to this:

    foreach $beh ( $behaviour1, $behaviour2, $behaviour3 .... )
    {
        my $result = &$beh
        return $result if defined $result
    }

If you don't pass any C<-behaviours> constructor array, the default behaviours will be used:

    $mt = new Text::MagicTemplate;
    
    # means
    $mt = new Text::MagicTemplate { -behaviours => 'DEFAULT' };
    # that expicitly means
    
    $mt = new Text::MagicTemplate { -behaviours => [ qw( SCALAR
                                                         REF
                                                         CODE
                                                         ARRAY
                                                         HASH  ) ] };

Where 'DEFAULT', 'SCALAR', 'REF', 'CODE', 'ARRAY', 'HASH' are I<behaviour extension names> that the object will use to load the named extension file.

You can add, omit or change the order of the element in the array, fine tuning the behaviour of the object.

    $my_behaviour = sub{ if(my_condition){ do_my_behaviour }
                         else            { undef } }
    
    $mt = new Text::MagicTemplate { -behaviours => [ 'DEFAULT', 
                                                      $my_behaviour ] };
    
    # that explicitly means
    $mt = new Text::MagicTemplate { -behaviours => [ 'SCALAR',
                                                     'REF', 
                                                     'CODE', 
                                                     'ARRAY', 
                                                     'HASH', 
                                                      $my_behaviour] };
    
    # or you can add, omit and change the order of the behaviours
    $mt = new Text::MagicTemplate { -behaviours => [ 'SCALAR',
                                                     'REF',
                                                      $my_behaviour,
                                                     'ARRAY',
                                                     'HASH'] };

See  L<Text::MagicTemplateX::Core> for details and examples.

=back

=head2 output ( template [, identifier] )

This method merges the runtime values with the template and returns a reference to the output. It accepts one I<template> parameter that can be a reference to a SCALAR content, a path to a template file or a filehandle. If any I<identifier> is passed, it returns a reference to the output of just that block.

    # template is a path
    $output = $mt->output( '/temp/template_file.html' ) ;
    
    # template is a reference
    $output = $mt->output( \$tpl_content ) ;
    
    #template is a filehandler
    $output = $mt->output( *FILEHANDLER );
    
    # this limits the output to just 'my_block_identifier'
    $my_block_output = $mt->output( \$tpl_content, 'my_block_identifier');

B<Note>: If you pass a reference to a SCALAR content, the template content itself will be merged in place for efficiency. This means that after this line:

    $output = $mt->output( \$tpl_content ) ;

$tpl_content will be modified and $output will be just a reference to it. (see L<Cache in memory the template content|Text::MagicTemplate::Tutorial/"Cache in memory the template content">)

=head2 print ( template [, identifier] )

This method merges the runtime values with the template and prints the output. It accepts one I<template> parameter that can be a reference to a SCALAR content (see the note under L<output()|" output ( template [, identifier] )"> method), a path to a template file or a filehandle. If any I<identifier> is passed, it prints the output of just that block.

    # template is a path
    $mt->print( '/temp/template_file.html' );
    
    # template is a reference
    $mt->print( \$tpl_content ) ;
    
    #template is a filehandler
    $mt->print( *FILEHANDLER );
    
    # this limits the output to just 'my_block_identifier'
    $mt->print( \$tpl_content, 'my_block_identifier' );

You can use the print() method as a static method as well. The static method accepts the same parameters. It constructs a default object internally and prints the merged output.

    Text::MagicTemplate->print( 'template' );
    
    # that explicitly means
    $mt = Text::MagicTemplate->new;
    $mt->print( 'template' );

=head2 get_block ( template [, identifier] )

This method returns a reference to the template content or to a block inside the template, without merging values. It accepts one I<template> parameter that can be a reference to a SCALAR content (see the note under L<output()|" output ( template [, identifier] )"> method), a path to a template file or a filehandle. If any I<identifier> is passed, it returns just that block.

    # this returns a ref to the whole template content
    $tpl_content = $mt->get_block ( '/temp/template_file.html' );
    
    # this return a ref to the 'my_block_identifier' block
    $tpl_block = $mt->get_block ( '/temp/template_file.html', 'my_block_identifier' );
    
    # same thing passing a reference
    $tpl_block = $mt->get_block ( $tpl_content, 'my_block_identifier' );

=head2 set_block ( template, identifier, new_content )

This method sets the content of the block (or blocks) I<identifier> inside a I<template> - without merging values - and returns a reference to the changed template. It accepts one I<template> parameter that can be a reference to a SCALAR content (see the note under L<output()|" output ( template [, identifier] )"> method), a path to a template file or a filehandle. I<New_content> can be a reference to the content or the content itself.

    # this return a ref to the 'my_block' block
    $new_content = $mt->get_block ( '/temp/template_file_2.html', 'my_block' );
    
    # this returns a ref to the changed template content,
    $changed_content = $mt->set_block ( '/temp/template_file.html', 'my_old_block', $new_content );

=head1 STATIC METHODS

=head2 ID_list ()

Calling this method (before the L<output()|"output ( template [, identifier] )"> or L<print()|"print ( template [, identifier] )"> methods) will redefine the behaviour of the module, so your program will print a pretty formatted list of only the identifiers present in the template, thus the programmer can pass a description of each label and block within a template to a designer:

    Text::MagicTemplate->ID_list;

See also L<Prepare the identifiers description list|Text::MagicTemplate::Tutorial/"Prepare the identifiers description list">.

=head2 set_ID_output ()

Deprecated method. Use ID_list() instead.

=head1 PRIVATE METHODS

Text::MagicTemplate has a few private methods that it uses internally but documented in L<Text::MagicTemplateX/"PRIVATE METHODS"> useful just if you plan to write an extension.

=head1 SYNTAX GLOSSARY

=over

=item attributes string

The I<attributes string> contains every character between the end of the label I<identifier> and the I<end label> marker. This is optionally used to pass special parameters to the behaviour.

=item behaviour

The behaviour generated by Text::MagicTemplate (i.e. with the 'DEFAULT' behaviours, an UNDEF value type triggers the deletion of the zone; an ARRAY value type generates a loop).

=item block

A I<block> is a I<template zone> delimited by (and including) a I<label> and an I<end label>:

    +-------+-------------------+------------+
    | LABEL |      CONTENT      | END_LABEL  |
    +-------+-------------------+------------+

Example: B<{my_identifier} content of the block {/my_identifier}>

where C<'{my_identifier}'> is the LABEL, C<' content of the block '> is the CONTENT and C<'{/my_identifier}'> is the END_LABEL.

=item end label

An I<end label> is a string in the form of:

    +--------------+---------------+------------+------------+
    | START_MARKER | END_MARKER_ID | IDENTIFIER | END_MARKER |
    +--------------+---------------+------------+------------+

Example of end label : B<{/my_identifier}>

where C<'{'> is the START_MARKER, C<'/'> is the END_MARKER_ID, C<'my_identifier'> is the IDENTIFIER, and C<'}'> is the END_MARKER.

=item identifier

A I<label identifier> is a alphanumeric name C<(\w+)> that represents (and usually matches) a variable or a subroutine identifier of your code.

=item illegal blocks

Each block in the template can contain arbitrary quantities of nested labels and/or blocks, but it cannot contain itself (a block with its same identifier), or cannot be cross-nested.

B<Legal  block>: {block1}...{block2}...{/block2}...{/block1}

B<Illegal auto-nested block>: {block1}...{block1}...{/block1}...{/block1}

B<Illegal cross-nested block>: {block1}...{block2}...{/block1}...{/block2}

If the template contains any illegal block, unpredictable behaviours may occur.

=item include label

An I<include label> is a I<label> used to include a I<template> file. The I<identifier> must be surrounded by single or double quotes and should be a valid path.

Example: B<{'/templates/temp_file.html'}>

=item label

A I<label> is a string in the form of:

    +--------------+------------+------------+------------+
    | START_MARKER | IDENTIFIER | ATTRIBUTES | END_MARKER |
    +--------------+------------+------------+------------+

Example: B<{my_identifier attribute1 attribute2}>

where C<'{'> is the START_MARKER, C<'my_identifier'> is the IDENTIFIER, C<'attribute1 attribute2'> are the ATTRIBUTES and C<'}'> is the END_MARKER.

=item lookup

The action to match label I<identifier> with code identifier (variable, subroutine and method identifier and hash keys).

=item markers

The markers that defines a labels and blocks. These are the default values of the markers that define the label:

    START_MARKER:   {
    END_MARKER_ID:  /
    END_MARKER:     }

You can redefine them by using the C<-markers> constructor array. (see L<"Redefine Markers"> and L<-markers>).

=item matching identifier

The identifier (symbol name or key name) in the code that is matching with the zone or label identifier

=item nested block

A I<nested block> is a I<block> contained in another I<block>:

    +----------------------+
    |   CONTAINER_BLOCK    |
    |  +----------------+  |
    |  |  NESTED_BLOCK  |  |
    |  +----------------+  |
    +----------------------+

Example:
    {my_container_identifier}
    B<{my_nested_identifier} content of the block {/my_nested_identifier}>
    {/my_container_identifier}

where all the above is the CONTAINER_BLOCK and C<'{my_nested_identifier} content of the block {/my_nested_identifier}'> is the NESTED_BLOCK.

=item merger process

The process that merges runtime values with a I<template> producing the final output

=item output

The I<output> is the result of the merger of runtimes values with a template

=item template

A I<template> is a text content or a text file (i.e. plain, HTML, XML, etc.) containing some I<label> or I<block>.

=item value type

The type of the value found by a lookup (i.e. UNDEF, SCALAR, HASH, ARRAY, ...), that is usually used in the I<behaviour> condition to trigger the I<behaviour>.

=item zone

A I<zone> is an area in the template that must have an I<identifier>, may have an I<attributes string> and may have a I<content>. A zone without any content is also called I<label>, while a zone with content is also called I<block>.

=item zone object

A I<zone object> is an internal object representing a zone.

=back

=head1 SEE ALSO

=item * L<Text::MagicTemplate::Zone|Text::MagicTemplate::Zone>

=item * L<Text::MagicTemplate::Tutorial|Text::MagicTemplate::Tutorial>

=item * L<Text::MagicTemplateX|Text::MagicTemplateX>

=item * L<Text::MagicTemplateX::Core|Text::MagicTemplateX::Core>

=item * L<Text::MagicTemplateX::HTML|Text::MagicTemplateX::HTML>

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Text::MagicTemplate.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.

=head1 CREDITS

Thanks to I<Mark Overmeer> http://search.cpan.org/author/MARKOV/ that has submitted a variety of code cleanups/speedups and other useful suggesitions.



