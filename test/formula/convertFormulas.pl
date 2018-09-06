
main();

sub main() {
    my $file = $ARGV[0];

    open(INPUTFILE, $file) || die("Could not open input file $file");

    my $formula = "";
    while (<INPUTFILE>) {
        $formula .= $_;
    }

    print  ("tex2svg \"$formula\" > out.svg");
    system ("tex2svg \"$formula\" > out.svg");

    system ("tex2htmlcss \"$formula\" > out.html");
}
