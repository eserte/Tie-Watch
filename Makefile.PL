use ExtUtils::MakeMaker;

my $eumm_recent_enough = $ExtUtils::MakeMaker::VERSION >= 6.54;

if (!$eumm_recent_enough) {
    *MY::dist_core = sub {
	<<'EOF';
dist :
	$(NOECHO) $(ECHO) "Sorry, use a newer EUMM!"

EOF
    };
}

WriteMakefile(
    'NAME'         => 'Tie::Watch',
    'VERSION_FROM' => 'lib/Tie/Watch.pm',
    'PREREQ_PM'    => {
        'Test::More'    => 0.47,
        'Scalar::Util'  => 0,
    },
    ($] >= 5.005 ?
       (ABSTRACT   => 'Place watchpoints on Perl (and Tk) variables',
        AUTHOR     => 'Steve Lidie (Stephen.O.Lidie@Lehigh.EDU)') : ()),
    'dist'         => {COMPRESS => 'gzip', SUFFIX => 'gz'},
    ($eumm_recent_enough ?
     (META_ADD => { resources => { repository => 'git://github.com/eserte/Tie-Watch.git' } }) : ()),
);
