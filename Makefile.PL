use ExtUtils::MakeMaker;
use Config;

$Version = '0.93';

WriteMakefile(
    'NAME'        => 'Tie::Watch',
    'VERSION'     => $Version,
    'INSTALLDIRS' => 'perl',	
    'PM'          => {'Tie/Watch.pm' => '$(INST_LIBDIR)/Watch.pm'},      
);
