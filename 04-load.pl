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

When we ran 03-load.pl, we got this result.

Agency                     Entries

Aurora Police Dept               2
Columbia Police Dept             2
Columbus Police Dept             2
Glendale Police Dept             2
Honolulu Police Dept             2
Kansas City Police Dept          2
Pasadena Police Dept             2
Peoria Police Dept               2
Rochester Police Dept            2
Springfield Police Dept          3

Are some of our rows duplicates?  Or is there, perhaps, more than one entry
for an agency named, say, "Columbia Police Dept"?

=cut

open my $IN, '<', $file or croak "Unable to open $file";
my $header = $csv->getline( $IN );
$csv->column_names(@{$header});

my $key = 'Agency';
my %agencies;
while ( my $rowdata = $csv->getline_hr( $IN ) ) {
    push @{$agencies{$rowdata->{$key}}},
        { map { $_ => $rowdata->{$_} } grep { $_ ne $key } keys %{$rowdata} };
}
$csv->eof or $csv->error_diag();

for my $name (sort keys %agencies) {
    if (scalar @{$agencies{$name}} > 1) {
        say "Agency: $name";
        for my $agency (@{$agencies{$name}}) {
            dd( { map { $_ => $agency->{$_} } (qw| city state |)} );
        }
    }
}
