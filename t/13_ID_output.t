## 13

use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }

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

$espected = << '__EOS__';
IDENTIFIERS LIST: 
my_nested_loop: 
	date: 
	operation: 
	details: 
		quantity: 
		item: 
	/details: 
/my_nested_loop: 
__EOS__

$mt->set_ID_output;
$content = $mt->output(\$tmp);
ok($$content."\n", $espected);
