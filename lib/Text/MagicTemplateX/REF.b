# behaviour extension
# Text::MagicTemplate distribution version 2.22


sub
{
    my ($s, $z) = @_;
    my $v = $z->value ;
    if (ref $z->value =~ /^(SCALAR|REF)$/)
    {
        $s->apply_behaviour($z->value($$v))
    }
    else { undef }
}


