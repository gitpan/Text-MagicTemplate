package Text::MagicTemplate;
$VERSION = '1.25';
use 5.005;
use Carp qw ( croak );
use strict; no strict "refs";

__PACKAGE__->syntax ( qw|{ / }| );

sub new
{
    my $c = shift;
    my $s ;
    @_ ? @$s = @_ : $s->[0] = (caller)[0];
    bless $s, $c;
}

sub syntax
{
    my $c = shift;
    (${$c.'::_START'}, ${$c.'::_END_ID'}, ${$c.'::_END'}) = map qr($_), @_ if @_;
    (${$c.'::_START'}, ${$c.'::_END_ID'}, ${$c.'::_END'});
}

sub print              { print ${&output} }
sub output             { \$_[0]->_block( ${&get_block} ) }
sub code_execution_ON  { ${shift().'::_NO_CODE'} = 0 }
sub code_execution_OFF { ${shift().'::_NO_CODE'} = 1 }

sub get_block
{
    my ($type, $temp, $id) = @_;
    my $c = ref $type || $type;
    my ($S, $I, $E) = $c->syntax;
    if (ref $temp) { $temp = $$temp }
    else           { open INP, $temp or croak "Error opening template file \"$temp\" ($!)";
                     $temp = do {local $/; <INP>}; close INP; }
    $temp =~ s/ $S ('|") (.*?) \1 $E /${$c->get_block($2)}/xgse;   # include
    ($temp) = $temp =~ /($S $id $E .*? $S $I $id $E)/xs if $id;
    \$temp;
}

sub set_block
{
    my ($c, $temp, $id, $new_content) = @_;
    my ($S, $I, $E) = $c->syntax;
    $temp = $c->get_block($temp);
    $new_content = $$new_content if ref $new_content;
    $$temp =~ s/ $S $id $E .*? $S $I $id $E /$new_content/xsg ;
    $temp;
}

sub _block
{
    my ($s, $content, $ref) = @_;
    my ($S, $I, $E) = ref($s)->syntax;
    $content =~ s/ $S (\w+) $E (?: (.*?) $S $I \1 $E )? /$s->_lookup($2, $1, $ref)/xsge ;
    $content;
}

sub _lookup
{
    my ($s, $content, $id, $hash_ref) = @_;
    my @item = $hash_ref || @$s;
    foreach my $location (@item)
    {
        if (not ref $location)
        {
            local *sym = '*'.$location.'::'.$id;
            if    (defined &{*sym} and not ${ref ($s).'::_NO_CODE'}) { return $s->_value ($content, &{*sym}($content)) }
            elsif (defined ${*sym}) { return $s->_value ($content, ${*sym}) }
            elsif (defined @{*sym}) { return $s->_loop  ($content, \@{*sym}) }
            elsif (defined %{*sym}) { return $s->_block ($content, \%{*sym}) }
        }
        elsif ( ref $location eq 'HASH' and exists $location->{$id} ) { return $s->_value($content, $location->{$id}) }
    }
    if  ($hash_ref) { return $s->_lookup ( $content, $id ) }
    else            { return undef }
}

sub _value
{
    my ($s, $content, $value) = @_;
    if    (ref $value eq 'CODE' and not ${ref ($s).'::_NO_CODE'})  { return $s->_value ($content, &$value($content)) }
    elsif (not ref $value)        { return $value }
    elsif (ref $value eq 'SCALAR'){ return $$value }
    elsif (ref $value eq 'ARRAY') { return $s->_loop  ($content, $value) }
    elsif (ref $value eq 'HASH')  { return $s->_block ($content, $value) }
}

sub _loop
{
    my ($s, $content, $arr_ref) = @_;
    my ($loop_content);
    for my $i (0..$#$arr_ref) { $loop_content .= $s->_value($content, $arr_ref->[$i]) }
    $loop_content;
}

sub set_ID_output
{
    require Text::MagicTemplate::Utilities;
    import Text::MagicTemplate::Utilities qw ( _block ) ; # redefine subs
}

sub code_execution     { &code_execution_ON }  # deprecated alias
sub no_code_execution  { &code_execution_OFF } # deprecated alias

1;