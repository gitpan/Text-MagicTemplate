sub
{
    my ($s, $z) = @_;
    ref $z->value =~ /^(SCALAR|REF)$/
    && $s->apply_behaviour($z->value($$v))
}
