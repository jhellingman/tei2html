# tagBibleRefs.pl -- Tag Bible references appearing in documents.

use strict;
use Roman;      # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

my $tagPattern = "<(.*?)>";

my $romanNumberPattern = "(?:[MmDdCcLlXxVvIi]+)";
my $numberPattern = "(?:[0-9]+)";

my $refPattern = "";


my %books = (

# The Jewish Bible/Old Testament

"Amos"                      => "Amos",
"Am"                        => "Amos",
"1 Chron."                  => "1 Chronicles",
"1 Chr"                     => "1 Chronicles",
"1 Chr."                    => "1 Chronicles",
"2 Chron."                  => "2 Chronicles",
"2 Chr"                     => "2 Chronicles",
"2 Chr."                    => "2 Chronicles",
"Dan."                      => "Daniel",
"Dn"                        => "Daniel",
"Deut."                     => "Deuteronomy",
"Dt"                        => "Deuteronomy",
"Eccles."                   => "Ecclesiastes",
"Eccl"                      => "Ecclesiastes",
"Eccl."                     => "Ecclesiastes",
"Esther"                    => "Esther",
"Est"                       => "Esther",
"Exod."                     => "Exodus",
"Ex"                        => "Exodus",
"Ex."                       => "Exodus",
"Ezek."                     => "Ezekiel",
"Ez."                       => "Ezekiel",
"Ez"                        => "Ezekiel",
"Ezra"                      => "Ezra",
"Ezr"                       => "Ezra",
"Gen."                      => "Genesis",
"Gn"                        => "Genesis",
"Hab."                      => "Habakkuk",
"Hb"                        => "Habakkuk",
"Hag."                      => "Haggai",
"Hg"                        => "Haggai",
"Hosea"                     => "Hosea",
"Hos"                       => "Hosea",
"Isa."                      => "Isaiah",
"Is"                        => "Isaiah",
"Is."                       => "Isaiah",
"Jer."                      => "Jeremiah",
"Jer"                       => "Jeremiah",
"Job"                       => "Job",
"Jb"                        => "Job",
"Joel"                      => "Joel",
"Jl"                        => "Joel",
"Jon."                      => "Jonah",
"Jon"                       => "Jonah",
"Josh."                     => "Joshua",
"Jo"                        => "Joshua",
"Judg."                     => "Judges",
"Jgs"                       => "Judges",
"1 Kings"                   => "1 Kings",
"1 Kgs"                     => "1 Kings",
"2 Kings"                   => "2 Kings",
"2 Kgs"                     => "2 Kings",
"Lam."                      => "Lamentations",
"Lam"                       => "Lamentations",
"Lev."                      => "Leviticus",
"Lv"                        => "Leviticus",
"Mal."                      => "Malachi",
"Mal"                       => "Malachi",
"Mic."                      => "Micah",
"Mi"                        => "Micah",
"Nah."                      => "Nahum",
"Na"                        => "Nahum",
"Neh."                      => "Nehemiah",
"Neh"                       => "Nehemiah",
"Num."                      => "Numbers",
"Nm"                        => "Numbers",
"Obad."                     => "Obadiah",
"Ob"                        => "Obadiah",
"Prov."                     => "Proverbs",
"Prv"                       => "Proverbs",
"Ps."                       => "Psalm",
"Psa."                      => "Psalm",
"Pss."                      => "Psalms",
"Ps"                        => "Psalm",
"Pss"                       => "Psalms",
"Ruth"                      => "Ruth",
"Ru"                        => "Ruth",
"1 Sam."                    => "1 Samuel",
"1 Sm"                      => "1 Samuel",
"2 Sam."                    => "2 Samuel",
"2 Sm"                      => "2 Samuel",
"Song of Sol."              => "Song of Solomon",
"Sg"                        => "Song of Solomon",
"Song of Songs"             => "Song of Solomon",
"Zech."                     => "Zechariah",
"Zec"                       => "Zechariah",
"Zeph."                     => "Zephaniah",
"Zep"                       => "Zephaniah",

# The Apocrypha

"Bar."                      => "Baruch",
"Bar"                       => "Baruch",
"Ecclus."                   => "Ecclesiasticus",
"Sirach"                    => "Ecclesiasticus",
"1 Esd."                    => "1 Esdras",
"2 Esd."                    => "2 Esdras",
"Jth."                      => "Judith",
"Jdt"                       => "Judith",
"1 Macc."                   => "1 Maccabees",
"1 Mc"                      => "1 Maccabees",
"2 Macc."                   => "2 Maccabees",
"2 Mc"                      => "2 Maccabees",
"Pr. of Man."               => "Prayer of Manasses",
"Manasseh"                  => "Prayer of Manasses",
"Sir"                       => "Ecclesiasticus",
"Song of Three Children"    => "Song of the Three Holy Children",
"Sus."                      => "Susanna",
"Tob."                      => "Tobit",
"Tb"                        => "Tobit",
"Ws"                        => "Wisdom of Solomon",
"Wisdom"                    => "Wisdom of Solomon",
"Wisd. of Sol."             => "Wisdom of Solomon",

# The New Testament

"Acts"                      => "Acts of the Apostles",
"Apoc."                     => "Revelation",
"Apocalypse"                => "Revelation",
"Col."                      => "Colossians",
"Col"                       => "Colossians",
"1 Cor."                    => "1 Corinthians",
"1 Cor"                     => "1 Corinthians",
"2 Cor."                    => "2 Corinthians",
"2 Cor"                     => "2 Corinthians",
"Eph."                      => "Ephesians",
"Eph"                       => "Ephesians",
"Gal."                      => "Galatians",
"Gal"                       => "Galatians",
"Heb."                      => "Hebrews",
"Heb"                       => "Hebrews",
"James"                     => "James",
"Jas"                       => "James",
"John"                      => "John",
"Jn"                        => "John",
"1 John"                    => "1 John",
"1 Jn"                      => "1 John",
"2 John"                    => "2 John",
"2 Jn"                      => "2 John",
"3 John"                    => "3 John",
"3 Jn"                      => "3 John",
"Jude"                      => "Jude",
"Luke"                      => "Luke",
"Lk"                        => "Luke",
"Mark"                      => "Mark",
"Mk"                        => "Mark",
"Mat."                      => "Matthew",
"Matt."                     => "Matthew",
"Mt"                        => "Matthew",
"1 Pet."                    => "1 Peter",
"1 Pt"                      => "1 Peter",
"2 Pet."                    => "2 Peter",
"2 Pt"                      => "2 Peter",
"Philem."                   => "Philemon",
"Phlm"                      => "Philemon",
"Phil."                     => "Philippians",
"Phil"                      => "Philippians",
"Rev."                      => "Revelation",
"Rv"                        => "Revelation",
"Rom."                      => "Romans",
"Rom"                       => "Romans",
"1 Thess."                  => "1 Thessalonians",
"1 Thes"                    => "1 Thessalonians",
"1 Thes."                   => "1 Thessalonians",
"2 Thess."                  => "2 Thessalonians",
"2 Thes"                    => "2 Thessalonians",
"2 Thes."                   => "2 Thessalonians",
"1 Tim."                    => "1 Timothy",
"1 Tm"                      => "1 Timothy",
"2 Tim."                    => "2 Timothy",
"2 Tm"                      => "2 Timothy",
"Titus"                     => "Titus",
"Ti"                        => "Titus"
);

my %abbreviations = (

# The Jewish Bible/Old Testament

"amos"                      => "Am",
"am"                        => "Am",
"1 chronicles"              => "1 Chr",
"1 chron."                  => "1 Chr",
"1 chr"                     => "1 Chr",
"1 chr."                    => "1 Chr",
"2 chronicles"              => "2 Chr",
"2 chron."                  => "2 Chr",
"2 chr"                     => "2 Chr",
"2 chr."                    => "2 Chr",
"daniel"                    => "Dn",
"dan."                      => "Dn",
"dn"                        => "Dn",
"deuteronomy"               => "Dt",
"deut."                     => "Dt",
"dt"                        => "Dt",
"ecclesiastes"              => "Eccl",
"eccles."                   => "Eccl",
"eccl"                      => "Eccl",
"eccl."                     => "Eccl",
"esther"                    => "Est",
"est"                       => "Est",
"exodus"                    => "Ex",
"exod."                     => "Ex",
"ex"                        => "Ex",
"ex."                       => "Ex",
"ezekiel"                   => "Ez",
"ezek."                     => "Ez",
"ez"                        => "Ez",
"ezra"                      => "Ezr",
"ezr"                       => "Ezr",
"genesis"                   => "Gn",
"gen."                      => "Gn",
"gn"                        => "Gn",
"habakkuk"                  => "Hb",
"hab."                      => "Hb",
"hb"                        => "Hb",
"haggai"                    => "Hg",
"hag."                      => "Hg",
"hg"                        => "Hg",
"hosea"                     => "Hos",
"hos"                       => "Hos",
"isaiah"                    => "Is",
"isa."                      => "Is",
"is"                        => "Is",
"is."                       => "Is",
"jeremiah"                  => "Jer",
"jer."                      => "Jer",
"jer"                       => "Jer",
"job"                       => "Jb",
"jb"                        => "Jb",
"joel"                      => "Jl",
"jl"                        => "Jl",
"jonah"                     => "Jon",
"jon."                      => "Jon",
"jon"                       => "Jon",
"joshua"                    => "Jo",
"josh."                     => "Jo",
"jo"                        => "Jo",
"judges"                    => "Jgs",
"judg."                     => "Jgs",
"jgs"                       => "Jgs",
"1 kings"                   => "1 Kgs",
"1 kgs"                     => "1 Kgs",
"2 kings"                   => "2 Kgs",
"2 kgs"                     => "2 Kgs",
"lamentations"              => "Lam",
"lam."                      => "Lam",
"lam"                       => "Lam",
"leviticus"                 => "Lv",
"lev."                      => "Lv",
"lv"                        => "Lv",
"malachi"                   => "Mal",
"mal."                      => "Mal",
"mal"                       => "Mal",
"micah"                     => "Mi",
"mic."                      => "Mi",
"mi"                        => "Mi",
"nahum"                     => "Na",
"nah."                      => "Na",
"na"                        => "Na",
"nehemiah"                  => "Neh",
"neh."                      => "Neh",
"neh"                       => "Neh",
"numbers"                   => "Nm",
"num."                      => "Nm",
"nm"                        => "Nm",
"obadiah"                   => "Ob",
"obad."                     => "Ob",
"ob"                        => "Ob",
"proverbs"                  => "Prv",
"prov."                     => "Prv",
"prv"                       => "Prv",
"psalm"                     => "Ps",
"ps."                       => "Ps",
"psa."                      => "Ps",
"psalms"                    => "Ps",
"pss."                      => "Ps",
"ps"                        => "Ps",
"pss"                       => "Ps",
"ruth"                      => "Ru",
"ru"                        => "Ru",
"1 samuel"                  => "1 Sm",
"1 sam."                    => "1 Sm",
"1 sm"                      => "1 Sm",
"2 samuel"                  => "2 Sm",
"2 sam."                    => "2 Sm",
"2 sm"                      => "2 Sm",
"song of solomon"           => "Sg",
"song of sol."              => "Sg",
"sg"                        => "Sg",
"song of songs"             => "Sg",
"zechariah"                 => "Zec",
"zech."                     => "Zec",
"zec"                       => "Zec",
"zephaniah"                 => "Zep",
"zeph."                     => "Zep",
"zep"                       => "Zep",

# The Apocrypha

"baruch"                    => "Bar",
"bar."                      => "Bar",
"bar"                       => "Bar",
"ecclesiasticus"            => "Sir",
"ecclus."                   => "Sir",
"sirach"                    => "Sir",
"1 esdras"                  => "1 Esd",
"1 esd."                    => "1 Esd",
"2 esdras"                  => "2 Esd",
"2 esd."                    => "2 Esd",
"judith"                    => "Jdt",
"jth."                      => "Jdt",
"jdt"                       => "Jdt",
"1 maccabees"               => "1 Mc",
"1 macc."                   => "1 Mc",
"1 mc"                      => "1 Mc",
"2 maccabees"               => "2 Mc",
"2 macc."                   => "2 Mc",
"2 mc"                      => "2 Mc",
"prayer of manasses"        => "Manasseh",
"pr. of man."               => "Manasseh",
"manasseh"                  => "Manasseh",
"sir"                       => "Sir",
"song of the three holy children" => "Song of the Three Children",
"song of three children"    => "Song of the Three Children",
"susanna"                   => "Sus",
"sus."                      => "Sus",
"tobit"                     => "Tb",
"tob."                      => "Tb",
"tb"                        => "Tb",
"wisdom of solomon"         => "Ws",
"ws"                        => "Ws",
"wisdom"                    => "Ws",
"wisd. of sol."             => "Ws",

# The New Testament

"acts of the apostles"      => "Acts",
"acts"                      => "Acts",
"revelation"                => "Rev",
"apoc."                     => "Rev",
"apocalypse"                => "Rev",
"colossians"                => "Col",
"col."                      => "Col",
"col"                       => "Col",
"1 corinthians"             => "1 Cor",
"1 cor."                    => "1 Cor",
"1 cor"                     => "1 Cor",
"2 corinthians"             => "2 Cor",
"2 cor."                    => "2 Cor",
"2 cor"                     => "2 Cor",
"ephesians"                 => "Eph",
"eph."                      => "Eph",
"eph"                       => "Eph",
"galatians"                 => "Gal",
"gal."                      => "Gal",
"gal"                       => "Gal",
"hebrews"                   => "Heb",
"heb."                      => "Heb",
"heb"                       => "Heb",
"james"                     => "Jas",
"jas"                       => "Jas",
"john"                      => "Jn",
"jn"                        => "Jn",
"1 john"                    => "1 Jn",
"1 jn"                      => "1 Jn",
"2 john"                    => "2 Jn",
"2 jn"                      => "2 Jn",
"3 john"                    => "3 Jn",
"3 jn"                      => "3 Jn",
"jude"                      => "Jude",
"luke"                      => "Lk",
"lk"                        => "Lk",
"mark"                      => "Mk",
"mk"                        => "Mk",
"matthew"                   => "Mt",
"matt."                     => "Mt",
"mat."                      => "Mt",
"mt"                        => "Mt",
"1 peter"                   => "1 Pt",
"1 pet."                    => "1 Pt",
"1 pt"                      => "1 Pt",
"2 peter"                   => "2 Pt",
"2 pet."                    => "2 Pt",
"2 pt"                      => "2 Pt",
"philemon"                  => "Phlm",
"philem."                   => "Phlm",
"phlm"                      => "Phlm",
"philippians"               => "Phil",
"phil."                     => "Phil",
"phil"                      => "Phil",
"rev."                      => "Rev",
"rv"                        => "Rev",
"romans"                    => "Rom",
"rom."                      => "Rom",
"rom"                       => "Rom",
"1 thessalonians"           => "1 Thes",
"1 thess."                  => "1 Thes",
"1 thes"                    => "1 Thes",
"1 thes."                   => "1 Thes",
"2 thessalonians"           => "2 Thes",
"2 thess."                  => "2 Thes",
"2 thes"                    => "2 Thes",
"2 thes."                   => "2 Thes",
"1 timothy"                 => "1 Tm",
"1 tim."                    => "1 Tm",
"1 tm"                      => "1 Tm",
"2 timothy"                 => "2 Tm",
"2 tim."                    => "2 Tm",
"2 tm"                      => "2 Tm",
"titus"                     => "Ti",
"ti"                        => "Ti"
);

# http://www.beneiavraham.com/many-chapters-book-bible/

my %chapterCounts = (
"gn"    => 50,
"ex"    => 40,
"lv"    => 27,
"nm"    => 36,
"dt"    => 34,
"jo"    => 24,
"jd"    => 21,
"ru"    => 4,
"1 sm"  => 31,
"2 sm"  => 24,
"1 kgs" => 22,
"2 kgs" => 25,
"1 chr" => 29,
"2 chr" => 36,
"ezr"   => 10,
"neh"   => 13,
"est"   => 10,
"jb"    => 42,
"ps"    => 150,
"prv"   => 31,
"eccl"  => 12,
"sg"    => 8,
"is"    => 66,
"jer"   => 52,
"lam"   => 5,
"ez"    => 48,
"dn"    => 12,
"hos"   => 14,
"jl"    => 3,
"am"    => 9,
"ob"    => 1,
"jon"   => 4,
"mi"    => 7,
"na"    => 3,
"hb"    => 3,
"zep"   => 3,
"hg"    => 2,
"zec"   => 14,
"mal"   => 4,

"mt"    => 28,
"mk"    => 16,
"lk"    => 24,
"jn"    => 21,
"acts"  => 28,
"rom"   => 16,
"1 cor" => 16,
"2 cor" => 13,
"gal"   => 6,
"eph"   => 6,
"phil"  => 4,
"col"   => 4,
"1 thes" => 5,
"2 thes" => 3,
"1 tm"  => 6,
"2 tm"  => 4,
"ti"    => 3,
"phlm"  => 1,
"heb"   => 13,
"jas"   => 5,
"1 pt"  => 5,
"2 pt"  => 3,
"1 jn"  => 5,
"2 jn"  => 1,
"3 jn"  => 1,
"jude"  => 1,
"re"    => 22
);



buildRegularExpression();

main();



sub buildRegularExpression() {
    my @listBooks = ();
    foreach my $book (keys %books) {
        push (@listBooks, $book);
        push (@listBooks, $books{$book});
    }
    my @sortedBooks = uniq(sort(@listBooks));

    my $booksPattern = "";
    for (my $i = 0; $i < $#sortedBooks; $i++) {
        my $book = $sortedBooks[$i];
        if ($i > 0) {
            $booksPattern .= "|";
        }
        $booksPattern .= "(?:$book)";
    }

    $booksPattern =~ s/\./\\./g;
    # $booksPattern =~ s/ /\\s+/g;

    $refPattern = "\\b($booksPattern),? ($romanNumberPattern|$numberPattern) ?[,.:]? ?(?:($numberPattern)?(?:(?:&ndash;|-)($numberPattern))?)\\b";

    # print STDERR "PATTERN: $refPattern\n";
}


sub uniq {
    my @list = @_;
    my %seen = ();
    my @result = ();
    foreach my $item (@list) {
        unless ($seen{$item}) {
            push @result, $item;
            $seen{$item} = 1;
        }
    }
    return @result;
}


# test();

sub test {
    print "TESTING...\n\n";
    print tagRefs("See Gen. xxvi 23 for this and Exod. 12 : 4 for that\n");
}


sub main() {
    my $file = $ARGV[0];
    open(INPUTFILE, $file) || die("Could not open input file $file");

    while (<INPUTFILE>) {
        my $remainder = $_;
        while ($remainder =~ m/$tagPattern/) {
            my $fragment = $`;
            my $tag = $&;
            $remainder = $';
            print tagRefs($fragment);
            print $tag;
        }
        print tagRefs($remainder);
    }

    close INPUTFILE;
}


sub tagRefs($) {
    my $remainder = shift;

    my $result = "";
    while ($remainder =~ m/$refPattern/) {
        my $before = $`;
        my $match = $&;
        my $book = $1;
        my $chapter = $2;
        my $verse = $3;
        my $range = $4;
        $remainder = $';

        $result .= $before;
        $result .= tagRef($match, $book, $chapter, $verse, $range);
    }
    $result .= $remainder;

    return $result;
}


sub tagRef {
    my $match = shift;
    my $book = shift;
    my $chapter = shift;
    my $verse = shift;
    my $range = shift;

    # print STDERR "MATCH: $match\n";
    # print STDERR "BOOK: $book CHAPTER: $chapter VERSE: $verse\n";

    if (isroman($chapter)) {
        $chapter = arabic($chapter);
    }

    if ($abbreviations{lc $book}) {
        $book = $abbreviations{lc $book}
    }

    # Books with just a single chapter (ob, phlm, 2 jn, 3 jn, jude) omit the chapter number.
    if (exists $chapterCounts{lc $book} && $chapter > $chapterCounts{lc $book} && $chapterCounts{lc $book} != 1) {
        print STDERR "WARNING: No chapter $chapter in $book for [$match] ($book has " . $chapterCounts{lc $book} . " chapters)\n";
        return $match;
    }
    if (!exists $chapterCounts{lc $book} && $chapter > 25) {
        print STDERR "WARNING: Large chapter number in match '$match' (book: '$book', chapter: $chapter)\n";
        return $match;
    }

    if ($book ne "") {
        if ($verse == 0) {
            # print STDERR "DEBUG: $match => $book $chapter\n";
            return "<xref url=\"bib:$book $chapter\">$match</xref>";
        }
        if ($range == 0) {
            # print STDERR "DEBUG: $match => $book $chapter:$verse\n";
            return "<xref url=\"bib:$book $chapter:$verse\">$match</xref>";
        }
        # print STDERR "DEBUG: $match => $book $chapter:$verse-$range\n";
        return "<xref url=\"bib:$book $chapter:$verse-$range\">$match</xref>";
    }
    return $match;
}
