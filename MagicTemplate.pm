package Text::MagicTemplate;
$VERSION = '1.31';
use 5.005;
use Carp qw ( croak );
use strict; no strict "refs";

__PACKAGE__->syntax( qw|{ / }| );

sub syntax
{
    my $c = shift;
    if (@_ == 3) { @{$c.'::SYNTAX'} = map qr/$_/s, @_, '(?:\s\w+)*', '\w+' }
    else         { croak 'Wrong number of syntax markers: got '. @_ . ', expected 3.' }
}

sub new            { my $c=shift; bless { location => @_?[@_]:[(caller)[0]] }, $c }
sub print          { print ${&output} }
sub output         { \$_[0]->_parse(${&get_block}) }
sub subs_execution { ${$_[0].'::_NS'} = ! $_[1] }

sub get_block
{
    my ($c, $temp, $id) = @_;
    $temp = _read_temp($temp);
    my ($S, $I, $E, $A) = @{(ref $c || $c).'::SYNTAX'};
    $temp =~ s/ $S ('|") (.*?) \1 $E /${$c->get_block($2)}/xgse;   # include
    ($temp) = $temp =~ /( $S$id$A$E (?: (?! $S$id$A$E) (?! $S$I$id$E) . )* $S$I$id$E )/xs if $id;
    \$temp;
}

sub _read_temp
{
    local $_ = shift || croak 'No parameter passed as template';
    if    (ref eq 'SCALAR') { $_ = $$_ }
    elsif (ref eq 'GLOB' || ref \$_ eq 'GLOB'){ $_ = do{local $/; <$_>} }
    elsif ($_ && !ref) { open _ or croak "Error opening the file \"$_\": ($^E)";
                           $_ = do{local $/; <_>}; close _ }
    else  { croak 'Wrong template parameter type: '. (ref||'UNDEF') }
    $_ or croak 'The template content is empty';
}

sub set_block
{
    my ($c, $temp, $id, $new) = @_;
    my ($S, $I, $E, $A) = @{$c.'::SYNTAX'};
    $temp = $c->get_block($temp);
    $$temp =~ s/ $S$id$A$E (?: (?! $S$id$A$E) (?! $S$I$id$E) . )* $S$I$id$E /$$new||$new/xgse ;
    $temp;
}

sub _parse
{
    my ($s, $temp, $v) = @_;
    my ($S, $I, $E, $A, $ID) = @{ref($s).'::SYNTAX'};
    $temp =~ s/ $S($ID)($A)$E  (?: ( (?: (?! $S\1$A$E) (?! $S$I\1$E) . )* )  $S$I\1$E  )?
              /$s->_lookup({ id=>$1, attributes=>$2 && substr($2, 1), content=>$3 }, $v)/xgse ;
    $temp;
}

sub _lookup
{
    my ($s, $t, $v) = @_;
    for ($v || @{$s->{location}})
    {
    	my $res;
        if (!ref) { local *S = '*'.$_.'::'.$t->{id}; $res = $s->_value($t, ${*S}||*S{CODE}||*S{ARRAY}||*S{HASH}) }
        elsif ( $_->{$t->{id}} )                   { $res = $s->_value($t, $_->{$t->{id}}) }
        return $res if $res;
    }
    $s->_lookup( $t ) if $v;
}

sub _value
{
    my ($s, $t, $v) = @_; my $rv = ref $v;
    if    (! $rv)                             { $v }
    elsif ($rv=~/(SCALAR|REF)/)               { $s->_value($t, $$v) }
    elsif ($rv=~/CODE/ &&! ${ref($s).'::_NS'}){ $s->_value($t, $v->($t->{content})) }
    elsif ($rv=~/ARRAY/)                      { join '', map {$s->_value($t, $_)} @$v }
    elsif ($rv=~/HASH/)                       { $s->_parse($t->{content}, $v) }
}

sub set_ID_output
{
    require Text::MagicTemplate::Utilities;
    import Text::MagicTemplate::Utilities qw( _parse ) ; # redefine subs
}

sub code_execution_ON  { $_[0]->subs_execution(1) } # deprecated alias
sub code_execution_OFF { $_[0]->subs_execution(0) } # deprecated alias
sub code_execution     { $_[0]->subs_execution(1) } # deprecated alias
sub no_code_execution  { $_[0]->subs_execution(0) } # deprecated alias

1;