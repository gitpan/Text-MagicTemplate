# behaviour extension
# Text::MagicTemplate distribution version 2.11


sub
{
    my ($s, $z) = @_;
    ref $z->value =~ /^(SCALAR|REF)$/
    && $s->apply_behaviour($z->value($$v))
}