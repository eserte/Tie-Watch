use ExtUtils::MakeMaker;
use Config;

WriteMakefile(
    'NAME'         => 'Tie::Watch',
    'VERSION_FROM' => 'Watch.pm',
    'dist'         => {COMPRESS => 'gzip', SUFFIX => 'gz'}
);
