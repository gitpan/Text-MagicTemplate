sub
{
    my ($s, $z, $v, $l) = @_;
    if (ref $v eq 'CODE')
    {
        my $value = !ref $l || ref $l eq 'HASH' ? $v->($z->{content}, $z->{attributes}) : $v->($l, $z->{content}, $z->{attributes});
        $s->apply_behaviour($z, $value, $l)
    }
}
