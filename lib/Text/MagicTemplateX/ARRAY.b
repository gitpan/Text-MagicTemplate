sub
{
    my ($s, $z, $v, $l) = @_;
    ref $v eq 'ARRAY'
    && join '', map {$s->apply_behaviour($z, $_, $l)} @$v
}