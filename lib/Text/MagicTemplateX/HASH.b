sub
{
    my ($s, $z, $v, $l) = @_;
    ref $v eq 'HASH'
    && $s->parse($z->{content}, $v)
}