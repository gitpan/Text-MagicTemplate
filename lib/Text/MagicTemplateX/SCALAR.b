# behaviour extension
# Text::MagicTemplate distribution version 2.11


sub
{
    my ($s, $z) = @_;
    !ref $z->value
    && $z->value
}