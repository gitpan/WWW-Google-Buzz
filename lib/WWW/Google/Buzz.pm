package WWW::Google::Buzz;

use strict; use warnings;

use Carp;
use Readonly;
use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request::Common;
use URI::Escape q/uri_escape/;

=head1 NAME

WWW::Google::Buzz - Interface to Google Buzz API.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';
Readonly my $API_VERSION => 'v1';
Readonly my $BASE_URL    => "https://www.googleapis.com/buzz/$API_VERSION/activities";

=head1 DESCRIPTION

This module is  intended for anyone who wants to write applications that can interact with the
Google  Buzz  API.  Google  Buzz  is  a tool for sharing updates, photos, videos and more, and
participating in conversations about things which is interesting.This can be used to create to
search activities & public activities of any Google Buzz user programmatically.However I would
be adding the ability to create, update and add  comment  very soon. Courtesy limit is 1000000
queries per day. Currently it supports version v1.

IMPORTANT:  The  version  v1  of the Google Buzz API is in Labs, and its features might change
unexpectedly until it graduates.

=head1 CONSTRUCTOR

The constructor expects your application API, which you can get it for FREE from Google.

    use strict; use warnings;
    use WWW::Google::Buzz;

    my $api_key = 'Your_API_Key';
    my $buzz    = WWW::Google::Buzz->new($api_key);

=cut

sub new
{
    my $class   = shift;
    my $api_key = shift;
    croak("ERROR: API Key is missing.\n")
        unless defined $api_key;

    my $self = { api_key => $api_key,
                 browser => LWP::UserAgent->new()
               };
    bless $self, $class;
    return $self;
}

=head1 METHODS

=head2 search_activities()

Search activies using the given query string. This method accepts the following parameters as
mentioned in the below table. The key 'q' is mandatory.

    +----------------+-----------------------------------------------+------------+---------+
    | Key            | Description                                   | Values     | Default |
    +----------------+-----------------------------------------------+------------+---------+
    | alt            | Specifies an alternative representation type. | atom/json  | atom    |
    | prettyprint    | If true,the response will include indentations| true/false | false   |
    |                | and line breaks to make it human readable.    |            |         |
    | q              | Specifies a full-text query string.           |            |         |
    | lon,lat,radius | Specifies geographical location by lon, lat   |            |         |
    |                | and radius.                                   |            |         |
    | bbox           | Accepts two pairs of geographic coordinates   |            |         |
    |                | which identify the southwest and northeast    |            |         |
    |                | corners of the rectangular bounding region    |            |         |
    |                | and takes the form lon1,lat1,lon2,lat2.       |            |         |
    | pid            | Takes the reference value for a place, as     |            |         |
    |                | provided by the Places Web Service.           |            |         |
    +----------------+-----------------------------------------------+------------+---------+

    use strict; use warnings;
    use WWW::Google::Buzz;

    my $api_key = 'Your_API_Key';
    my $buzz    = WWW::Google::Buzz->new($api_key);
    print $buzz->search_activities({q => 'London', prettyprint=>'true'});

=cut

sub search_activities
{
    my $self  = shift;
    my $param = shift;

    _validate_param($param);

    croak("ERROR: Missing key 'q' in the param list.")
        unless exists($param->{q});

    _validate_alt($param->{alt});
    _validate_prettyprint($param->{prettyprint});
    _validate_number('lon', $param->{lon});
    _validate_number('lat', $param->{lat});
    _validate_number('radius', $param->{radius});

    if (defined($param->{bbox}))
    {
        my @bbox = split /\,/,$param->{bbox};
        croak("ERROR: Invalid value for key 'bbox': [".$param->{bbox}."]\n")
            if (scalar(@bbox) != 4);
        foreach (@bbox)
        {
            _validate_number('bbox', $_);
        }
    }

    croak("ERROR: Invalid value for key 'pid': [".$param->{pid}."]\n")
        if (defined($param->{pid}) && ($param->{pid} !~ /^[A-Za-z0-9]+$/));

    my $url = sprintf("%s/search?key=%s", $BASE_URL, $self->{api_key});
    $url .= sprintf("&q=%s", uri_escape($param->{q}));
    $url .= sprintf("&alt=%s", $param->{alt}) if exists($param->{alt});
    $url .= sprintf("&prettyprint=%s", $param->{prettyprint}) if exists($param->{prettyprint});
    $url .= sprintf("&lon=%s", $param->{lon}) if exists($param->{lon});
    $url .= sprintf("&lat=%s", $param->{lat}) if exists($param->{lat});
    $url .= sprintf("&radius=%s", $param->{radius}) if exists($param->{radius});
    $url .= sprintf("&bbox=%s", $param->{bbox}) if exists($param->{bbox});
    $url .= sprintf("&pid=%s", $param->{pid}) if exists($param->{pid});

    my $request  = HTTP::Request->new(GET => $url);
    my $response = $self->{browser}->request($request);
    croak("ERROR: Could not connect to $url [".$response->status_line."].\n")
        unless $response->is_success;

    return $response->content;
}

=head2 get_public_activities()

Search public activies for the given userId.  This  method accepts the following parameters as
mentioned in the below table. The key 'user_id' is mandatory.

    +----------------+-----------------------------------------------+------------+---------+
    | Key            | Description                                   | Values     | Default |
    +----------------+-----------------------------------------------+------------+---------+
    | user_id        | userId of the owner of activities.            | googlebuzz |         |
    | alt            | Specifies an alternative representation type. | atom/json  | atom    |
    | prettyprint    | If true,the response will include indentations| true/false | false   |
    |                | and line breaks to make it human readable.    |            |         |
    +----------------+-----------------------------------------------+------------+---------+

    use strict; use warnings;
    use WWW::Google::Buzz;

    my $api_key = 'Your_API_Key';
    my $buzz    = WWW::Google::Buzz->new($api_key);
    print $buzz->get_public_activities({user_id => 'googlebuzz', prettyprint=>'true'});

=cut

sub get_public_activities
{
    my $self  = shift;
    my $param = shift;

    _validate_param($param);

    croak("ERROR: Missing key 'user_id' in the param list.")
        unless exists($param->{user_id});

    _validate_alt($param->{alt});
    _validate_prettyprint($param->{prettyprint});

    my $url = sprintf("%s/%s/\@public?key=%s", $BASE_URL, $param->{user_id}, $self->{api_key});
    $url .= sprintf("&alt=%s", $param->{alt}) if exists($param->{alt});
    $url .= sprintf("&prettyprint=%s", $param->{prettyprint}) if exists($param->{prettyprint});
    my $request  = HTTP::Request->new(GET => $url);
    my $response = $self->{browser}->request($request);
    croak("ERROR: Could not connect to $url [".$response->status_line."].\n")
        unless $response->is_success;

    return $response->content;
}

sub _validate_param
{
    my $param = shift;
    croak("ERROR: Missing input parameters.\n")
        unless defined $param;
    croak("ERROR: Input param has to be a ref to HASH.\n")
        if (ref($param) ne 'HASH');
}

sub _validate_alt
{
    my $alt = shift;
    croak("ERROR: Invalid value for key 'alt': [$alt]\n")
        if (defined($alt) && ($alt !~ /\batom\b|\bjson\b/i));
}

sub _validate_prettyprint
{
    my $prettyprint = shift;
    croak("ERROR: Invalid value for key 'prettyprint': [$prettyprint]\n")
        if (defined($prettyprint) && ($prettyprint !~ /\btrue\b|\bfalse\b/i));
}

sub _validate_number
{
    my $key   = shift;
    my $value = shift;
    croak("ERROR: Invalid value for key '$key': [$value].\n")
        if (defined($value) && ($value !~ /-?\d+\.?\d+?/));
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-google-buzz at rt.cpan.org> or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-Buzz>. I will
be notified & then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::Buzz

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-Buzz>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-Buzz>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-Buzz>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-Buzz/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

By using the Google Buzz API, you agree to  the  Google Buzz API Terms of Service and agree to
abide by the Google Buzz Developer Policies.

=over 2

=item * L<http://code.google.com/apis/buzz/terms.html>

=item * L<http://code.google.com/apis/buzz/policies.html>

=back

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of WWW::Google::Buzz