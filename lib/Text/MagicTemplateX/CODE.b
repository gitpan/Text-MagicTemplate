# behaviour extension
# Text::MagicTemplate distribution version 2.11


sub
{
    my ($s, $z) = @_;
    if (ref $z->value eq 'CODE')
    {
		my $l = $z->lookup_element;
        $z->value( !ref $l || ref $l eq 'HASH' ? $z->value->($z)
		: $z->value->($l, $z) );
        $s->apply_behaviour($z)
    }
}