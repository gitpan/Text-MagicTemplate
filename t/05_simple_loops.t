## 5

use Test;
use Text::MagicTemplate;
BEGIN {  plan tests => 1 }


$mt = new Text::MagicTemplate;
$tmp = 'A loop:{my_loop}|Date: {date} - Operation: {operation}{/my_loop}|';

$my_loop = [
             { date => '8-2-02', operation => 'purchase' },
             { date => '9-3-02', operation => 'payment' }
           ] ;

$content = $mt->output(\$tmp);
ok ($$content, 'A loop:|Date: 8-2-02 - Operation: purchase|Date: 9-3-02 - Operation: payment|');
