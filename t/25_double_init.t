#!perl -w
use Test::More tests => 1;
use strict;
use Text::MagicTemplate;

my $tmpl = 'text {var1}, text {var2}. ' ;

my %hash1 = (var1 => 1, var2 => 2) ;
my %hash2 = (var1 => 3, var2 => 4) ;

our $mt = new Text::MagicTemplate
              lookups => \%hash1,
            #  options => 'no_cache'
               ;

my $out = ${$mt->output('t/25_tmpl')} ;

$mt = new Text::MagicTemplate
          lookups => \%hash2 ;


$out .= ${$mt->output('t/25_tmpl')} ;

is($out, 'text 1, text 2. text 3, text 4. ') ;
