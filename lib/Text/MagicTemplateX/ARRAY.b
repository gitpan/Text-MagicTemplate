sub
{
    my ($s, $z) = @_;
    ref $z->value eq 'ARRAY'
    && join '', map {$s->apply_behaviour($z->value($_))} @{$z->value}
}
