use ExtUtils::MakeMaker;
use Config;

WriteMakefile(
    'NAME'         => 'Watch',
    'VERSION_FROM' => 'Tie/Watch.pm',
    'INSTALLDIRS'  => 'perl',	
    'PM'           => {'Tie/Watch.pm' => '$(INST_LIBDIR)/Watch.pm'},      
);
