package Text::MagicTemplate::HTML;
$VERSION = '1.0';
use Text::MagicTemplate;
push @ISA, qw(Text::MagicTemplate);

__PACKAGE__->syntax qw|<!--{ / }-->|;

 1;
