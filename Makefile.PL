use ExtUtils::MakeMaker;

WriteMakefile
(
    NAME             => 'Text::MagicTemplate',
    VERSION_FROM     => 'MagicTemplate.pm',
 	($] ge '5.005') ? (
 	'AUTHOR'         => 'Domizio Demichelis <dd\@4pro.net>',
    'ABSTRACT'       => 'Magic merger of runtime values with template',
	) : (),

);
