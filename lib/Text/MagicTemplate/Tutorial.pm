package Text::MagicTemplate::Tutorial
$VERSION = '1.01'
__END__

=head1 NAME

Text::MagicTemplate::Tutorial - useful tutorial for Text::MagicTemplate.

=head1 DESCRIPTION

This Tutorial is a complement of L<Text::MagicTemplate>; it is oriented to suggest you specific solutions to specific needs.

=head1 HOW TO...

You should read and understand section L<Text::MagicTemplate/"How it works">, before reading this section.

=head2 Include a file

To include a file in a template just set a label with the pathname of the file as identifier, surrounded by quotes:

    {'/temp/footer.html'}

The file will be included in place of the label and if it is a template, it will be processed as usual.

=head2 Redefine Markers

=over

=item by explicitly define the -markers constructor parameter

    $mt = new Text::MagicTemplate { -markers => [qw(<- / ->)] }; # redefine the markers as needed

=item by using a markers extension

The standard installation comes with a HTML friendly markers extension that implements a HTML-comment-like syntax. If your output is an HTML text - or just because you prefer that particular look - you can use it instead of using the default markers.

    $mt = new Text::MagicTemplate { -markers => 'HTML' };
    # that means
    $mt = new Text::MagicTemplate { -markers => [qw(<!-- / -->)] };

=item by creating a new markers extension

If you need some custom and permanent solution you can create your own syntax extension.

Redefine the markers and save this code as the file F<'myCustomMarkers.m'> into the Text::MagicTemplateX directory:

    [ qw(__ END_ __) ]; # redefine these values as needed

Use it by loading the extension as usual:

    $mt = new Text::MagicTemplate { -markers => 'myCustomMarkers' };

This syntax would work with this block labeled 'my_identifier':

    __my_identifier__ content of block __END_my_identifier__

If you write some custom syntax extension - useful for any particular output - please, let me know.

See L<-markers|Text::MagicTemplate/-markers> constructor parameter key for details.

=back

=head2 Setup a template

A quick way to setup a template in 4 simple steps is the following:

=over

=item 1 Prepare an output

Prepare a complete output as your code could print. Place all the static items of your output where they should go, place placeholders (any runtime value that your code would supply) where they should go and format everything as you want

=item 2 Choose names

Choose meaningful names (or variables and subroutines names if you already have a code) for labels and blocks

=item 3 Insert single labels

Find the dynamic items in the template and replace them with a label, or if you want to keep them as visible placeholders, transform each one of them into a block

=item 4 Define blocks

If you have any area that will be repeated by a loop or that will be printed just under certain conditions transform it into a block.

=back

=head2 Setup placeholders

These are a couple of templates that use a HTML friendly sintax (implemented in B<Text::MagicTemplate::HTML>). The output will be the same for both templates, with or without placeholders: the difference is the way you can look at the template.

=over

=item template without placeholders

    <p><hr>Name: <b style="color:blue"><!--{name}--></b><br>
    Surname: <b style="color:blue"><!--{surname}--></b><hr></p>

This is what you would see in a WYSIWYG editor: I<(you should be using a browser to see the example below this line)>

=for html
<p><hr>Name: <b style="color:blue"><!--{name}--></b><br>
Surname: <b style="color:blue"><!--{surname}--></b><hr></p>

=item template with placeholders

The placeholders "John" and "Smith" are included in blocks and will be replaced by the actual values of 'name' and 'surname' from your code.

    <p><hr>Name: <b style="color:blue"><!--{name}-->John<!--{/name}--></b><br>
    Surname: <b style="color:blue"><!--{surname}-->Smith<!--{/surname}--></b><hr></p>

This is what you would see in a WYSIWYG editor: I<(you should be using a browser to see the example below this line)>

=for html
<p><hr>Name: <b style="color:blue"><!--{name}-->John<!--{/name}--></b><br>
Surname: <b style="color:blue"><!--{surname}-->Smith<!--{/surname}--></b><hr></p>

=back

=head2 Setup simulated areas

If you want to include in your template some area only for design purpose I<(for example to see, right in the template, how could look a large nested loop)>, just transform it into a block and give it an identifier that will never be defined in your code.

    {my_simulated_area}this block simulates a possible output and it will never generate any output{/my_simulated_area}

=head2 Setup labeled areas

If you want to label some area in your template I<(for example to extract the area to mix with another template)>, just transform it into a block and give it an identifier that will always be defined in your code. A convenient way to do so is to set the identifier to a reference to an empty hash. This will generate the output of the block and will do the lookup into the stored locations.

=over

=item the code

    $my_labeled_area = {};  # a ref to an empty hash

=item the template

    {my_labeled_area}this block will always generate an output{/my_labeled_area}

=back

=head2 Build a loop

=over

=item the template

A loop is represented by a block, usually containing labels:

    A loop:
    {my_loop}-------------------
    Date: {date}
    Operation: {operation}
    {/my_loop}-------------------

=item the code

You should have some array of hashes (or a reference to) defined somewhere:

    $my_loop = [
                 { date => '8-2-02', operation => 'purchase' },
                 { date => '9-3-02', operation => 'payment' }
               ] ;

=item the output

    A loop:
    -------------------
    Date: 8-2-02
    Operation: purchase
    -------------------
    Date: 9-3-02
    Operation: payment
    -------------------

=back

=head2 Build a nested loop

=over

=item the template

A nested loop is represented by a block nested into another block:

    A nested loop:
    {my_nested_loop}-------------------
    Date: {date}
    Operation: {operation}
    Details:{details}
               - {quantity} {item}{/details}
    {/my_nested_loop}-------------------

Note that the block I<'details'> is nested into the block I<'my_nested_loop'>.

=item the code

You should have some array nested into some other array, defined somewhere:

    # a couple of nested "for" loops may produce this:
    $my_nested_loop = [
                         {
                            date      => '8-2-02',
                            operation => 'purchase',
                            details   => [
                                            {quantity => 5, item => 'balls'},
                                            {quantity => 3, item => 'cubes'},
                                            {quantity => 6, item => 'cones'}
                                         ]
                         },
                         {
                            date      => '9-3-02',
                            operation => 'payment',
                            details   => [
                                            {quantity => 2, item => 'cones'},
                                            {quantity => 4, item => 'cubes'}
                                         ]
                          }
                      ] ;

Note that the value of the keys I<'details'> are a reference to an array of hashes.

=item the output

    A nested loop:
    -------------------
    Date: 8-2-02
    Operation: purchase
    Details:
              - 5 balls
              - 3 cubes
              - 6 cones
    -------------------
    Date: 9-3-02
    Operation: payment
    Details:
              - 2 cones
              - 4 cubes
    -------------------

=back

=head2 Setup an if-else condition

=over

=item the template

An if-else condition is represented with 2 blocks

    {OK_block}This is the OK block, containig {a_scalar}{/OK_block}
    {NO_block}This is the NO block{/NO_block}

=item the code

Remember that a block will be deleted if the lookup of the identifier returns the UNDEF value, so your code will determine what block will generate output (defined identifier) and what not (undefined identifier).

    if ($OK) { $OK_block = {a_scalar => 'A SCALAR VARIABLE'} }
    else     { $NO_block = {} }

Same thing here:

    $a_scalar = 'A SCALAR VARIABLE';
    $OK ? $OK_block={} : $NO_block={};

=item the output

A true C<$OK> would leave undefined C<$NO_block>, so it would produce this output:

    This is the OK block, containig A SCALAR VARIABLE

A false $OK would leave undefined C<$OK_block>, so it would produce this output:

    This is the NO block

Note that C<$OK_block> and C<$NO_block> should not return a SCALAR value, that would replace the whole block with the value of the scalar.

=back

=head2 Setup a switch condition

=over

=item the template

A simple switch (if-elsif-elsif) condition is represented with multiple blocks:

    {type_A}type A block with {a_scalar_1}{/type_A}
    {type_B}type B block with {a_scalar_2}{/type_B}
    {type_C}type C block with {a_scalar_1}{/type_C}
    {type_D}type D block with {a_scalar_2}{/type_D}

=item the code

Your code will determine what block will generate output (defined identifier) and what not (undefined identifier). In the following example, value of C<$type>  will determine what block will produce output, then the next line will define C<$type_C> using a symbolic reference:

    $type  = 'type_C';
    $$type = { a_scalar_1 => 'THE SCALAR 1', a_scalar_2 => 'THE SCALAR 2' };

Same thing yet but with a different programming style:

    $a_scalar_1 = 'THE SCALAR 1';
    $a_scalar_2 = 'THE SCALAR 2';
    $type       = 'type_D';
    $$type      = {};

Same thing without using any symbolic reference:

    $type       = 'type_D';
    $my_hash{$type} = { a_scalar_1 => 'THE SCALAR 1', a_scalar_2 => 'THE SCALAR 2' };
    $mt = new Text::MagicTemplate { -lookups => \%my_hash };

=item the output

A C<$type> set to 'type_C' would produce this output:

    type C block with THE SCALAR 1

A C<$type> set to 'type_D' would produce this output:

    type D block with THE SCALAR 2

=back

=head2 Pass parameters to a subroutine

Text::MagicTemplate can execute subroutines from your code: when you use a block identifier that matches with a subroutine identifier, the subroutine will receive the content of the block as a single parameter and will be executed. This is very useful when you want to return a modified copy of the template content itself, or if you want to allow the designer to pass parameter to the subroutines, or if you want to evaluate a perl expression inside the template.

This example show you how to allow the designer to pass some parameters to a subroutine in your code.

=over

=item the template

    {matrix}5,3{/matrix}

The content of 'matrix' block ('5,3') is used as parameter

=item the code

    sub matrix
    {
        my ($block_content) = shift;
        my ($column, $row) = split ',' , $block_content;         # split the parameters
        my $out;
        for (0..$row-1) {$out .= 'X' x $column. "\n"};
        $out;
    }

The sub 'matrix' receive the content of the template block as a single parameter, and return the output for the block

=item the output

    XXXXX
    XXXXX
    XXXXX

=back

=head2 Use subroutines to rewrite links

If you use a block identifier that matches with a subroutine identifier, the subroutine will receive the content of the block as a single parameter and will be executed. This is very useful when you want to return a modified copy of the template content itself.

A typical application of this capability is the template of a HTML table of content that point to several template files. You can use the capabilities of your favourite WYSIWYG editor to easily link each menu in the template with each template file. By doing so you will generate a static and working HTML file, linked with the other static and working HTML template files. This will allow you to easily check the integrity of your links, and preview how the links would work when utilized by your program.

Then a simple C<modify_link> subroutine - defined in your program - will return a self-pointing link that Text::MagicTemplate::HTML will put in the output in place of the static link. See the example below:

=over

=item the template

    <p><a href="<!--{modify_link}-->add.html<!--{/modify_link}-->">Add Item</a></p>
    <p><a href="<!--{modify_link}-->update.html<!--{/modify_link}-->">Update Item</a></p>
    <p><a href="<!--{modify_link}-->delete.html<!--{/modify_link}-->">Delete Item</a></p>

Working links pointing to static templates files (useful for testing and preview purpose, without passing through the program)

=item the code

    sub modify_link
    {
        my ($behaviour) = shift =~ m|([^/]*).html$|;
        return '/path/to/myprog.cgi?behaviour='.$behaviour;
    }

=item the output

    <p><a href="/path/to/myprog.cgi?behaviour=add">Add Item</a></p>
    <p><a href="/path/to/myprog.cgi?behaviour=update">Update Item</a></p>
    <p><a href="/path/to/myprog.cgi?behaviour=delete">Delete Item</a></p>

Working links pointing to your program, defining different query strings.

See also L<"Passing parameters to a subroutine">.

=back

=head2 Prepare the identifiers description list

If you have to pass to a webmaster the description of every identifier in your program utilized by any label or block, Text::MagicTemplate can help you by generating a pretty formatted list of all the identifiers (from labels and blocks) present in any output printed by your program. Just follow these steps:

=over

=item 1 Add the following line anywhere before printing the output:

    Text::MagicTemplate->set_ID_output;

=item 2 Capture the outputs of your program

Your program will run exactly the same way, but instead of print the regular outputs, it will print just a pretty formatted list of all the identifiers present in any output.

=item 3 Add the description

Add the description of each label and block to the captured output and give it to the webmaster.

=back

=head2 Allow untrustworthy people to edit the template

F<MagicTemplate.pm> does not use any eval() statement, it just do a recursive search and replace with the content of the template. Besides, the allowed characters for identifiers are only alphanumeric C<(\w+)>, so even dealing with tainted templates should not raise any security problem that you wouldn't have in your program itself.

However, since the module is just about 90 lines of code, you should consider to analise it directly. If you do this, please send me some feedback.

=head3 Avoid unwanted executions

This module can execute the subroutines of your code whenever it matches a label or block identifier with the subroutine identifier. Though unlikely, it is possible in principle that someone (only if allowed to edit the template) sneaks the correct identifier from your code, therefore, if you have any potentially dangerous subroutine in your code, you should restrict this capability. To do this, you can omit the 'CODE' behaviour, or pass only explicit locations to the C<new()> method.

=over

=item potentially unsafe code

    sub my_potentially_dangerous_sub { unlink 'database_file' };
    $name = 'John';
    $surname = 'Smith';
    $mt = new Text::MagicTemplate ; # automatic lookup in __PACKAGE__ namespace

With this code, a malicious person allowed to edit the template could add the label I<{my_potentially_dangerous_sub}> in the template and that label would trigger the deletion of 'database_file'.

=item code with subs_execution disabled

Just explicitly omit the 'CODE' behaviour when you create the object, so no sub will be executed:

     $mt = new Text::MagicTemplate { -behaviours => [qw(SCALAR REF ARRAY HASH)] };

=item code with restricted lookups

    sub my_potentially_dangerous_sub { unlink 'database_file' };
    %my_restricted_hash = ( name => 'John', surname => 'Smith' );
    $mt = new Text::MagicTemplate {-lookups => \%my_restricted_hash } ; # lookup in %my_restricted_hash only

With this code the lookup is restricted to just the identifiers used in the template, thus the subroutine C<my_potentially_dangerous_sub> is unavailable to the outside world. (see C<new()> method).

=back

=head2 Embed perl into a template

This example represents the maximum degree of inclusion of perl code into a template: in this situation, virtually any code inside the '_EVAL_' block will be executed from the template. For obvious reasons you should use this behaviour ONLY if you are the programmer AND the designer.

=over

=item the template

    {_EVAL_}$char x ($num+1){/_EVAL_}

The content of '_EVAL_' block could be any perl expression

=item the code

    $mt = new Text::MagicTemplate { -behaviours => [ 'DEFAULT', '_EVAL_' ] };
    $char = 'W';
    $num = 5;


=item the output

The behaviour will return the evaluated content of the block.

    WWWWWW

Since a block can contain any quantity of text, you could use this type of configuration as a cheap way to embed perl into (HTML) files.

Note that the default syntax markers ({/}) could somehow clash with perl blocks, so if you want to embed perl into your templates, you should consider to redefine the syntax with some more appropriate marker (See L<"Redefine Syntax">).

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this software. Feel free to write me any comment, suggestion or request.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.