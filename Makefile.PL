use ExtUtils::MakeMaker;

eval {
    if ((getpwuid($<))[0] eq 'eserte' && $ExtUtils::MakeMaker::VERSION < 6.54) {
	warn <<EOF;
**********************************************************************
* WARNING:
* ExtUtils::MakeMaker too old. META.yml will be imcomplete
**********************************************************************
EOF
    }
};

WriteMakefile(
    'NAME'         => 'Tie::Watch',
    'VERSION_FROM' => 'Watch.pm',
    ($] >= 5.005 ?
       (ABSTRACT   => 'Place watchpoints on Perl (and Tk) variables',
        AUTHOR     => 'Steve Lidie (Stephen.O.Lidie@Lehigh.EDU)') : ()),
    'dist'         => {COMPRESS => 'gzip', SUFFIX => 'gz'},
    ($ExtUtils::MakeMaker::VERSION >= 6.54 ?
     (META_ADD => { resources => { repository => 'git://github.com/eserte/Tie-Watch.git' } }) : ()),
);
