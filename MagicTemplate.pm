package Text::MagicTemplate;
$VERSION = '1.2';
use Carp qw ( croak );
use strict; no strict "refs";

sub new
{
    my $c = shift;
    @_ || push @_, caller;
    $c->syntax || $c->syntax qw|{ / }| ;
    defined ${$c.'::_CODE_EXECUTION'} || $c->code_execution;
    bless \@_, $c;
}

sub syntax
{
    my $c = shift;
    (${$c.'::_START'}, ${$c.'::_END_ID'}, ${$c.'::_END'}) = map quotemeta, @_ if @_;
    (${$c.'::_START'}, ${$c.'::_END_ID'}, ${$c.'::_END'});
}

sub code_execution    { ${shift().'::_CODE_EXECUTION'} = 1 }
sub no_code_execution { ${shift().'::_CODE_EXECUTION'} = 0 }

sub print
{
    my ($s) = shift;
    print ${$s->output(@_)};
}

sub output
{
    my ($s) = shift;
    \$s->_block( ${$s->get_block(@_)} );
}

sub get_block
{
    my ($type, $temp, $id) = @_;
    my $c = ref $type || $type;
    my ($S, $I, $E) = $c->syntax;
    if (ref $temp) { $temp = $$temp }
    else           { open INP, $temp or croak "Error opening template file \"$temp\" ($!)";
                     $temp = do {local $/; <INP>}; close INP; }
    $temp =~ s/ $S ('|") (.*?) \1 $E / ${$c->get_block($2)} /xgse;   # include
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
            if    (defined &{*sym} and ${ref ($s).'::_CODE_EXECUTION'}) { return $s->_value ($content, &{*sym}($content)) }
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
    if    (ref $value eq 'CODE' and ${ref ($s).'::_CODE_EXECUTION'})  { return $s->_value ($content, &$value($content)) }
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

if ($Text::MagicTemplate::ID_OUTPUT)
{
    require Text::MagicTemplate::Utilities;
    import Text::MagicTemplate::Utilities qw ( _block ) ; # redefine subs
}

1;