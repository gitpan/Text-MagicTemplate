# behaviour extension
# Text::MagicTemplate distribution version 2.2


sub
{
    my ($s, $z) = @_;
    if (ref $z->value =~ /^(SCALAR|REF)$/)
    {
        $s->apply_behaviour($z->value($$v))
    }
    else { undef }
}


