use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WWW::Google::Buzz',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/WWW/Google/Buzz.pm',
    ABSTRACT_FROM => 'lib/WWW/Google/Buzz.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'WWW-Google-Buzz-*' },
    PREREQ_PM     => {
        'Test::More'     => 0,
        'Readonly'       => 0,
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'URI::Escape'    => '3.29',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);