sub
{
    my ($s, $z, $v, $l) = @_;
    ref $v eq 'SCALAR' || ref $v eq 'REF'
    && $s->apply_behaviour($z, $$v, $l)
}