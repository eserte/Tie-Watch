use ExtUtils::MakeMaker;
use Config;

$Version = '0.95';

WriteMakefile(
    'NAME'        => 'Tie::Watch',
    'VERSION'     => $Version,
    'INSTALLDIRS' => 'perl',	
    'PM'          => {'Tie/Watch.pm' => '$(INST_LIBDIR)/Watch.pm'},      
);
