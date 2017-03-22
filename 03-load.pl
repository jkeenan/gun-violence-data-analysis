# perl
use strict;
use warnings;
use 5.10.1;
use Data::Dump qw( dd );
use Carp;
use Cwd;
use Text::CSV;

my $cwd = cwd();
my $inputsdir = "$cwd/inputs";

# Supply name of file in 'inputs' directory on command-line

my $base = 'UCR-1985-2015.csv';
my $file = "$inputsdir/$base";
croak "Could not locate $file" unless -f $file;

my $csv = Text::CSV->new ( { binary => 1 } )
    or croak "Cannot use CSV: ". Text::CSV->error_diag ();
 
=pod

When we built a hash out of the CSV data keyed on 'Agency' we got 11 fewer
elements than expected.  That's probably because in the CSV file there is
more than one row with the same value for 'Agency'.  Let's see if that is
the case.

=cut

open my $IN, '<', $file or croak "Unable to open $file";
my %agencies;
while ( my $r = $csv->getline( $IN ) ) {
    $agencies{$r->[0]}++;
 }
$csv->eof or $csv->error_diag();
close $IN or croak "Unable to close $file after reading";

say scalar(keys %agencies), " distinct agencies found in $base";
say '';
printf "%-20s%14s\n" => ('Agency', 'Entries');
say '';
for my $k (sort keys %agencies) {
    printf "%-30s%4d\n" => ($k, $agencies{$k})
        if $agencies{$k} > 1;
}
