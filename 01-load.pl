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

my $base = shift(@ARGV);
my $file = "$inputsdir/$base";
croak "Could not locate $file" unless -f $file;

my $csv = Text::CSV->new ( { binary => 1 } )
    or croak "Cannot use CSV: ". Text::CSV->error_diag ();
 
open my $IN, '<', $file or croak "Unable to open $file";
my @rows;
while ( my $r = $csv->getline( $IN ) ) {
    push @rows, $r;
 }
$csv->eof or $csv->error_diag();
close $IN or croak "Unable to close $file after reading";

say scalar(@rows) - 1, " rows in $base (excluding header row)";
dd(\@rows);
