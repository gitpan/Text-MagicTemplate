package Text::MagicTemplate::HTML;
$VERSION = '1.1';
use 5.005;
use Text::MagicTemplate;
push @ISA, qw(Text::MagicTemplate);

__PACKAGE__->syntax ( qw|<!--{ / }-->| );

1;