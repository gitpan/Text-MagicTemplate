#!perl -w
use Test::More tests => 2;
use strict;
use HTML::MagicTemplate;

use HTML::MagicTemplate qw( NEXT_HANDLER LAST_HANDLER );

is( LAST_HANDLER, 1) ;
is( NEXT_HANDLER, 0) ;
