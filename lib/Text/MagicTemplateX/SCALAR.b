# behaviour extension
# Text::MagicTemplate distribution version 2.2


sub
{
    my ($s, $z) = @_;
    if (!ref $z->value) { $z->value }
    else { undef }
}


