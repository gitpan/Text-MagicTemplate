use strict ;
use Test::More tests => 1 ;
use Text::MagicTemplate;

our ($mt, $content, $tmp, $my_nested_loop);

$mt = new Text::MagicTemplate;
$tmp = 'A nested loop:{my_nested_loop}|Date: {date} - Operation: {operation} - Details:{details} - {quantity} {item}{/details} - {/my_nested_loop}|';

$my_nested_loop = [
                     {
                        date      => '8-2-02',
                        operation => 'purchase',
                        details   => [
                                        {quantity => 5, item => 'balls'},
                                        {quantity => 3, item => 'cubes'},
                                        {quantity => 6, item => 'cones'}
                                     ]
                     },
                     {
                        date      => '9-3-02',
                        operation => 'payment',
                        details   => [
                                        {quantity => 2, item => 'cones'},
                                        {quantity => 4, item => 'cubes'}
                                     ]
                      }
                  ] ;

$content = $mt->output(\$tmp);
is($$content, 'A nested loop:|Date: 8-2-02 - Operation: purchase - Details: - 5 balls - 3 cubes - 6 cones - |Date: 9-3-02 - Operation: payment - Details: - 2 cones - 4 cubes - |');
