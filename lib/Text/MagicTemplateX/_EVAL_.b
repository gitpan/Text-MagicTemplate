# behaviour extension
# Text::MagicTemplate distribution version 2.22


sub
{
    my ($s, $z) = @_;
    if ($z->id eq '_EVAL_')
    {
        $s->apply_behaviour($z->value(eval $z->content))
    }
    else { undef }
}

