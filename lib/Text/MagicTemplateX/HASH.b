sub
{
    my ($s, $z) = @_;
    ref $z->value eq 'HASH'
    && $s->parse($z)
}
