sub
{
    my ($s, $t, $v, $l) = @_;
    $t->{id} eq '_EVAL_'
    && $s->apply_behaviour($z, eval $t->{content}, $l)
}
