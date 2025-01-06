# handleFootnotes.pl

use strict;
use warnings;
use Data::Dumper;
use SgmlSupport qw/getAttrVal/;

main();

my $pageNumber = 0;

sub main {

    my $page = '';

    while (<>) {
        my $line = $_;
        $page .= $line;
        if ($line =~ /<pb\b(.*?)>/) {
            $pageNumber = getAttrVal('n', $1);
            handlePage($page);
            $page = '';
        }
    }
    handlePage($page);
}


sub handlePage {
    my $page = shift;
    my @matches = $page =~ /\[Footnote ([0-9]+|[A-Z]): (.*?)\]\n/smg;

    my $iterator = natatime(2, @matches);
    while (my @footnote = $iterator->()) {

        my $number = $footnote[0];
        my $note = $footnote[1];

        # print "[Footnote: $number: $note]\n";

        $page = moveNoteInline($page, $number, $note);
    }

    print $page;
}


sub moveNoteInline {
    my $page = shift;
    my $number = shift;
    my $note = shift;

    if ($page =~ /<note n=$number><\/note>/) {
        $page =~ s/<note n=$number><\/note>/<note n=$number>$note<\/note>/;

        $page =~ s/\[Footnote $number: (.*?)\]\n/\n/smg

    } else {
        print STDERR "Note $number not found on page $pageNumber.\n";
    }

    return $page;
}


sub natatime {
    my $n = shift;
    my @list = @_;

    return sub {
        return splice @list, 0, $n;
    }
}
