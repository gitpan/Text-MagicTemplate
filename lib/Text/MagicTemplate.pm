package Text::MagicTemplate;
$VERSION = 2.05;
use 5.005;
use Carp qw ( croak );
use strict;

sub default_markers    { [ 'DEFAULT' ] }
sub default_behaviours { [ 'DEFAULT' ] }

sub new
{
    my ($c, $s) = @_;
    map { $s->{$_}      = [$s->{$_}] unless ref $s->{$_} eq 'ARRAY' } keys %$s;
    $s->{-markers}    ||= $c->default_markers;
    $s->{-behaviours} ||= $c->default_behaviours;
    $s->{-lookups}    ||= [ (caller)[0] ];
    $s->{-markers}      = do "Text/MagicTemplateX/$s->{-markers}[0].m"
                          or croak "Error opening markers extension: \"$s->{-markers}[0]\": $^E"
                          unless @{$s->{-markers}}==3 ;
    $s->{-markers}      = [ map qr/$_/s, @{$s->{-markers}}, '(?:\s\w+)*', '\w+' ];
    $s->{-behaviours}   = [ $c->load_behaviours($s->{-behaviours}) ];
    bless $s, $c;
}

sub load_behaviours
{
    my ($c, $b) = @_;
    map { if    (ref eq 'CODE'){ $_ }
          elsif (!ref) { my $ref = do "Text/MagicTemplateX/$_.b"
                         or croak "Error opening behaviour extension: \"$_\": $^E";
                         if    (ref $ref eq 'ARRAY') {$c->load_behaviours($ref)}
                         elsif (ref $ref eq 'CODE')  { $ref } } } @$b
}

sub get_block
{
    my ($s, $temp, $id) = @_;
    $temp = $s->read_temp($temp);
    my ($S, $I, $E, $A) = @{$s->{-markers}};
    $temp =~ s/ $S ('|") (.*?) \1 $E /${$s->get_block($2)}/xgse;   # include
    ($temp) = $temp =~ /( $S$id$A$E (?: (?! $S$id$A$E) (?! $S$I$id$E) . )* $S$I$id$E )/xs if $id;
    \$temp;
}

sub read_temp
{
    local $_ = $_[1] || croak 'No template parameter passed';
    if    (ref eq 'SCALAR') { $_ = $$_ }
    elsif (ref eq 'GLOB' || ref \$_ eq 'GLOB'){ $_ = do{local $/; <$_>} }
    elsif ($_ && !ref) { open _ or croak "Error opening the template file \"$_\": ($^E)";
                         $_ = do{local $/; <_>}; close _ }
    else  { croak 'Wrong template parameter type: '. (ref||'UNDEF') }
    $_ or croak 'The template content is empty';
}

sub set_block
{
    my ($s, $temp, $id, $new) = @_;
    my ($S, $I, $E, $A) = @{$s->{-markers}};
    $temp = $s->get_block($temp);
    $$temp =~ s/ $S$id$A$E (?: (?! $S$id$A$E) (?! $S$I$id$E) . )* $S$I$id$E /$$new||$new/xgse ;
    $temp;
}

sub output { \$_[0]->parse(${&get_block}) }

sub print
{
	my $s = shift;
	$s = $s->new( {-lookups => [ (caller)[0] ]} ) unless ref $s;
	print ${$s->output(@_)}
}

sub parse
{
    my ($s, $temp, $v) = @_;
    my ($S, $I, $E, $A, $ID) = @{$s->{-markers}};
    $temp =~ s/ $S($ID)($A)$E  (?: ( (?: (?! $S\1$A$E) (?! $S$I\1$E) . )* )  $S$I\1$E  )?
              /$s->lookup({ id=>$1, attributes=>$2 && substr($2,1), content=>$3 }, $v)/xgse ;
    $temp;
}

sub lookup
{
    my ($s, $z, $v) = @_;
    for ( $v || @{$s->{-lookups}} )
    {
        my $value = ref eq 'HASH' && $_->{$z->{id}}
                    ?     $_->{$z->{id}}
                    : do{ local *S = '*'.(ref $_||$_).'::'.$z->{id};
    	                  ${*S}||*S{CODE}||*S{ARRAY}||*S{HASH} };
        if (my $result = $s->apply_behaviour($z, $value, $_)){return $result};
    }
    $s->lookup( $z ) if $v;
}

sub apply_behaviour
{
    for ( @{$_[0]->{-behaviours}} )
    { if (my $result = &$_){return $result} }
}

sub set_ID_output
{
    require Text::MagicTemplate::Utilities;
    import Text::MagicTemplate::Utilities qw(parse) # redefine subs
}

1;