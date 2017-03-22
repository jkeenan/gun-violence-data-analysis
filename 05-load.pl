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

When we ran 04-load.pl, we got this result.

    Agency: Aurora Police Dept
      { city => "Aurora", state => "Colorado" }
      { city => "Aurora", state => "Illinois" }
    Agency: Columbia Police Dept
      { city => "Columbia", state => "South Carolina" }
      { city => "Columbia", state => "Missouri" }
    Agency: Columbus Police Dept
      { city => "Columbus", state => "Ohio" }
      { city => "Columbus", state => "Georgia" }
    Agency: Glendale Police Dept
      { city => "Glendale", state => "Arizona" }
      { city => "Glendale", state => "California" }
    Agency: Honolulu Police Dept
      { city => "Honolulu", state => "Hawaii" }
      { city => "Honolulu", state => "Hawaii" }
    Agency: Kansas City Police Dept
      { city => "Kansas City", state => "Missouri" }
      { city => "Kansas City", state => "Kansas" }
    Agency: Pasadena Police Dept
      { city => "Pasadena", state => "Texas" }
      { city => "Pasadena", state => "California" }
    Agency: Peoria Police Dept
      { city => "Peoria", state => "Arizona" }
      { city => "Peoria", state => "Illinois" }
    Agency: Rochester Police Dept
      { city => "Rochester", state => "New York" }
      { city => "Rochester", state => "Minnesota" }
    Agency: Springfield Police Dept
      { city => "Springfield", state => "Missouri" }
      { city => "Springfield", state => "Massachusetts" }
      { city => "Springfield", state => "Illinois" }

So there are cases (10 out of 11) where we have the same agency name for
agencies in identically named cities in different states.  That suggests that,
rather than keying on 'Agency', we should key on a combination of 'city' and
'state'.

That leaves 1 case, Honolulu Police Dept, where there are 2 rows.  Manual
inspection shows that the two rows are not in fact identical, but that the
second entry seems to be more complete than the first.

    Honolulu Police Dept,Honolulu,Hawaii,HI,36,46,36,28,,34,29,31,31,35,38,27,34,17,37,20,20,18,15,26,15,17,19,18,14,19,,,,,15,4.4,5.6,4.3,3.3,,4.1,3.4,3.5,3.5,4,4.3,3.1,3.9,1.9,4.3,2.3,2.3,2,1.7,2.9,1.7,1.9,2.1,2,1.5,2,,,,,1.50900271

    Honolulu Police Dept,Honolulu,Hawaii,HI,36,46,36,28,,34,29,31,31,35,38,27,34,17,37,20,20,18,15,26,15,17,19,18,14,19,14,11,18,,15,4.4,5.6,4.3,3.3,,4.1,3.4,3.5,3.5,4,4.3,3.1,3.9,1.9,4.3,2.3,2.3,2,1.7,2.9,1.7,1.9,2.1,2,1.5,2,,,,,1.50900271

We should report this to the data provider, but in the meantime, for the sake
of expedience, we'll simply have the second entry overwrite the first.

=cut

open my $IN, '<', $file or croak "Unable to open $file";
my $header = $csv->getline( $IN );
$csv->column_names(@{$header});

my %data;
my %overwritten_data;
while ( my $rowdata = $csv->getline_hr( $IN ) ) {
    my $key = join('|' => ($rowdata->{city}, $rowdata->{state_short}));
    $overwritten_data{$key} = delete $data{$key}
        if (exists $data{$key});
    $data{$key} = $rowdata;
}
$csv->eof or $csv->error_diag();

say scalar(keys %data), " rows extracted from $base";
say scalar(keys %overwritten_data), " rows rejected from $base";
dd(\%data, \%overwritten_data);

