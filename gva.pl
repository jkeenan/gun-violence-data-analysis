# perl
use strict;
use warnings;
use Data::Dumper;$Data::Dumper::Indent=1;
use Cwd;
use Text::CSV;

=pod

tract_fips,num_killed,num_incidents,city_or_county,state,tract_square_mileage,2014_tract_population,2014_tract_population_black,2014_tract_population_over_age_25_with_no_hs_degree,2014_tract_population_below_poverty_line,,,,,,,,,,,
48201100000,21(a),17(a),Houston,Texas,1.47,"4,178",14.22%,13.37%,12.78%,,,,,,,,,,,3.33%
6071007200,16,1,San Bernardino,California,3.63,"7,196",2.58%,30.77%,36.48%,,,,,,,,,,,

=cut

my $sourcedir = cwd();
my $inputsdir = "$sourcedir/inputs";
my $tractfile = 'gva_release_2015_grouped_by_tract.csv';
my $f = "$inputsdir/$tractfile";

my @rows;
my $csv = Text::CSV->new ( { binary => 1 } )
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
 
open my $IN, '<', $f or die "Unable to open $f: $!";
while ( my $row = $csv->getline( $IN ) ) {
    my @thisrow = @{$row}[0..9];
    for my $idx ( 1, 2 ) {
        $thisrow[$idx] =~ s/^(.*)\(.\)$/$1/;
    }
    push @rows, \@thisrow;
 }
$csv->eof or $csv->error_diag();
close $IN;

print Dumper(\@rows);
