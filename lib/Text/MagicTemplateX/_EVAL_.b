sub
{
    my ($s, $z) = @_;
    $z->id eq '_EVAL_'
    && $s->apply_behaviour($z->value(eval $z->content))
}
