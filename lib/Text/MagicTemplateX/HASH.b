# behaviour extension
# Text::MagicTemplate distribution version 2.22


sub
{
    my ($s, $z) = @_;
    if (ref $z->value eq 'HASH') { ${$s->parse($z)} }
    else { undef }
}
