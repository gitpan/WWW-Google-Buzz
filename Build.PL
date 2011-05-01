use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'WWW::Google::Buzz',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/WWW/Google/Buzz.pm',
    add_to_cleanup    => [ 'WWW-Google-Buzz-*' ],
    build_requires    => {
        'Test::More'     => 0,
        'Readonly'       => 0,
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'URI::Escape'    => '3.29',
    },
);

$builder->create_build_script();