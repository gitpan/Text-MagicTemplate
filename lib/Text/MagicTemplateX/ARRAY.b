# behaviour extension
# Text::MagicTemplate distribution version 2.2


sub
{
    my ($s, $z) = @_;
    if (ref $z->value eq 'ARRAY')
    {
        join '', map {$s->apply_behaviour($z->value($_))} @{$z->value}
    }
    else { undef }
}

