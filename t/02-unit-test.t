#!perl

use strict; use warnings;
use WWW::Google::Buzz;
use Test::More tests => 12;

my $api_key = 'AIzaSyAe7Flr-9rBq-9Aqi84P9QYM8NsR4wSi1M';
my $buzz    = WWW::Google::Buzz->new($api_key);

eval { $buzz->search_activities(); };
like($@, qr/ERROR: Missing input parameters./);

eval { $buzz->search_activities(q => 'obama'); };
like($@, qr/ERROR: Input param has to be a ref to HASH./);

eval { $buzz->search_activities({qa => 'obama'}); };
like($@, qr/ERROR: Missing key 'q' in the param list./);

eval { $buzz->search_activities({q => 'obama', alt => 'atm'}); };
like($@, qr/ERROR: Invalid value for key 'alt': \[atm\]/);

eval { $buzz->search_activities({q => 'obama', alt => 'atom', prettyprint => 'trrue'}); };
like($@, qr/ERROR: Invalid value for key 'prettyprint': \[trrue\]/);

eval { $buzz->search_activities({q => 'obama', lat => 'abc'}); };
like($@, qr/ERROR: Invalid value for key 'lat': \[abc\]/);

eval { $buzz->search_activities({q => 'obama', lat => 37.4220, lon => 'abc'}); };
like($@, qr/ERROR: Invalid value for key 'lon': \[abc\]/);

eval { $buzz->search_activities({q => 'obama', lat => 37.4220, lon => -122.0843, radius => 'abc'}); };
like($@, qr/ERROR: Invalid value for key 'radius': \[abc\]/);

eval { $buzz->search_activities({q => 'obama', bbox => 37.4220}); };
like($@, qr/ERROR: Invalid value for key 'bbox': \[37.422\]/);

eval { $buzz->search_activities({q => 'obama', bbox => '37.4220;-122.0843'}); };
like($@, qr/ERROR: Invalid value for key 'bbox': \[37.4220\;\-122.0843\]/);

eval { $buzz->search_activities({q => 'obama', bbox => '37.4220;-122.0843;-120.123'}); };
like($@, qr/ERROR: Invalid value for key 'bbox': \[37.4220\;\-122.0843\;\-120.123\]/);

eval { $buzz->search_activities({q => 'obama', pid => 'bac?123'}); };
like($@, qr/ERROR: Invalid value for key 'pid': \[bac\?123\]/);