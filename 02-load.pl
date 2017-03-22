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

Let's assume that the entries in the first column, 'Agency' are unique.  If so,
then we can populate a hash where 'Agency' will be the key and the value will
be a reference to a hash with all the other columns.

=cut

open my $IN, '<', $file or croak "Unable to open $file";
my $header = $csv->getline( $IN );
$csv->column_names(@{$header});

my $key = 'Agency';
my %data;
while ( my $rowdata = $csv->getline_hr( $IN ) ) {
    $data{$rowdata->{$key}} = { map { $_ => $rowdata->{$_} } grep { $_ ne $key } keys %{$rowdata} };
}
$csv->eof or $csv->error_diag();

say scalar(keys %data), " rows extracted from $base";
dd(\%data);
