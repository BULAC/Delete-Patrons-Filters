use Modern::Perl;
use Koha::Patrons;
use Koha::Patron::Messages;
package Delete::Patrons::Filters;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw( dp_filter );

our $VERSION = '0.001';

sub dp_filter {
    my $borrowernumber = shift;

    if ($borrowernumber !~ /^[0-9]+$/) {
        warn "borrowernumber: '$borrowernumber' should be a digit";
        return 0;
    }
    my $patron = Koha::Patrons->find($borrowernumber);
    if (! defined $patron) {
        warn "borrowernumber: '$borrowernumber' is not in Koha";
        return 0;
    }

    # Keep borrowers with notes
    if ($patron->borrowernotes() ne "") {
        say "FILTER: Patron $borrowernumber has notes: " . $patron->borrowernotes();
        return 1;
    }

    # Keep borrowers with messages
    my $messages = Koha::Patron::Messages->search({ borrowernumber => $borrowernumber })->unblessed();
    if ($#$messages >= 0) {
        say "FILTER: Patron $borrowernumber has messages: ";
        for my $message (@$messages) {
            say '    - ' . $message->{'message'} . ', ' . $message->{'message_date'};
        }
        return 1;
    }

    # Keep borrowers with public virtualshelves
    my $shelves = Koha::Virtualshelves->search( { owner => $borrowernumber } )->unblessed;
    my $public_shelves = [];
    for my $shelf (@$shelves) {
        if ($shelf->{'public'} == 1) {
            push @$public_shelves, $shelf;
        }
    }
    if ($#$public_shelves >= 0) {
        say "FILTER: Patron $borrowernumber has at least one public list: ";
        for my $shelf (@$public_shelves) {
            say '    - ' . $shelf->{'shelfnumber'} . ', ' . $shelf->{'shelfname'};
        }
        return 1
    }
    return 0
}

1;

__END__

=head1 NAME

Delete::Patrons::Filters - add some filters to the Koha
delete_patrons.pl script.

=head1 SYNOPSIS

  use Delete::Patrons::Filters;

  for my $borrower (@borrowers) {
    next if (dp_filter($borrower));
    # code to delete patron below
    ...
  }

=head1 DESCRIPTION

Delete::Patrons::Filters add some filters to home made Koha
delete_patrons.pl scripts. Those filters are mainly designed to be
used in the Bulac library. It’s very hardcodish.

=head1 EXPORTS

The following are exported:

=item dp_filter

The filter takes a $borrowernumber as parameter, it then checks if
this borrower has internal notes, messages. If yes he is excluded from
deletion, if no, he can be deleted.


=head1 LICENSE

Copyright (C) 2023 Nicolas Legrand.
