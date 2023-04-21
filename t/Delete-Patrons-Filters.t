#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 5;
use Delete::Patrons::Filters qw(dp_filter);
use Koha::Patrons;


my $non_existent_patron;
my $non_existent_patron_id = 1;
while (1) {
    $non_existent_patron = Koha::Patrons->find($non_existent_patron_id);
    $non_existent_patron_id++;
    (defined $non_existent_patron) ? next : last;
}
my $patron_with_notes = Koha::Patrons->search({"borrowernotes" => {"!=" => ""}})->next();
my $patron_without_notes = Koha::Patrons->search({"borrowernotes" => {"=" => ""}})->next();


use_ok 'Delete::Patrons::Filters';
is (dp_filter("POUAITE"), 0, "None digit should return 0");
is (dp_filter($non_existent_patron_id), 0, "Deleted Patrons should return 0");
is (dp_filter($patron_with_notes->borrowernumber()), 1, $patron_with_notes->borrowernumber() . "Patrons with notes should return 1");
is (dp_filter($patron_without_notes->borrowernumber()), 0, "Patrons without notes should return 0");
