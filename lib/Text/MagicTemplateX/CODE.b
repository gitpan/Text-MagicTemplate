sub
{
    my ($s, $z, $v, $l) = @_;
    if (ref $v eq 'CODE')
    {
        my $value = !ref $l || ref $l eq 'HASH' ? $v->($z->{content}) : $v->($l, $z->{content});
        $s->apply_behaviour($z, $value, $l)
    }
}
