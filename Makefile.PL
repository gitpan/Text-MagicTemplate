use ExtUtils::MakeMaker;

WriteMakefile
(
    NAME         => 'Text::MagicTemplate',
    AUTHOR       => 'Domizio Demichelis <dd\@4pro.net>',
    VERSION_FROM => 'MagicTemplate.pm',
    PREREQ_PM   => {'test::Harness' => '0'}
);
