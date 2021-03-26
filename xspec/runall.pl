
my @files = glob( '*.xspec' );

foreach my $file (@files) {
    print $file . "\n";
    system "xspec -c $file";
}