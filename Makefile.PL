use ExtUtils::MakeMaker;

WriteMakefile
(
  NAME             => 'Text::MagicTemplate',
  VERSION_FROM     => 'lib/Text/MagicTemplate.pm',
  ($] ge '5.005')
     ? ('AUTHOR'   => 'Domizio Demichelis <dd\@4pro.net>',
        'ABSTRACT' => 'Magic merger of runtime values with templates' )
     : (),
);


sub MY::tool_autosplit
{ 'AUTOSPLITFILE => $(PERLRUN) -MAutoSplit  -e "autosplit($$ARGV[0], $$ARGV[1], 1, 0, 0);"'}

