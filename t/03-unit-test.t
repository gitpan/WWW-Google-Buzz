#!perl

use strict; use warnings;
use WWW::Google::Buzz;
use Test::More tests => 5;

my $api_key = 'AIzaSyAe7Flr-9rBq-9Aqi84P9QYM8NsR4wSi1M';
my $buzz    = WWW::Google::Buzz->new($api_key);

eval { $buzz->get_public_activities(); };
like($@, qr/ERROR: Missing input parameters./);

eval { $buzz->get_public_activities(user_id => 'googlebuzz'); };
like($@, qr/ERROR: Input param has to be a ref to HASH./);

eval { $buzz->get_public_activities({usser_id => 'googlebuzz'}); };
like($@, qr/ERROR: Missing key 'user_id' in the param list./);

eval { $buzz->get_public_activities({user_id => 'googlebuzz', alt => 'atm'}); };
like($@, qr/ERROR: Invalid value for key 'alt': \[atm\]/);

eval { $buzz->get_public_activities({user_id => 'googlebuzz', alt => 'atom', prettyprint => 'trrue'}); };
like($@, qr/ERROR: Invalid value for key 'prettyprint': \[trrue\]/);