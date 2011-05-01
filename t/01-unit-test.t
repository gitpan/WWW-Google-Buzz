#!perl

use strict; use warnings;
use WWW::Google::Buzz;
use Test::More tests => 1;

my ($buzz);

eval { $buzz = WWW::Google::Buzz->new(); };
like($@, qr/ERROR: API Key is missing./);