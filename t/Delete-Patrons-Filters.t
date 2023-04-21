#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;
use Delete::Patrons::Filters;
use Koha::Patrons;

use_ok 'Delete::Patrons::Filters';

my $patron_with_notes = Koha::Patrons->search({"borrowernotes" => {"!=" => ""}})->next();
my $patron_without_notes = Koha::Patrons->search({"borrowernotes" => {"=" => ""}})->next();

is (dp_filter("POUAITE", 0, "None digit should return 0"));
is (dp_filter(2), 0, "Deleted Patrons should return 0"));
is (dp_filter($patron_with_notes), 1, "Patrons with notes should return 1"));
is (dp_filter($patron_without_notes), 0, "Patrons without notes should return 0"));
