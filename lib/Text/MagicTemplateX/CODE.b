# behaviour extension
# Text::MagicTemplate distribution version 2.22


sub
{
    my ($s, $z) = @_;
    if ( ref $z->value eq 'CODE' )
    {
        my $v = $z->value;
        my $l = $z->location;
        if (!ref $l or ref $l eq 'HASH') { $z->value($z->value->($z)) }
        else                             { $z->value($z->value->($l, $z)) }
        $v ne $z->value ? $s->apply_behaviour($z) : undef
    }
     else { undef }
}


