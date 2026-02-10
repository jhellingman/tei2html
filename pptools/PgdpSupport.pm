# PgdpSupport.pm -- package to support PGDP notation for special characters.

package PgdpSupport;

use strict;         
use warnings;

use base 'Exporter';

use Unicode::Normalize;
use HTML::Entities;

our $VERSION = '1.00';
our @ISA = qw(Exporter);
our @EXPORT = qw(pgdp2sgml handlePgdpAccents);


#
# Handle special letters in the coding system as used on PGDP.
#
sub pgdp2sgml {
    my $string = shift;
    my $useExtensions = shift;

    # Extensions used for FRANCK
    if ($useExtensions == 1) {
        $string =~ s/\[\x{00b0}([a-zA-Z])\]/\&$1ring;/g;    # ring (FRANCK: using degree sign)

        $string =~ s/\[o\)\]/\&oogon;/g;                    # FRANCK: o with ogonek (NON-STANDARD!)
        $string =~ s/\[O\)\]/\&Oogon;/g;                    # FRANCK: O with ogonek (NON-STANDARD!)
        $string =~ s/\[o,\]/\&oogon;/g;                     # FRANCK: o with ogonek (NON-STANDARD!)
        $string =~ s/\[O,\]/\&Oogon;/g;                     # FRANCK: O with ogonek (NON-STANDARD!)
        $string =~ s/\[a,\]/\&aogon;/g;                     # FRANCK: a with ogonek (NON-STANDARD!)
        $string =~ s/\[A,\]/\&Aogon;/g;                     # FRANCK: A with ogonek (NON-STANDARD!)
        $string =~ s/\[e,\]/\&eogon;/g;                     # FRANCK: e with ogonek (NON-STANDARD!)
        $string =~ s/\[E,\]/\&Eogon;/g;                     # FRANCK: E with ogonek (NON-STANDARD!)

        $string =~ s/\[\^o,\]/\&oogoncirc;/g;               # FRANCK: o with ogonek and circumflex (NON-STANDARD!)
        $string =~ s/\[\x{00f4},\]/\&oogoncirc;/g;          # FRANCK: o with ogonek and circumflex (NON-STANDARD!)
        $string =~ s/\[\^o\)\]/\&oogoncirc;/g;              # FRANCK: o with ogonek and circumflex (NON-STANDARD!)
        $string =~ s/\[\x{00f4}\)\]/\&oogoncirc;/g;         # FRANCK: o with ogonek and circumflex (NON-STANDARD!)

        $string =~ s/\[\^\x{00f8}\]/\&oslashcirc;/g;        # FRANCK: o-slash with circumflex (NON-STANDARD!)

        $string =~ s/\[\^r\.\]/\&rdotbcirc;/g;              # FRANCK: r with dot below and circumflex

        $string =~ s/\[\@k\]/\&kcirc;/g;                    # k with circumflex (FRANCK: k with flag on tail)

        $string =~ s/\[x\]/\&khgr;/g;                       # FRANCK: Greek chi in Latin context
        $string =~ s/\[e\]/\&schwa;/g;                      # FRANCK: schwa

        # Letters with multiple accents:
        $string =~ s/\[\^\x{00e4}\]/\&aumlcirc;/g;          # a with dieresis and circumflex (FRANCK)
        $string =~ s/\[\^\x{00f6}\]/\&oumlcirc;/g;          # o with dieresis and circumflex (FRANCK)
        $string =~ s/\[\^\x{00fc}\]/\&uumlcirc;/g;          # u with dieresis and circumflex (FRANCK)

        $string =~ s/\[\=\x{00e1}\]/\&amacracu;/g;          # a with macron and acute (FRANCK: inverted order!)
        $string =~ s/\[\=\x{00fa}\]/\&umacracu;/g;          # u with macron and acute (FRANCK: inverted order!)

        $string =~ s/\[\.\x{00e9}\]/\&edotaac;/g;           # e with dot above and acute (FRANCK: actually next to each other!)
        $string =~ s/\[\.\/e\]/\&edotaac;/g;                # e with dot above and acute (FRANCK: actually next to each other!)
        $string =~ s/\[\/\.e\]/\&edotaac;/g;                # e with dot above and acute (FRANCK: actually next to each other!)

        $string =~ s/\[=\x{00f6}\]/\&oumlmacr;/g;           # o with dieresis and macron (FRANCK: actually next to each other!)

        $string =~ s/\[~\.e\]/\&edotatil;/g;                # e with dot above and tilde (FRANCK)
        $string =~ s/\[~\"e\]/\&eumltil;/g;                 # e with dieresis and tilde (FRANCK)
        $string =~ s/\[~\x{00eb}\]/\&eumltil;/g;            # e with diaresis and tilde (FRANCK)

        $string =~ s/\[\*ae\]/\&aering;/g;                  # ae ligature with ring (FRANCK)
        $string =~ s/\[\*\x{00e6}\]/\&aering;/g;            # ae ligature with ring (FRANCK)
        $string =~ s/\[=\x{00e6}\]/\&aemacr;/g;             # ae ligature with macron (FRANCK)


        $string =~ s/\[\*u\]/\&uring;/g;                    # u with ring (FRANCK)
        $string =~ s/\[~\*u\]/\&uringtil;/g;                # u with ring and tilde (FRANCK)
        $string =~ s/\[\*\/u\]/\&uringacu;/g;               # u with ring and acute (FRANCK)
        $string =~ s/\[\x{00b0}\/u\]/\&uringacu;/g;         # u with ring and acute (FRANCK: using degree sign)
        $string =~ s/\[\x{00b0}\x{00fa}\]/\&uringacu;/g;    # u with ring and acute (FRANCK: using degree sign and u acute)

        $string =~ s/\[n,\]/\&eng;/g;                       # BRUGGENCATE: eng
        $string =~ s/\[a\]/\&turna;/g;                      # BRUGGENCATE: turned a
        $string =~ s/\[\^a\]/\&turnacirc;/g;                # BRUGGENCATE: turned a with circumflex
        $string =~ s/\[\x{00e2}\]/\&turnacirc;/g;           # BRUGGENCATE: turned a with circumflex
    }

    # Accents above:
    $string =~ s/\[\/([a-zA-Z])\]/\&$1acute;/g;         # acute
    $string =~ s/\[\'([a-zA-Z])\]/\&$1acute;/g;         # acute
    $string =~ s/\[\x{00b4}([a-zA-Z])\]/\&$1acute;/g;   # acute (wrong encoding!)
    $string =~ s/\[\\([a-zA-Z])\]/\&$1grave;/g;         # grave
    $string =~ s/\[`([a-zA-Z])\]/\&$1grave;/g;          # grave
    $string =~ s/\[\^([a-zA-Z])\]/\&$1circ;/g;          # circumflex
    $string =~ s/\[\"([a-zA-Z])\]/\&$1uml;/g;           # dieresis
    $string =~ s/\[~([a-zA-Z])\]/\&$1tilde;/g;          # tilde
    $string =~ s/\[=([a-zA-Z])\]/\&$1macr;/g;           # macron
    $string =~ s/\[\)([a-zA-Z])\]/\&$1breve;/g;         # breve
    $string =~ s/\[\.([a-zA-Z])\]/\&$1dota;/g;          # dot above
    $string =~ s/\[[>v]([a-zA-Z])\]/\&$1caron;/g;       # caron / hajek

    $string =~ s/\[,([a-zA-Z])\]/\&$1spas;/g;           # spiritus asper (rough breathing)

    # Accents below:
    $string =~ s/\[([a-zA-Z])\.\]/\&$1dotb;/g;          # dot below
    $string =~ s/\[([a-zA-Z])=\]/\&$1barb;/g;           # bar (or macron) below
    $string =~ s/\[([a-zA-Z]),\]/\&$1cedil;/g;          # cedilla
    $string =~ s/\[([a-zA-Z])\)]/\&$1breveb;/g;         # breve below
    $string =~ s/\[([a-zA-Z])\^]/\&$1circb;/g;          # circumflex below
    $string =~ s/\[([a-zA-Z]):]/\&$1umlb;/g;            # umlaut below

    # Multiple accents above and below:
    $string =~ s/\[=([a-zA-Z]):\]/\&$1maumb;/g;         # macron and umlaut below
    $string =~ s/\[\)([a-zA-Z]):\]/\&$1brumb;/g;        # breve and umlaut below
    $string =~ s/\[\'([a-zA-Z]):\]/\&$1acumb;/g;        # acute and umlaut below
    $string =~ s/\[`([a-zA-Z]):\]/\&$1grumb;/g;         # grave and umlaut below
    $string =~ s/\[~([a-zA-Z]):\]/\&$1tiumb;/g;         # tilde and umlaut below

    $string =~ s/\[\'\)([a-zA-Z]):\]/\&$1acbrumb;/g;    # acute, breve and umlaut below

    $string =~ s/\[`([a-zA-Z])\.\]/\&$1gradb;/g;        # grave and dot below
    $string =~ s/\[,([a-zA-Z])\.\]/\&$1sadb;/g;         # spiritus asper and dot below

    # Multiple accents both above:
    $string =~ s/\[`,([a-zA-Z])\]/\&$1grasa;/g;         # grave and spiritus asper (rough breathing)
    $string =~ s/\['\)([a-zA-Z])\]/\&$1breac;/g;        # breve and acute

    # Ligatures
    $string =~ s/\[ae\]/\&aelig;/g;                     # ae ligature
    $string =~ s/\[AE\]/\&AElig;/g;                     # AE ligature
    $string =~ s/\[oe\]/\&oelig;/g;                     # oe ligature
    $string =~ s/\[OE\]/\&OElig;/g;                     # OE ligature

    # Welsh special letters
    $string =~ s/\[ll\]/\&lllig;/g;                     # ll ligature (Welsh)
    $string =~ s/\[Ll\]/\&Lllig;/g;                     # Ll ligature (Welsh)
    $string =~ s/\[LL\]/\&Lllig;/g;                     # LL ligature (Welsh)

    $string =~ s/\[dd\]/\&dstrok;/g;                    # dd = d with stroke (Welsh)
    $string =~ s/\[Dd\]/\&Dstrok;/g;                    # Dd = D with stroke (Welsh)
    $string =~ s/\[DD\]/\&Dstrok;/g;                    # DD = D with stroke (Welsh)

    $string =~ s/\[w6\]/\&wwelsh;/g;                    # Middle Welsh w (looks like 6 with open loop)
    $string =~ s/\[W6\]/\&Wwelsh;/g;                    # Middle Welsh W (looks like 6 with open loop)

    # Ligatures with accents
    $string =~ s/\[\^(ae|\x{00e6})\]/\&aecirc;/g;       # ae with circumflex
    $string =~ s/\[\'(ae|\x{00e6})\]/\&aeacute;/g;      # ae with acute
    $string =~ s/\[\/(ae|\x{00e6})\]/\&aeacute;/g;      # ae with acute
    $string =~ s/\[\x{00b4}(ae|\x{00e6})\]/\&aeacute;/g;        # ae with acute (wrong encoding!)

    $string =~ s/\[\'oe\]/\&oeacute;/g;                 # oe with acute
    $string =~ s/\[\'OE\]/\&OEacute;/g;                 # OE with acute
    $string =~ s/\[\/oe\]/\&oeacute;/g;                 # oe with acute
    $string =~ s/\[\/OE\]/\&OEacute;/g;                 # OE with acute
    $string =~ s/\[o\x{00e9}\]/\&oeacute;/g;            # oe with acute
    $string =~ s/\[\x{00f3}e\]/\&oeacute;/g;            # oe with acute
    $string =~ s/\[\x{00b4}oe\]/\&oeacute;/g;           # oe with acute (wrong encoding!)

    # Old-Icelandic ligatures
    $string =~ s/\[ao\]/\&aolig;/g;                     # ao ligature
    $string =~ s/\[AO\]/\&AOlig;/g;                     # AO ligature
    $string =~ s/\[\/ao\]/\&aoacute;/g;                 # ao with acute
    $string =~ s/\[a\x{00f3}\]/\&aoacute;/g;            # ao with acute
    $string =~ s/\[\x{00e1}o\]/\&aoacute;/g;            # ao with acute
    $string =~ s/\[\/AO\]/\&AOacute;/g;                 # AO with acute

    # Double accents
    $string =~ s/\[\)=([a-zA-Z])\]/\&$1macrbrev;/g;     # macron and breve
    $string =~ s/\[\^\"([a-zA-Z])\]/\&$1umlcirc;/g;     # dieresis and circumflex

    $string =~ s/\[``([a-zA-Z])\]/\&$1dgrave;/g;        # double grave

    # More JASCHKE:
    $string =~ s/\[:x]/\&xuml;/g;                       # x umlaut (JASCHKE)
    $string =~ s/\[~e=]/\&etilbarb;/g;                  # e with tilde and bar below (JASCHKE)
    $string =~ s/\[~o=]/\&otilbarb;/g;                  # o with tilde and bar below (JASCHKE)
    $string =~ s/\[~o:]/\&otilumlb;/g;                  # o with tilde and umlaut below (JASCHKE)
    $string =~ s/\['=o]/\&omacracu;/g;                  # o with macron and acute (JASCHKE)
    $string =~ s/\['=a]/\&amacracu;/g;                  # a with macron and acute (JASCHKE)
    $string =~ s/\[=e=]/\&emacrbarb;/g;                 # e with macron and bar below (JASCHKE)
    $string =~ s/\['=e=]/\&emacracubarb;/g;             # e with macron and acute and bar below (JASCHKE)
    $string =~ s/\[\)o=]/\&obrevbarb;/g;                # o with breve and bar below (JASCHKE)
    $string =~ s/\[\)o:]/\&obrevumlb;/g;                # o with breve and umlaut below (JASCHKE)
    $string =~ s/\[\)e:]/\&ebrevumlb;/g;                # e with breve and umlaut below (JASCHKE)
    $string =~ s/\[\)e=]/\&ebrevbarb;/g;                # e with breve and bar below (JASCHKE)
    $string =~ s/\['\)o:]/\&oacubrevumlb;/g;            # o with breve and acute and umlaut below (JASCHKE)
    $string =~ s/\['vs]/\&scaracu;/g;                   # s with caron and acute (JASCHKE)
    $string =~ s/\['vz]/\&zcaracu;/g;                   # z with caron and acute (JASCHKE)
    $string =~ s/\['vc]/\&ccaracu;/g;                   # c with caron and acute (JASCHKE)
    $string =~ s/\['vj]/\&jcaracu;/g;                   # j with caron and acute (JASCHKE)
    $string =~ s/\[\)s\.]/\&sbrevdotb;/g;               # s with breve and dot below (JASCHKE)
    $string =~ s/\[\x{00e9}=\]/\&eacubarb;/g;           # e with acute and bar below (JASCHKE)
    $string =~ s/\['=e\]/\&emacracu;/g;                 # e with macron and acute (JASCHKE)
    $string =~ s/\[\x{00e9}\.\]/\&eacudotb;/g;          # e with acute and dot below (JASCHKE)
    $string =~ s/\['o:\]/\&oacuumlb;/g;                 # o with acute and umlaut below (JASCHKE)
    $string =~ s/\[vs.\]/\&scardotb;/g;                 # s with caron and dot below (JASCHKE)

    # Guilder sign
    $string =~ s/\[f\]/\&florin;/g;                     # guilder sign.

    # various odd letters: (As used in Franck's Etymologisch Woordenboek)
    $string =~ s/\[ng\]/\&eng;/g;                       # eng
    $string =~ s/\[NG\]/\&ENG;/g;                       # ENG
    $string =~ s/\[zh\]/\&ezh;/g;                       # ezh
    $string =~ s/\[ZH\]/\&EZH;/g;                       # EZH
    $string =~ s/\[sh\]/\&esh;/g;                       # esh
    $string =~ s/\[SH\]/\&ESH;/g;                       # ESH

    # Letters with strokes
    $string =~ s/\[-b\]/\&bstrok;/g;                    # b with stroke through stem
    $string =~ s/\[-d\]/\&dstrok;/g;                    # d with stroke through stem
    $string =~ s/\[-h\]/\&hstrok;/g;                    # h with stroke through stem
    $string =~ s/\[-l\]/\&lstrok;/g;                    # l with stroke through stem
    $string =~ s/\[-L\]/\&Lstrok;/g;                    # L with stroke through stem

    return $string;
}


sub handlePgdpAccents() {
    my $line = shift;
    return NFC(handlePgdpWideAccents(handlePgdpNormalAccents($line)));
}


sub handlePgdpWideAccents() {
    my $line = shift;

    $line = NFD($line);

    my $abovePattern = "(['/`\\\\=~()-]*)";

    # Unicode \p{M} pattern doesn't work in Perl:
    # my $basePattern = "([a-zA-Z]\p{M}*)([a-zA-Z]\p{M}*)";
    my $basePattern = "([a-zA-Z][\x{300}-\x{36F}]*)([a-zA-Z][\x{300}-\x{36F}]*)";
    my $belowPattern = "([=)-]*)";

    my $pattern = "\\[" . $abovePattern . $basePattern . $belowPattern . "\\]";

    $line =~ s/$pattern/convertWideAccent($1,$2,$3,$4)/ge;
    return $line;
}


sub convertWideAccent() {
    my $above = shift;
    my $base1 = shift;
    my $base2 = shift;
    my $below = shift;

    if ($base1 eq 'i') {
        $base1 = "\x{131}";
    }
    if ($base2 eq 'i') {
        $base2 = "\x{131}";
    }

    my %aboveAccents = (
        "`"         => "\x{300}\x{34F}",   # acute (needs CGJ to avoid reordering in NFC)
        "\\"        => "\x{300}\x{34F}",   # acute
        "'"         => "\x{301}\x{34F}",   # grave
        "/"         => "\x{301}\x{34F}",   # grave

        ")"         => "\x{35D}",   # wide breve
        "="         => "\x{35E}",   # wide macron
        "-"         => "\x{35E}",   # wide macron
        "~"         => "\x{360}",   # wide tilde
        "("         => "\x{361}",   # wide inverted breve
    );

    my %belowAccents = (
        ")"         => "\x{35C}",   # wide breve
        "="         => "\x{35F}",   # wide macron
        "-"         => "\x{35F}",   # wide macron
    );

    my @aboves = split(//, $above);
    foreach my $a (@aboves) {
        $a = $aboveAccents{$a};
    }
    $above = join('', @aboves);

    my @belows = split(//, $below);
    foreach my $b (@belows) {
        $b = $belowAccents{$b};
    }
    $below = join('', @belows);

    return $base1 . $below . reverse($above) . $base2;
}


sub handlePgdpNormalAccents() {
    my $line = shift;

    $line = NFD($line);

    my $abovePattern = "(['`\"/\\\\?*:.^)(v=~-]*)";
    my $basePattern = "([a-zA-Z][\x{300}-\x{36F}]*)";
    my $belowPattern = "([.\":*,v^)(~=<>-]*)";

    my $pattern = "\\[" . $abovePattern . $basePattern . $belowPattern . "\\]";

    $line =~ s/$pattern/convertAccent($1,$2,$3)/ge;
    return $line;
}


sub convertAccent() {
    my $above = shift;
    my $base = shift;
    my $below = shift;

    my %aboveAccents = (
        "`"         => "\x{300}",   # acute
        "\\"        => "\x{300}",   # acute
        "'"         => "\x{301}",   # grave
        "/"         => "\x{301}",   # grave
        "^"         => "\x{302}",   # circumflex
        "~"         => "\x{303}",   # tilde
        "="         => "\x{304}",   # macron
        "-"         => "\x{304}",   # macron
        ")"         => "\x{306}",   # breve
        "."         => "\x{307}",   # dot
        "\""        => "\x{308}",   # diaeresis
        ":"         => "\x{308}",   # diaeresis
        "?"         => "\x{309}",   # hook
        "*"         => "\x{30A}",   # ring
        "v"         => "\x{30C}",   # caron
        "("         => "\x{311}",   # inverted breve
        ","         => "\x{312}"    # cedilla
    );

    # dot diaeresis(2) ring cedilla caron circumflex breve inverted-breve tilde macron(2)

    my %belowAccents = (
        "."         => "\x{323}",   # dot
        "\""        => "\x{324}",   # diaeresis
        ":"         => "\x{324}",   # diaeresis
        "*"         => "\x{325}",   # ring
        ","         => "\x{327}",   # cedilla
        "v"         => "\x{32C}",   # caron
        "^"         => "\x{32D}",   # circumflex
        ")"         => "\x{32E}",   # breve
        "("         => "\x{32F}",   # inverted breve
        "~"         => "\x{330}",   # tilde
        "="         => "\x{331}",   # macron
        "-"         => "\x{331}",   # macron
    );

    my @aboves = split(//, $above);
    my @belows = split(//, $below);

    foreach my $a (@aboves) {
        $a = $aboveAccents{$a};
    }

    foreach my $b (@belows) {
        $b = $belowAccents{$b};
    }

    $above = join('', @aboves);
    $below = join('', @belows);

    return $base . $below . reverse($above);
}

1;
