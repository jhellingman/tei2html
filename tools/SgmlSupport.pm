# sgmlSupport.pm -- package to support SGML entities.
#

package SgmlSupport;

use base 'Exporter';

use Unicode::Normalize;
use HTML::Entities;

our $VERSION = '1.00';
our @ISA = qw(Exporter);
our @EXPORT = qw(getAttrVal sgml2utf sgml2utf_html utf2sgml utf2entities utf2numericEntities pgdp2sgml translateEntity handlePgdpAccents);


sub utf2chr {
    my $string = shift;

    my @chars = split(//, $string);
    foreach (@chars) {
        if (ord($_) > 127) {
            $_ = 'chr(0x' . sprintf('%04X', ord($_)) . ')';
        }
        else {
            $_ = '"' . $_ . '"';
        }
    }
    return join(' . ', @chars);
}


BEGIN {

    %ent = ();

    # mapping from SGML entities to Unicode
    # Derived from SGML.TXT, downloaded from www.unicode.org

    # $ent{'fjlig'}     = chr(0x????);  #  fj ligature
    # $ent{'gap'}       = chr(0x????);  #  greater-than, approximately equal to
    # $ent{'gEl'}       = chr(0x????);  #  greater-than, double equals, less-than
    # $ent{'gnap'}      = chr(0x????);  #  greater-than, not approximately equal to
    # $ent{'jnodot'}    = chr(0x????);  #  latin small letter dotless j
    # $ent{'lpargt'}    = chr(0x????);  #  left parenthesis, greater-than
    # $ent{'lap'}       = chr(0x????);  #  less-than, approximately equal to
    # $ent{'lEg'}       = chr(0x????);  #  less-than, double equals, greater-than
    # $ent{'lnap'}      = chr(0x????);  #  less-than, not approximately equal to
    # $ent{'ngE'}       = chr(0x????);  #  not greater-than, double equals
    # $ent{'nlE'}       = chr(0x????);  #  not less-than, double equals
    # $ent{'nsmid'}     = chr(0x????);  #  nshortmid
    # $ent{'prap'}      = chr(0x????);  #  precedes, approximately equal to
    # $ent{'prnap'}     = chr(0x????);  #  precedes, not approximately equal to
    # $ent{'prnE'}      = chr(0x????);  #  precedes, not double equal
    # $ent{'rpargt'}    = chr(0x????);  #  right parenthesis, greater-than
    # $ent{'smid'}      = chr(0x????);  #  shortmid
    # $ent{'scap'}      = chr(0x????);  #  succeeds, approximately equal to
    # $ent{'scnap'}     = chr(0x????);  #  succeeds, not approximately equal to
    # $ent{'scnE'}      = chr(0x????);  #  succeeds, not double equals
    # $ent{'epsiv'}     = chr(0x????);  #  variant epsilon

    $ent{'Aacgr'}       = chr(0x0386);  #  GREEK CAPITAL LETTER ALPHA WITH TONOS
    $ent{'aacgr'}       = chr(0x03AC);  #  GREEK SMALL LETTER ALPHA WITH TONOS
    $ent{'Aacute'}      = chr(0x00C1);  #  LATIN CAPITAL LETTER A WITH ACUTE
    $ent{'aacute'}      = chr(0x00E1);  #  LATIN SMALL LETTER A WITH ACUTE
    $ent{'Abreve'}      = chr(0x0102);  #  LATIN CAPITAL LETTER A WITH BREVE
    $ent{'abreve'}      = chr(0x0103);  #  LATIN SMALL LETTER A WITH BREVE
    $ent{'Acirc'}       = chr(0x00C2);  #  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
    $ent{'acirc'}       = chr(0x00E2);  #  LATIN SMALL LETTER A WITH CIRCUMFLEX
    $ent{'acute'}       = chr(0x00B4);  #  ACUTE ACCENT
    $ent{'Acy'}         = chr(0x0410);  #  CYRILLIC CAPITAL LETTER A
    $ent{'acy'}         = chr(0x0430);  #  CYRILLIC SMALL LETTER A
    $ent{'AElig'}       = chr(0x00C6);  #  LATIN CAPITAL LETTER AE
    $ent{'aelig'}       = chr(0x00E6);  #  LATIN SMALL LETTER AE
    $ent{'Agr'}         = chr(0x0391);  #  GREEK CAPITAL LETTER ALPHA
    $ent{'agr'}         = chr(0x03B1);  #  GREEK SMALL LETTER ALPHA
    $ent{'Agrave'}      = chr(0x00C0);  #  LATIN CAPITAL LETTER A WITH GRAVE
    $ent{'agrave'}      = chr(0x00E0);  #  LATIN SMALL LETTER A WITH GRAVE
    $ent{'aleph'}       = chr(0x2135);  #  ALEF SYMBOL
    $ent{'Amacr'}       = chr(0x0100);  #  LATIN CAPITAL LETTER A WITH MACRON
    $ent{'amacr'}       = chr(0x0101);  #  LATIN SMALL LETTER A WITH MACRON
    $ent{'amp'}         = chr(0x0026);  #  AMPERSAND
    $ent{'and'}         = chr(0x2227);  #  LOGICAL AND
    $ent{'ang'}         = chr(0x2220);  #  ANGLE
    $ent{'ang90'}       = chr(0x221F);  #  RIGHT ANGLE
    $ent{'angmsd'}      = chr(0x2221);  #  MEASURED ANGLE
    $ent{'angsph'}      = chr(0x2222);  #  SPHERICAL ANGLE
    $ent{'angst'}       = chr(0x212B);  #  ANGSTROM SIGN
    $ent{'Aogon'}       = chr(0x0104);  #  LATIN CAPITAL LETTER A WITH OGONEK
    $ent{'aogon'}       = chr(0x0105);  #  LATIN SMALL LETTER A WITH OGONEK
    $ent{'ap'}          = chr(0x2248);  #  ALMOST EQUAL TO
    $ent{'ape'}         = chr(0x224A);  #  ALMOST EQUAL OR EQUAL TO
    $ent{'Aring'}       = chr(0x00C5);  #  LATIN CAPITAL LETTER A WITH RING ABOVE
    $ent{'aring'}       = chr(0x00E5);  #  LATIN SMALL LETTER A WITH RING ABOVE
    $ent{'ast'}         = chr(0x002A);  #  ASTERISK
    $ent{'Atilde'}      = chr(0x00C3);  #  LATIN CAPITAL LETTER A WITH TILDE
    $ent{'atilde'}      = chr(0x00E3);  #  LATIN SMALL LETTER A WITH TILDE
    $ent{'Auml'}        = chr(0x00C4);  #  LATIN CAPITAL LETTER A WITH DIAERESIS
    $ent{'auml'}        = chr(0x00E4);  #  LATIN SMALL LETTER A WITH DIAERESIS
    $ent{'barwed'}      = chr(0x22BC);  #  NAND
    $ent{'Barwed'}      = chr(0x2306);  #  PERSPECTIVE
    $ent{'bcong'}       = chr(0x224C);  #  ALL EQUAL TO
    $ent{'Bcy'}         = chr(0x0411);  #  CYRILLIC CAPITAL LETTER BE
    $ent{'bcy'}         = chr(0x0431);  #  CYRILLIC SMALL LETTER BE
    $ent{'bdquo'}       = chr(0x201E);  #  DOUBLE LOW-9 QUOTATION MARK
    $ent{'becaus'}      = chr(0x2235);  #  BECAUSE
    $ent{'bepsi'}       = chr(0x220D);  #  SMALL CONTAINS AS MEMBER
    $ent{'bernou'}      = chr(0x212C);  #  SCRIPT CAPITAL B
    $ent{'beth'}        = chr(0x2136);  #  BET SYMBOL
    $ent{'Bgr'}         = chr(0x0392);  #  GREEK CAPITAL LETTER BETA
    $ent{'bgr'}         = chr(0x03B2);  #  GREEK SMALL LETTER BETA
    $ent{'blank'}       = chr(0x2423);  #  OPEN BOX
    $ent{'blk12'}       = chr(0x2592);  #  MEDIUM SHADE
    $ent{'blk14'}       = chr(0x2591);  #  LIGHT SHADE
    $ent{'blk34'}       = chr(0x2593);  #  DARK SHADE
    $ent{'block'}       = chr(0x2588);  #  FULL BLOCK
    $ent{'bottom'}      = chr(0x22A5);  #  UP TACK
    $ent{'bowtie'}      = chr(0x22C8);  #  BOWTIE
    $ent{'boxdl'}       = chr(0x2510);  #  BOX DRAWINGS LIGHT DOWN AND LEFT
    $ent{'boxdL'}       = chr(0x2555);  #  BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE
    $ent{'boxDl'}       = chr(0x2556);  #  BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE
    $ent{'boxDL'}       = chr(0x2557);  #  BOX DRAWINGS DOUBLE DOWN AND LEFT
    $ent{'boxdr'}       = chr(0x250C);  #  BOX DRAWINGS LIGHT DOWN AND RIGHT
    $ent{'boxdR'}       = chr(0x2552);  #  BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE
    $ent{'boxDr'}       = chr(0x2553);  #  BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE
    $ent{'boxDR'}       = chr(0x2554);  #  BOX DRAWINGS DOUBLE DOWN AND RIGHT
    $ent{'boxh'}        = chr(0x2500);  #  BOX DRAWINGS LIGHT HORIZONTAL
    $ent{'boxH'}        = chr(0x2550);  #  BOX DRAWINGS DOUBLE HORIZONTAL
    $ent{'boxhd'}       = chr(0x252C);  #  BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
    $ent{'boxHd'}       = chr(0x2564);  #  BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE
    $ent{'boxhD'}       = chr(0x2565);  #  BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE
    $ent{'boxHD'}       = chr(0x2566);  #  BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL
    $ent{'boxhu'}       = chr(0x2534);  #  BOX DRAWINGS LIGHT UP AND HORIZONTAL
    $ent{'boxHu'}       = chr(0x2567);  #  BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE
    $ent{'boxhU'}       = chr(0x2568);  #  BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE
    $ent{'boxHU'}       = chr(0x2569);  #  BOX DRAWINGS DOUBLE UP AND HORIZONTAL
    $ent{'boxul'}       = chr(0x2518);  #  BOX DRAWINGS LIGHT UP AND LEFT
    $ent{'boxuL'}       = chr(0x255B);  #  BOX DRAWINGS UP SINGLE AND LEFT DOUBLE
    $ent{'boxUl'}       = chr(0x255C);  #  BOX DRAWINGS UP DOUBLE AND LEFT SINGLE
    $ent{'boxUL'}       = chr(0x255D);  #  BOX DRAWINGS DOUBLE UP AND LEFT
    $ent{'boxur'}       = chr(0x2514);  #  BOX DRAWINGS LIGHT UP AND RIGHT
    $ent{'boxuR'}       = chr(0x2558);  #  BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE
    $ent{'boxUr'}       = chr(0x2559);  #  BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE
    $ent{'boxUR'}       = chr(0x255A);  #  BOX DRAWINGS DOUBLE UP AND RIGHT
    $ent{'boxv'}        = chr(0x2502);  #  BOX DRAWINGS LIGHT VERTICAL
    $ent{'boxV'}        = chr(0x2551);  #  BOX DRAWINGS DOUBLE VERTICAL
    $ent{'boxvh'}       = chr(0x253C);  #  BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
    $ent{'boxvH'}       = chr(0x256A);  #  BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE
    $ent{'boxVh'}       = chr(0x256B);  #  BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE
    $ent{'boxVH'}       = chr(0x256C);  #  BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL
    $ent{'boxvl'}       = chr(0x2524);  #  BOX DRAWINGS LIGHT VERTICAL AND LEFT
    $ent{'boxvL'}       = chr(0x2561);  #  BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE
    $ent{'boxVl'}       = chr(0x2562);  #  BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE
    $ent{'boxVL'}       = chr(0x2563);  #  BOX DRAWINGS DOUBLE VERTICAL AND LEFT
    $ent{'boxvr'}       = chr(0x251C);  #  BOX DRAWINGS LIGHT VERTICAL AND RIGHT
    $ent{'boxvR'}       = chr(0x255E);  #  BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE
    $ent{'boxVr'}       = chr(0x255F);  #  BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE
    $ent{'boxVR'}       = chr(0x2560);  #  BOX DRAWINGS DOUBLE VERTICAL AND RIGHT
    $ent{'bprime'}      = chr(0x2035);  #  REVERSED PRIME
    $ent{'breve'}       = chr(0x02D8);  #  BREVE
    $ent{'brvbar'}      = chr(0x00A6);  #  BROKEN BAR
    $ent{'bsim'}        = chr(0x223D);  #  REVERSED TILDE
    $ent{'bsime'}       = chr(0x22CD);  #  REVERSED TILDE EQUALS
    $ent{'bsol'}        = chr(0x005C);  #  REVERSE SOLIDUS
    $ent{'bull'}        = chr(0x2022);  #  BULLET
    $ent{'bump'}        = chr(0x224E);  #  GEOMETRICALLY EQUIVALENT TO
    $ent{'bumpe'}       = chr(0x224F);  #  DIFFERENCE BETWEEN
    $ent{'Cacute'}      = chr(0x0106);  #  LATIN CAPITAL LETTER C WITH ACUTE
    $ent{'cacute'}      = chr(0x0107);  #  LATIN SMALL LETTER C WITH ACUTE
    $ent{'cap'}         = chr(0x2229);  #  INTERSECTION
    $ent{'Cap'}         = chr(0x22D2);  #  DOUBLE INTERSECTION
    $ent{'caret'}       = chr(0x2041);  #  CARET INSERTION POINT
    $ent{'caron'}       = chr(0x02C7);  #  CARON
    $ent{'Ccaron'}      = chr(0x010C);  #  LATIN CAPITAL LETTER C WITH CARON
    $ent{'ccaron'}      = chr(0x010D);  #  LATIN SMALL LETTER C WITH CARON
    $ent{'Ccedil'}      = chr(0x00C7);  #  LATIN CAPITAL LETTER C WITH CEDILLA
    $ent{'ccedil'}      = chr(0x00E7);  #  LATIN SMALL LETTER C WITH CEDILLA
    $ent{'Ccirc'}       = chr(0x0108);  #  LATIN CAPITAL LETTER C WITH CIRCUMFLEX
    $ent{'ccirc'}       = chr(0x0109);  #  LATIN SMALL LETTER C WITH CIRCUMFLEX
    $ent{'Cdot'}        = chr(0x010A);  #  LATIN CAPITAL LETTER C WITH DOT ABOVE
    $ent{'cdot'}        = chr(0x010B);  #  LATIN SMALL LETTER C WITH DOT ABOVE
    $ent{'cedil'}       = chr(0x00B8);  #  CEDILLA
    $ent{'cent'}        = chr(0x00A2);  #  CENT SIGN
    $ent{'CHcy'}        = chr(0x0427);  #  CYRILLIC CAPITAL LETTER CHE
    $ent{'chcy'}        = chr(0x0447);  #  CYRILLIC SMALL LETTER CHE
    $ent{'check'}       = chr(0x2713);  #  CHECK MARK
    $ent{'cir'}         = chr(0x25CB);  #  WHITE CIRCLE
    $ent{'circ'}        = chr(0x02C6);  #  MODIFIER LETTER CIRCUMFLEX ACCENT
    $ent{'cire'}        = chr(0x2257);  #  RING EQUAL TO
    $ent{'clubs'}       = chr(0x2663);  #  BLACK CLUB SUIT
    $ent{'colon'}       = chr(0x003A);  #  COLON
    $ent{'colone'}      = chr(0x2254);  #  COLON EQUALS
    $ent{'comma'}       = chr(0x002C);  #  COMMA
    $ent{'commat'}      = chr(0x0040);  #  COMMERCIAL AT
    $ent{'comp'}        = chr(0x2201);  #  COMPLEMENT
    $ent{'compfn'}      = chr(0x2218);  #  RING OPERATOR
    $ent{'cong'}        = chr(0x2245);  #  APPROXIMATELY EQUAL TO
    $ent{'conint'}      = chr(0x222E);  #  CONTOUR INTEGRAL
    $ent{'coprod'}      = chr(0x2210);  #  N-ARY COPRODUCT
    $ent{'copy'}        = chr(0x00A9);  #  COPYRIGHT SIGN
    $ent{'copysr'}      = chr(0x2117);  #  SOUND RECORDING COPYRIGHT
    $ent{'crarr'}       = chr(0x21B5);  #  DOWNWARDS ARROW WITH CORNER LEFTWARDS
    $ent{'cross'}       = chr(0x2717);  #  BALLOT X
    $ent{'cuepr'}       = chr(0x22DE);  #  EQUAL TO OR PRECEDES
    $ent{'cuesc'}       = chr(0x22DF);  #  EQUAL TO OR SUCCEEDS
    $ent{'cularr'}      = chr(0x21B6);  #  ANTICLOCKWISE TOP SEMICIRCLE ARROW
    $ent{'cup'}         = chr(0x222A);  #  UNION
    $ent{'Cup'}         = chr(0x22D3);  #  DOUBLE UNION
    $ent{'curarr'}      = chr(0x21B7);  #  CLOCKWISE TOP SEMICIRCLE ARROW
    $ent{'curren'}      = chr(0x00A4);  #  CURRENCY SIGN
    $ent{'cuvee'}       = chr(0x22CE);  #  CURLY LOGICAL OR
    $ent{'cuwed'}       = chr(0x22CF);  #  CURLY LOGICAL AND
    $ent{'dagger'}      = chr(0x2020);  #  DAGGER
    $ent{'Dagger'}      = chr(0x2021);  #  DOUBLE DAGGER
    $ent{'daleth'}      = chr(0x2138);  #  DALET SYMBOL
    $ent{'darr'}        = chr(0x2193);  #  DOWNWARDS ARROW
    $ent{'dArr'}        = chr(0x21D3);  #  DOWNWARDS DOUBLE ARROW
    $ent{'darr2'}       = chr(0x21CA);  #  DOWNWARDS PAIRED ARROWS
    $ent{'dash'}        = chr(0x2010);  #  HYPHEN
    $ent{'dashv'}       = chr(0x22A3);  #  LEFT TACK
    $ent{'dblac'}       = chr(0x02DD);  #  DOUBLE ACUTE ACCENT
    $ent{'Dcaron'}      = chr(0x010E);  #  LATIN CAPITAL LETTER D WITH CARON
    $ent{'dcaron'}      = chr(0x010F);  #  LATIN SMALL LETTER D WITH CARON
    $ent{'Dcy'}         = chr(0x0414);  #  CYRILLIC CAPITAL LETTER DE
    $ent{'dcy'}         = chr(0x0434);  #  CYRILLIC SMALL LETTER DE
    $ent{'deg'}         = chr(0x00B0);  #  DEGREE SIGN
    $ent{'Dgr'}         = chr(0x0394);  #  GREEK CAPITAL LETTER DELTA
    $ent{'dgr'}         = chr(0x03B4);  #  GREEK SMALL LETTER DELTA
    $ent{'dharl'}       = chr(0x21C3);  #  DOWNWARDS HARPOON WITH BARB LEFTWARDS
    $ent{'dharr'}       = chr(0x21C2);  #  DOWNWARDS HARPOON WITH BARB RIGHTWARDS
    $ent{'diam'}        = chr(0x22C4);  #  DIAMOND OPERATOR
    $ent{'diams'}       = chr(0x2666);  #  BLACK DIAMOND SUIT
    $ent{'divide'}      = chr(0x00F7);  #  DIVISION SIGN
    $ent{'divonx'}      = chr(0x22C7);  #  DIVISION TIMES
    $ent{'DJcy'}        = chr(0x0402);  #  CYRILLIC CAPITAL LETTER DJE
    $ent{'djcy'}        = chr(0x0452);  #  CYRILLIC SMALL LETTER DJE
    $ent{'dlarr'}       = chr(0x2199);  #  SOUTH WEST ARROW
    $ent{'dlcorn'}      = chr(0x231E);  #  BOTTOM LEFT CORNER
    $ent{'dlcrop'}      = chr(0x230D);  #  BOTTOM LEFT CROP
    $ent{'dollar'}      = chr(0x0024);  #  DOLLAR SIGN
    $ent{'dot'}         = chr(0x02D9);  #  DOT ABOVE
    $ent{'DotDot'}      = chr(0x20DC);  #  COMBINING FOUR DOTS ABOVE
    $ent{'drarr'}       = chr(0x2198);  #  SOUTH EAST ARROW
    $ent{'drcorn'}      = chr(0x231F);  #  BOTTOM RIGHT CORNER
    $ent{'drcrop'}      = chr(0x230C);  #  BOTTOM RIGHT CROP
    $ent{'DScy'}        = chr(0x0405);  #  CYRILLIC CAPITAL LETTER DZE
    $ent{'dscy'}        = chr(0x0455);  #  CYRILLIC SMALL LETTER DZE
    $ent{'Dstrok'}      = chr(0x0110);  #  LATIN CAPITAL LETTER D WITH STROKE
    $ent{'dstrok'}      = chr(0x0111);  #  LATIN SMALL LETTER D WITH STROKE
    $ent{'dtri'}        = chr(0x25BF);  #  WHITE DOWN-POINTING SMALL TRIANGLE
    $ent{'dtrif'}       = chr(0x25BE);  #  BLACK DOWN-POINTING SMALL TRIANGLE
    $ent{'DZcy'}        = chr(0x040F);  #  CYRILLIC CAPITAL LETTER DZHE
    $ent{'dzcy'}        = chr(0x045F);  #  CYRILLIC SMALL LETTER DZHE
    $ent{'Eacgr'}       = chr(0x0388);  #  GREEK CAPITAL LETTER EPSILON WITH TONOS
    $ent{'eacgr'}       = chr(0x03AD);  #  GREEK SMALL LETTER EPSILON WITH TONOS
    $ent{'Eacute'}      = chr(0x00C9);  #  LATIN CAPITAL LETTER E WITH ACUTE
    $ent{'eacute'}      = chr(0x00E9);  #  LATIN SMALL LETTER E WITH ACUTE
    $ent{'Ecaron'}      = chr(0x011A);  #  LATIN CAPITAL LETTER E WITH CARON
    $ent{'ecaron'}      = chr(0x011B);  #  LATIN SMALL LETTER E WITH CARON
    $ent{'ecir'}        = chr(0x2256);  #  RING IN EQUAL TO
    $ent{'Ecirc'}       = chr(0x00CA);  #  LATIN CAPITAL LETTER E WITH CIRCUMFLEX
    $ent{'ecirc'}       = chr(0x00EA);  #  LATIN SMALL LETTER E WITH CIRCUMFLEX
    $ent{'ecolon'}      = chr(0x2255);  #  EQUALS COLON
    $ent{'Ecy'}         = chr(0x042D);  #  CYRILLIC CAPITAL LETTER E
    $ent{'ecy'}         = chr(0x044D);  #  CYRILLIC SMALL LETTER E
    $ent{'Edot'}        = chr(0x0116);  #  LATIN CAPITAL LETTER E WITH DOT ABOVE
    $ent{'edot'}        = chr(0x0117);  #  LATIN SMALL LETTER E WITH DOT ABOVE
    $ent{'eDot'}        = chr(0x2251);  #  GEOMETRICALLY EQUAL TO
    $ent{'EEacgr'}      = chr(0x0389);  #  GREEK CAPITAL LETTER ETA WITH TONOS
    $ent{'eeacgr'}      = chr(0x03AE);  #  GREEK SMALL LETTER ETA WITH TONOS
    $ent{'EEgr'}        = chr(0x0397);  #  GREEK CAPITAL LETTER ETA
    $ent{'eegr'}        = chr(0x03B7);  #  GREEK SMALL LETTER ETA
    $ent{'efDot'}       = chr(0x2252);  #  APPROXIMATELY EQUAL TO OR THE IMAGE OF
    $ent{'Egr'}         = chr(0x0395);  #  GREEK CAPITAL LETTER EPSILON
    $ent{'egr'}         = chr(0x03B5);  #  GREEK SMALL LETTER EPSILON
    $ent{'Egrave'}      = chr(0x00C8);  #  LATIN CAPITAL LETTER E WITH GRAVE
    $ent{'egrave'}      = chr(0x00E8);  #  LATIN SMALL LETTER E WITH GRAVE
    $ent{'egs'}         = chr(0x22DD);  #  EQUAL TO OR GREATER-THAN
    $ent{'ell'}         = chr(0x2113);  #  SCRIPT SMALL L
    $ent{'els'}         = chr(0x22DC);  #  EQUAL TO OR LESS-THAN
    $ent{'Emacr'}       = chr(0x0112);  #  LATIN CAPITAL LETTER E WITH MACRON
    $ent{'emacr'}       = chr(0x0113);  #  LATIN SMALL LETTER E WITH MACRON
    $ent{'empty'}       = chr(0x2205);  #  EMPTY SET
    $ent{'emsp'}        = chr(0x2003);  #  EM SPACE
    $ent{'emsp13'}      = chr(0x2004);  #  THREE-PER-EM SPACE
    $ent{'emsp14'}      = chr(0x2005);  #  FOUR-PER-EM SPACE
    $ent{'ENG'}         = chr(0x014A);  #  LATIN CAPITAL LETTER ENG
    $ent{'eng'}         = chr(0x014B);  #  LATIN SMALL LETTER ENG
    $ent{'ensp'}        = chr(0x2002);  #  EN SPACE
    $ent{'Eogon'}       = chr(0x0118);  #  LATIN CAPITAL LETTER E WITH OGONEK
    $ent{'eogon'}       = chr(0x0119);  #  LATIN SMALL LETTER E WITH OGONEK
    $ent{'epsis'}       = chr(0x220A);  #  SMALL ELEMENT OF
    $ent{'equals'}      = chr(0x003D);  #  EQUALS SIGN
    $ent{'equiv'}       = chr(0x2261);  #  IDENTICAL TO
    $ent{'erDot'}       = chr(0x2253);  #  IMAGE OF OR APPROXIMATELY EQUAL TO
    $ent{'esdot'}       = chr(0x2250);  #  APPROACHES THE LIMIT
    $ent{'ETH'}         = chr(0x00D0);  #  LATIN CAPITAL LETTER ETH
    $ent{'eth'}         = chr(0x00F0);  #  LATIN SMALL LETTER ETH
    $ent{'Euml'}        = chr(0x00CB);  #  LATIN CAPITAL LETTER E WITH DIAERESIS
    $ent{'euml'}        = chr(0x00EB);  #  LATIN SMALL LETTER E WITH DIAERESIS
    $ent{'excl'}        = chr(0x0021);  #  EXCLAMATION MARK
    $ent{'exist'}       = chr(0x2203);  #  THERE EXISTS
    $ent{'Fcy'}         = chr(0x0424);  #  CYRILLIC CAPITAL LETTER EF
    $ent{'fcy'}         = chr(0x0444);  #  CYRILLIC SMALL LETTER EF
    $ent{'female'}      = chr(0x2640);  #  FEMALE SIGN
    $ent{'ffilig'}      = chr(0xFB03);  #  LATIN SMALL LIGATURE FFI
    $ent{'fflig'}       = chr(0xFB00);  #  LATIN SMALL LIGATURE FF
    $ent{'ffllig'}      = chr(0xFB04);  #  LATIN SMALL LIGATURE FFL
    $ent{'filig'}       = chr(0xFB01);  #  LATIN SMALL LIGATURE FI
    $ent{'flat'}        = chr(0x266D);  #  MUSIC FLAT SIGN
    $ent{'fllig'}       = chr(0xFB02);  #  LATIN SMALL LIGATURE FL
    $ent{'fnof'}        = chr(0x0192);  #  LATIN SMALL LETTER F WITH HOOK
    $ent{'forall'}      = chr(0x2200);  #  FOR ALL
    $ent{'fork'}        = chr(0x22D4);  #  PITCHFORK
    $ent{'frac12'}      = chr(0x00BD);  #  VULGAR FRACTION ONE HALF
    $ent{'frac13'}      = chr(0x2153);  #  VULGAR FRACTION ONE THIRD
    $ent{'frac14'}      = chr(0x00BC);  #  VULGAR FRACTION ONE QUARTER
    $ent{'frac15'}      = chr(0x2155);  #  VULGAR FRACTION ONE FIFTH
    $ent{'frac16'}      = chr(0x2159);  #  VULGAR FRACTION ONE SIXTH
    $ent{'frac18'}      = chr(0x215B);  #  VULGAR FRACTION ONE EIGHTH
    $ent{'frac23'}      = chr(0x2154);  #  VULGAR FRACTION TWO THIRDS
    $ent{'frac25'}      = chr(0x2156);  #  VULGAR FRACTION TWO FIFTHS
    $ent{'frac34'}      = chr(0x00BE);  #  VULGAR FRACTION THREE QUARTERS
    $ent{'frac35'}      = chr(0x2157);  #  VULGAR FRACTION THREE FIFTHS
    $ent{'frac38'}      = chr(0x215C);  #  VULGAR FRACTION THREE EIGHTHS
    $ent{'frac45'}      = chr(0x2158);  #  VULGAR FRACTION FOUR FIFTHS
    $ent{'frac56'}      = chr(0x215A);  #  VULGAR FRACTION FIVE SIXTHS
    $ent{'frac58'}      = chr(0x215D);  #  VULGAR FRACTION FIVE EIGHTHS
    $ent{'frac78'}      = chr(0x215E);  #  VULGAR FRACTION SEVEN EIGHTHS
    $ent{'frasl'}       = chr(0x2044);  #  FRACTION SLASH
    $ent{'frown'}       = chr(0x2322);  #  FROWN
    $ent{'gacute'}      = chr(0x01F5);  #  LATIN SMALL LETTER G WITH ACUTE
    $ent{'Gbreve'}      = chr(0x011E);  #  LATIN CAPITAL LETTER G WITH BREVE
    $ent{'gbreve'}      = chr(0x011F);  #  LATIN SMALL LETTER G WITH BREVE
    $ent{'Gcedil'}      = chr(0x0122);  #  LATIN CAPITAL LETTER G WITH CEDILLA
    $ent{'gcedil'}      = chr(0x0123);  #  LATIN SMALL LETTER G WITH CEDILLA
    $ent{'Gcirc'}       = chr(0x011C);  #  LATIN CAPITAL LETTER G WITH CIRCUMFLEX
    $ent{'gcirc'}       = chr(0x011D);  #  LATIN SMALL LETTER G WITH CIRCUMFLEX
    $ent{'Gcy'}         = chr(0x0413);  #  CYRILLIC CAPITAL LETTER GHE
    $ent{'gcy'}         = chr(0x0433);  #  CYRILLIC SMALL LETTER GHE
    $ent{'Gdot'}        = chr(0x0120);  #  LATIN CAPITAL LETTER G WITH DOT ABOVE
    $ent{'gdot'}        = chr(0x0121);  #  LATIN SMALL LETTER G WITH DOT ABOVE
    $ent{'ge'}          = chr(0x2265);  #  GREATER-THAN OR EQUAL TO
    $ent{'gE'}          = chr(0x2267);  #  GREATER-THAN OVER EQUAL TO
    $ent{'gel'}         = chr(0x22DB);  #  GREATER-THAN EQUAL TO OR LESS-THAN
    $ent{'Gg'}          = chr(0x22D9);  #  VERY MUCH GREATER-THAN
    $ent{'Ggr'}         = chr(0x0393);  #  GREEK CAPITAL LETTER GAMMA
    $ent{'ggr'}         = chr(0x03B3);  #  GREEK SMALL LETTER GAMMA
    $ent{'gimel'}       = chr(0x2137);  #  GIMEL SYMBOL
    $ent{'GJcy'}        = chr(0x0403);  #  CYRILLIC CAPITAL LETTER GJE
    $ent{'gjcy'}        = chr(0x0453);  #  CYRILLIC SMALL LETTER GJE
    $ent{'gl'}          = chr(0x2277);  #  GREATER-THAN OR LESS-THAN
    $ent{'gne'}         = chr(0x2269);  #  GREATER-THAN BUT NOT EQUAL TO
    $ent{'gnsim'}       = chr(0x22E7);  #  GREATER-THAN BUT NOT EQUIVALENT TO
    $ent{'grave'}       = chr(0x0060);  #  GRAVE ACCENT
    $ent{'gsdot'}       = chr(0x22D7);  #  GREATER-THAN WITH DOT
    $ent{'gsim'}        = chr(0x2273);  #  GREATER-THAN OR EQUIVALENT TO
    $ent{'gt'}          = chr(0x003E);  #  GREATER-THAN SIGN
    $ent{'Gt'}          = chr(0x226B);  #  MUCH GREATER-THAN
    $ent{'hairsp'}      = chr(0x200A);  #  HAIR SPACE
    $ent{'hamilt'}      = chr(0x210B);  #  SCRIPT CAPITAL H
    $ent{'HARDcy'}      = chr(0x042A);  #  CYRILLIC CAPITAL LETTER HARD SIGN
    $ent{'hardcy'}      = chr(0x044A);  #  CYRILLIC SMALL LETTER HARD SIGN
    $ent{'harr'}        = chr(0x2194);  #  LEFT RIGHT ARROW
    $ent{'hArr'}        = chr(0x21D4);  #  LEFT RIGHT DOUBLE ARROW
    $ent{'harrw'}       = chr(0x21AD);  #  LEFT RIGHT WAVE ARROW
    $ent{'Hcirc'}       = chr(0x0124);  #  LATIN CAPITAL LETTER H WITH CIRCUMFLEX
    $ent{'hcirc'}       = chr(0x0125);  #  LATIN SMALL LETTER H WITH CIRCUMFLEX
    $ent{'hearts'}      = chr(0x2665);  #  BLACK HEART SUIT
    $ent{'hellip'}      = chr(0x2026);  #  HORIZONTAL ELLIPSIS
    $ent{'horbar'}      = chr(0x2015);  #  HORIZONTAL BAR
    $ent{'Hstrok'}      = chr(0x0126);  #  LATIN CAPITAL LETTER H WITH STROKE
    $ent{'hstrok'}      = chr(0x0127);  #  LATIN SMALL LETTER H WITH STROKE
    $ent{'hybull'}      = chr(0x2043);  #  HYPHEN BULLET
    $ent{'hyphen'}      = chr(0x002D);  #  HYPHEN-MINUS
    $ent{'Iacgr'}       = chr(0x038A);  #  GREEK CAPITAL LETTER IOTA WITH TONOS
    $ent{'iacgr'}       = chr(0x03AF);  #  GREEK SMALL LETTER IOTA WITH TONOS
    $ent{'Iacute'}      = chr(0x00CD);  #  LATIN CAPITAL LETTER I WITH ACUTE
    $ent{'iacute'}      = chr(0x00ED);  #  LATIN SMALL LETTER I WITH ACUTE
    $ent{'Icirc'}       = chr(0x00CE);  #  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
    $ent{'icirc'}       = chr(0x00EE);  #  LATIN SMALL LETTER I WITH CIRCUMFLEX
    $ent{'Icy'}         = chr(0x0418);  #  CYRILLIC CAPITAL LETTER I
    $ent{'icy'}         = chr(0x0438);  #  CYRILLIC SMALL LETTER I
    $ent{'idiagr'}      = chr(0x0390);  #  GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS
    $ent{'Idigr'}       = chr(0x03AA);  #  GREEK CAPITAL LETTER IOTA WITH DIALYTIKA
    $ent{'idigr'}       = chr(0x03CA);  #  GREEK SMALL LETTER IOTA WITH DIALYTIKA
    $ent{'Idot'}        = chr(0x0130);  #  LATIN CAPITAL LETTER I WITH DOT ABOVE
    $ent{'IEcy'}        = chr(0x0415);  #  CYRILLIC CAPITAL LETTER IE
    $ent{'iecy'}        = chr(0x0435);  #  CYRILLIC SMALL LETTER IE
    $ent{'iexcl'}       = chr(0x00A1);  #  INVERTED EXCLAMATION MARK
    $ent{'Igr'}         = chr(0x0399);  #  GREEK CAPITAL LETTER IOTA
    $ent{'igr'}         = chr(0x03B9);  #  GREEK SMALL LETTER IOTA
    $ent{'Igrave'}      = chr(0x00CC);  #  LATIN CAPITAL LETTER I WITH GRAVE
    $ent{'igrave'}      = chr(0x00EC);  #  LATIN SMALL LETTER I WITH GRAVE
    $ent{'IJlig'}       = chr(0x0132);  #  LATIN CAPITAL LIGATURE IJ
    $ent{'ijlig'}       = chr(0x0133);  #  LATIN SMALL LIGATURE IJ
    $ent{'Imacr'}       = chr(0x012A);  #  LATIN CAPITAL LETTER I WITH MACRON
    $ent{'imacr'}       = chr(0x012B);  #  LATIN SMALL LETTER I WITH MACRON
    $ent{'image'}       = chr(0x2111);  #  BLACK-LETTER CAPITAL I
    $ent{'incare'}      = chr(0x2105);  #  CARE OF
    $ent{'infin'}       = chr(0x221E);  #  INFINITY
    $ent{'inodot'}      = chr(0x0131);  #  LATIN SMALL LETTER DOTLESS I
    $ent{'int'}         = chr(0x222B);  #  INTEGRAL
    $ent{'intcal'}      = chr(0x22BA);  #  INTERCALATE
    $ent{'IOcy'}        = chr(0x0401);  #  CYRILLIC CAPITAL LETTER IO
    $ent{'iocy'}        = chr(0x0451);  #  CYRILLIC SMALL LETTER IO
    $ent{'Iogon'}       = chr(0x012E);  #  LATIN CAPITAL LETTER I WITH OGONEK
    $ent{'iogon'}       = chr(0x012F);  #  LATIN SMALL LETTER I WITH OGONEK
    $ent{'iquest'}      = chr(0x00BF);  #  INVERTED QUESTION MARK
    $ent{'isin'}        = chr(0x2208);  #  ELEMENT OF
    $ent{'Itilde'}      = chr(0x0128);  #  LATIN CAPITAL LETTER I WITH TILDE
    $ent{'itilde'}      = chr(0x0129);  #  LATIN SMALL LETTER I WITH TILDE
    $ent{'Iukcy'}       = chr(0x0406);  #  CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
    $ent{'iukcy'}       = chr(0x0456);  #  CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
    $ent{'Iuml'}        = chr(0x00CF);  #  LATIN CAPITAL LETTER I WITH DIAERESIS
    $ent{'iuml'}        = chr(0x00EF);  #  LATIN SMALL LETTER I WITH DIAERESIS
    $ent{'Jcirc'}       = chr(0x0134);  #  LATIN CAPITAL LETTER J WITH CIRCUMFLEX
    $ent{'jcirc'}       = chr(0x0135);  #  LATIN SMALL LETTER J WITH CIRCUMFLEX
    $ent{'Jcy'}         = chr(0x0419);  #  CYRILLIC CAPITAL LETTER SHORT I
    $ent{'jcy'}         = chr(0x0439);  #  CYRILLIC SMALL LETTER SHORT I
    $ent{'Jsercy'}      = chr(0x0408);  #  CYRILLIC CAPITAL LETTER JE
    $ent{'jsercy'}      = chr(0x0458);  #  CYRILLIC SMALL LETTER JE
    $ent{'Jukcy'}       = chr(0x0404);  #  CYRILLIC CAPITAL LETTER UKRAINIAN IE
    $ent{'jukcy'}       = chr(0x0454);  #  CYRILLIC SMALL LETTER UKRAINIAN IE
    $ent{'kappav'}      = chr(0x03F0);  #  GREEK KAPPA SYMBOL
    $ent{'Kcedil'}      = chr(0x0136);  #  LATIN CAPITAL LETTER K WITH CEDILLA
    $ent{'kcedil'}      = chr(0x0137);  #  LATIN SMALL LETTER K WITH CEDILLA
    $ent{'Kcy'}         = chr(0x041A);  #  CYRILLIC CAPITAL LETTER KA
    $ent{'kcy'}         = chr(0x043A);  #  CYRILLIC SMALL LETTER KA
    $ent{'Kgr'}         = chr(0x039A);  #  GREEK CAPITAL LETTER KAPPA
    $ent{'kgr'}         = chr(0x03BA);  #  GREEK SMALL LETTER KAPPA
    $ent{'kgreen'}      = chr(0x0138);  #  LATIN SMALL LETTER KRA
    $ent{'KHcy'}        = chr(0x0425);  #  CYRILLIC CAPITAL LETTER HA
    $ent{'khcy'}        = chr(0x0445);  #  CYRILLIC SMALL LETTER HA
    $ent{'KHgr'}        = chr(0x03A7);  #  GREEK CAPITAL LETTER CHI
    $ent{'khgr'}        = chr(0x03C7);  #  GREEK SMALL LETTER CHI
    $ent{'KJcy'}        = chr(0x040C);  #  CYRILLIC CAPITAL LETTER KJE
    $ent{'kjcy'}        = chr(0x045C);  #  CYRILLIC SMALL LETTER KJE
    $ent{'lAarr'}       = chr(0x21DA);  #  LEFTWARDS TRIPLE ARROW
    $ent{'Lacute'}      = chr(0x0139);  #  LATIN CAPITAL LETTER L WITH ACUTE
    $ent{'lacute'}      = chr(0x013A);  #  LATIN SMALL LETTER L WITH ACUTE
    $ent{'lagran'}      = chr(0x2112);  #  SCRIPT CAPITAL L
    $ent{'lang'}        = chr(0x2329);  #  LEFT-POINTING ANGLE BRACKET
    $ent{'laquo'}       = chr(0x00AB);  #  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    $ent{'larr'}        = chr(0x2190);  #  LEFTWARDS ARROW
    $ent{'Larr'}        = chr(0x219E);  #  LEFTWARDS TWO HEADED ARROW
    $ent{'lArr'}        = chr(0x21D0);  #  LEFTWARDS DOUBLE ARROW
    $ent{'larr2'}       = chr(0x21C7);  #  LEFTWARDS PAIRED ARROWS
    $ent{'larrhk'}      = chr(0x21A9);  #  LEFTWARDS ARROW WITH HOOK
    $ent{'larrlp'}      = chr(0x21AB);  #  LEFTWARDS ARROW WITH LOOP
    $ent{'larrtl'}      = chr(0x21A2);  #  LEFTWARDS ARROW WITH TAIL
    $ent{'Lcaron'}      = chr(0x013D);  #  LATIN CAPITAL LETTER L WITH CARON
    $ent{'lcaron'}      = chr(0x013E);  #  LATIN SMALL LETTER L WITH CARON
    $ent{'Lcedil'}      = chr(0x013B);  #  LATIN CAPITAL LETTER L WITH CEDILLA
    $ent{'lcedil'}      = chr(0x013C);  #  LATIN SMALL LETTER L WITH CEDILLA
    $ent{'lceil'}       = chr(0x2308);  #  LEFT CEILING
    $ent{'lcub'}        = chr(0x007B);  #  LEFT CURLY BRACKET
    $ent{'Lcy'}         = chr(0x041B);  #  CYRILLIC CAPITAL LETTER EL
    $ent{'lcy'}         = chr(0x043B);  #  CYRILLIC SMALL LETTER EL
    $ent{'ldot'}        = chr(0x22D6);  #  LESS-THAN WITH DOT
    $ent{'ldquo'}       = chr(0x201C);  #  LEFT DOUBLE QUOTATION MARK
    $ent{'le'}          = chr(0x2264);  #  LESS-THAN OR EQUAL TO
    $ent{'lE'}          = chr(0x2266);  #  LESS-THAN OVER EQUAL TO
    $ent{'leg'}         = chr(0x22DA);  #  LESS-THAN EQUAL TO OR GREATER-THAN
    $ent{'lfloor'}      = chr(0x230A);  #  LEFT FLOOR
    $ent{'lg'}          = chr(0x2276);  #  LESS-THAN OR GREATER-THAN
    $ent{'Lgr'}         = chr(0x039B);  #  GREEK CAPITAL LETTER LAMDA
    $ent{'lgr'}         = chr(0x03BB);  #  GREEK SMALL LETTER LAMDA
    $ent{'lhard'}       = chr(0x21BD);  #  LEFTWARDS HARPOON WITH BARB DOWNWARDS
    $ent{'lharu'}       = chr(0x21BC);  #  LEFTWARDS HARPOON WITH BARB UPWARDS
    $ent{'lhblk'}       = chr(0x2584);  #  LOWER HALF BLOCK
    $ent{'LJcy'}        = chr(0x0409);  #  CYRILLIC CAPITAL LETTER LJE
    $ent{'ljcy'}        = chr(0x0459);  #  CYRILLIC SMALL LETTER LJE
    $ent{'Ll'}          = chr(0x22D8);  #  VERY MUCH LESS-THAN
    $ent{'Lmidot'}      = chr(0x013F);  #  LATIN CAPITAL LETTER L WITH MIDDLE DOT
    $ent{'lmidot'}      = chr(0x0140);  #  LATIN SMALL LETTER L WITH MIDDLE DOT
    $ent{'lne'}         = chr(0x2268);  #  LESS-THAN BUT NOT EQUAL TO
    $ent{'lnsim'}       = chr(0x22E6);  #  LESS-THAN BUT NOT EQUIVALENT TO
    $ent{'lowast'}      = chr(0x2217);  #  ASTERISK OPERATOR
    $ent{'lowbar'}      = chr(0x005F);  #  LOW LINE
    $ent{'loz'}         = chr(0x25CA);  #  LOZENGE
    $ent{'loz'}         = chr(0x2727);  #  WHITE FOUR POINTED STAR
    $ent{'lozf'}        = chr(0x2726);  #  BLACK FOUR POINTED STAR
    $ent{'lpar'}        = chr(0x0028);  #  LEFT PARENTHESIS
    $ent{'lrarr2'}      = chr(0x21C6);  #  LEFTWARDS ARROW OVER RIGHTWARDS ARROW
    $ent{'lrhar2'}      = chr(0x21CB);  #  LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON
    $ent{'lsaquo'}      = chr(0x2039);  #  SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    $ent{'lsh'}         = chr(0x21B0);  #  UPWARDS ARROW WITH TIP LEFTWARDS
    $ent{'lsim'}        = chr(0x2272);  #  LESS-THAN OR EQUIVALENT TO
    $ent{'lsqb'}        = chr(0x005B);  #  LEFT SQUARE BRACKET
    $ent{'lsquo'}       = chr(0x2018);  #  LEFT SINGLE QUOTATION MARK
    $ent{'Lstrok'}      = chr(0x0141);  #  LATIN CAPITAL LETTER L WITH STROKE
    $ent{'lstrok'}      = chr(0x0142);  #  LATIN SMALL LETTER L WITH STROKE
    $ent{'lt'}          = chr(0x003C);  #  LESS-THAN SIGN
    $ent{'Lt'}          = chr(0x226A);  #  MUCH LESS-THAN
    $ent{'lthree'}      = chr(0x22CB);  #  LEFT SEMIDIRECT PRODUCT
    $ent{'ltimes'}      = chr(0x22C9);  #  LEFT NORMAL FACTOR SEMIDIRECT PRODUCT
    $ent{'ltri'}        = chr(0x25C3);  #  WHITE LEFT-POINTING SMALL TRIANGLE
    $ent{'ltrie'}       = chr(0x22B4);  #  NORMAL SUBGROUP OF OR EQUAL TO
    $ent{'ltrif'}       = chr(0x25C2);  #  BLACK LEFT-POINTING SMALL TRIANGLE
    $ent{'macr'}        = chr(0x00AF);  #  MACRON
    $ent{'male'}        = chr(0x2642);  #  MALE SIGN
    $ent{'malt'}        = chr(0x2720);  #  MALTESE CROSS
    $ent{'map'}         = chr(0x21A6);  #  RIGHTWARDS ARROW FROM BAR
    $ent{'marker'}      = chr(0x25AE);  #  BLACK VERTICAL RECTANGLE
    $ent{'Mcy'}         = chr(0x041C);  #  CYRILLIC CAPITAL LETTER EM
    $ent{'mcy'}         = chr(0x043C);  #  CYRILLIC SMALL LETTER EM
    $ent{'mdash'}       = chr(0x2014);  #  EM DASH
    $ent{'Mgr'}         = chr(0x039C);  #  GREEK CAPITAL LETTER MU
    $ent{'mgr'}         = chr(0x03BC);  #  GREEK SMALL LETTER MU
    $ent{'micro'}       = chr(0x00B5);  #  MICRO SIGN
    $ent{'mid'}         = chr(0x2223);  #  DIVIDES
    $ent{'middot'}      = chr(0x00B7);  #  MIDDLE DOT
    $ent{'minus'}       = chr(0x2212);  #  MINUS SIGN
    $ent{'minusb'}      = chr(0x229F);  #  SQUARED MINUS
    $ent{'mlapos'}      = chr(0x02BC);  #  MODIFIER LETTER APOSTROPHE
    $ent{'mnplus'}      = chr(0x2213);  #  MINUS-OR-PLUS SIGN
    $ent{'models'}      = chr(0x22A7);  #  MODELS
    $ent{'mumap'}       = chr(0x22B8);  #  MULTIMAP
    $ent{'nabla'}       = chr(0x2207);  #  NABLA
    $ent{'Nacute'}      = chr(0x0143);  #  LATIN CAPITAL LETTER N WITH ACUTE
    $ent{'nacute'}      = chr(0x0144);  #  LATIN SMALL LETTER N WITH ACUTE
    $ent{'nap'}         = chr(0x2249);  #  NOT ALMOST EQUAL TO
    $ent{'napos'}       = chr(0x0149);  #  LATIN SMALL LETTER N PRECEDED BY APOSTROPHE
    $ent{'natur'}       = chr(0x266E);  #  MUSIC NATURAL SIGN
    $ent{'nbsp'}        = chr(0x00A0);  #  NO-BREAK SPACE
    $ent{'Ncaron'}      = chr(0x0147);  #  LATIN CAPITAL LETTER N WITH CARON
    $ent{'ncaron'}      = chr(0x0148);  #  LATIN SMALL LETTER N WITH CARON
    $ent{'Ncedil'}      = chr(0x0145);  #  LATIN CAPITAL LETTER N WITH CEDILLA
    $ent{'ncedil'}      = chr(0x0146);  #  LATIN SMALL LETTER N WITH CEDILLA
    $ent{'ncong'}       = chr(0x2247);  #  NEITHER APPROXIMATELY NOR ACTUALLY EQUAL TO
    $ent{'Ncy'}         = chr(0x041D);  #  CYRILLIC CAPITAL LETTER EN
    $ent{'ncy'}         = chr(0x043D);  #  CYRILLIC SMALL LETTER EN
    $ent{'ndash'}       = chr(0x2013);  #  EN DASH
    $ent{'ne'}          = chr(0x2260);  #  NOT EQUAL TO
    $ent{'nearr'}       = chr(0x2197);  #  NORTH EAST ARROW
    $ent{'nequiv'}      = chr(0x2262);  #  NOT IDENTICAL TO
    $ent{'nexist'}      = chr(0x2204);  #  THERE DOES NOT EXIST
    $ent{'nge'}         = chr(0x2271);  #  NEITHER GREATER-THAN NOR EQUAL TO
    $ent{'Ngr'}         = chr(0x039D);  #  GREEK CAPITAL LETTER NU
    $ent{'ngr'}         = chr(0x03BD);  #  GREEK SMALL LETTER NU
    $ent{'ngt'}         = chr(0x226F);  #  NOT GREATER-THAN
    $ent{'nharr'}       = chr(0x21AE);  #  LEFT RIGHT ARROW WITH STROKE
    $ent{'nhArr'}       = chr(0x21CE);  #  LEFT RIGHT DOUBLE ARROW WITH STROKE
    $ent{'ni'}          = chr(0x220B);  #  CONTAINS AS MEMBER
    $ent{'NJcy'}        = chr(0x040A);  #  CYRILLIC CAPITAL LETTER NJE
    $ent{'njcy'}        = chr(0x045A);  #  CYRILLIC SMALL LETTER NJE
    $ent{'nlarr'}       = chr(0x219A);  #  LEFTWARDS ARROW WITH STROKE
    $ent{'nlArr'}       = chr(0x21CD);  #  LEFTWARDS DOUBLE ARROW WITH STROKE
    $ent{'nldr'}        = chr(0x2025);  #  TWO DOT LEADER
    $ent{'nle'}         = chr(0x2270);  #  NEITHER LESS-THAN NOR EQUAL TO
    $ent{'nlt'}         = chr(0x226E);  #  NOT LESS-THAN
    $ent{'nltri'}       = chr(0x22EA);  #  NOT NORMAL SUBGROUP OF
    $ent{'nltrie'}      = chr(0x22EC);  #  NOT NORMAL SUBGROUP OF OR EQUAL TO
    $ent{'nmid'}        = chr(0x2224);  #  DOES NOT DIVIDE
    $ent{'not'}         = chr(0x00AC);  #  NOT SIGN
    $ent{'notin'}       = chr(0x2209);  #  NOT AN ELEMENT OF
    $ent{'npar'}        = chr(0x2226);  #  NOT PARALLEL TO
    $ent{'npr'}         = chr(0x2280);  #  DOES NOT PRECEDE
    $ent{'npre'}        = chr(0x22E0);  #  DOES NOT PRECEDE OR EQUAL
    $ent{'nrarr'}       = chr(0x219B);  #  RIGHTWARDS ARROW WITH STROKE
    $ent{'nrArr'}       = chr(0x21CF);  #  RIGHTWARDS DOUBLE ARROW WITH STROKE
    $ent{'nrtri'}       = chr(0x22EB);  #  DOES NOT CONTAIN AS NORMAL SUBGROUP
    $ent{'nrtrie'}      = chr(0x22ED);  #  DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL
    $ent{'nsc'}         = chr(0x2281);  #  DOES NOT SUCCEED
    $ent{'nsce'}        = chr(0x22E1);  #  DOES NOT SUCCEED OR EQUAL
    $ent{'nsim'}        = chr(0x2241);  #  NOT TILDE
    $ent{'nsime'}       = chr(0x2244);  #  NOT ASYMPTOTICALLY EQUAL TO
    $ent{'nsub'}        = chr(0x2284);  #  NOT A SUBSET OF
    $ent{'nsube'}       = chr(0x2288);  #  NEITHER A SUBSET OF NOR EQUAL TO
    $ent{'nsup'}        = chr(0x2285);  #  NOT A SUPERSET OF
    $ent{'nsupe'}       = chr(0x2289);  #  NEITHER A SUPERSET OF NOR EQUAL TO
    $ent{'Ntilde'}      = chr(0x00D1);  #  LATIN CAPITAL LETTER N WITH TILDE
    $ent{'ntilde'}      = chr(0x00F1);  #  LATIN SMALL LETTER N WITH TILDE
    $ent{'num'}         = chr(0x0023);  #  NUMBER SIGN
    $ent{'numero'}      = chr(0x2116);  #  NUMERO SIGN
    $ent{'numsp'}       = chr(0x2007);  #  FIGURE SPACE
    $ent{'nvdash'}      = chr(0x22AC);  #  DOES NOT PROVE
    $ent{'nvDash'}      = chr(0x22AD);  #  NOT TRUE
    $ent{'nVdash'}      = chr(0x22AE);  #  DOES NOT FORCE
    $ent{'nVDash'}      = chr(0x22AF);  #  NEGATED DOUBLE VERTICAL BAR DOUBLE RIGHT
    $ent{'nwarr'}       = chr(0x2196);  #  NORTH WEST ARROW
    $ent{'Oacgr'}       = chr(0x038C);  #  GREEK CAPITAL LETTER OMICRON WITH TONOS
    $ent{'oacgr'}       = chr(0x03CC);  #  GREEK SMALL LETTER OMICRON WITH TONOS
    $ent{'Oacute'}      = chr(0x00D3);  #  LATIN CAPITAL LETTER O WITH ACUTE
    $ent{'oacute'}      = chr(0x00F3);  #  LATIN SMALL LETTER O WITH ACUTE
    $ent{'oast'}        = chr(0x229B);  #  CIRCLED ASTERISK OPERATOR
    $ent{'ocir'}        = chr(0x229A);  #  CIRCLED RING OPERATOR
    $ent{'Ocirc'}       = chr(0x00D4);  #  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
    $ent{'ocirc'}       = chr(0x00F4);  #  LATIN SMALL LETTER O WITH CIRCUMFLEX
    $ent{'Ocy'}         = chr(0x041E);  #  CYRILLIC CAPITAL LETTER O
    $ent{'ocy'}         = chr(0x043E);  #  CYRILLIC SMALL LETTER O
    $ent{'odash'}       = chr(0x229D);  #  CIRCLED DASH
    $ent{'Odblac'}      = chr(0x0150);  #  LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
    $ent{'odblac'}      = chr(0x0151);  #  LATIN SMALL LETTER O WITH DOUBLE ACUTE
    $ent{'odot'}        = chr(0x2299);  #  CIRCLED DOT OPERATOR
    $ent{'OElig'}       = chr(0x0152);  #  LATIN CAPITAL LIGATURE OE
    $ent{'oelig'}       = chr(0x0153);  #  LATIN SMALL LIGATURE OE
    $ent{'ogon'}        = chr(0x02DB);  #  OGONEK
    $ent{'Ogr'}         = chr(0x039F);  #  GREEK CAPITAL LETTER OMICRON
    $ent{'ogr'}         = chr(0x03BF);  #  GREEK SMALL LETTER OMICRON
    $ent{'Ograve'}      = chr(0x00D2);  #  LATIN CAPITAL LETTER O WITH GRAVE
    $ent{'ograve'}      = chr(0x00F2);  #  LATIN SMALL LETTER O WITH GRAVE
    $ent{'OHacgr'}      = chr(0x038F);  #  GREEK CAPITAL LETTER OMEGA WITH TONOS
    $ent{'ohacgr'}      = chr(0x03CE);  #  GREEK SMALL LETTER OMEGA WITH TONOS
    $ent{'OHgr'}        = chr(0x03A9);  #  GREEK CAPITAL LETTER OMEGA
    $ent{'ohgr'}        = chr(0x03C9);  #  GREEK SMALL LETTER OMEGA
    $ent{'ohm'}         = chr(0x2126);  #  OHM SIGN
    $ent{'olarr'}       = chr(0x21BA);  #  ANTICLOCKWISE OPEN CIRCLE ARROW
    $ent{'oline'}       = chr(0x203E);  #  OVERLINE
    $ent{'Omacr'}       = chr(0x014C);  #  LATIN CAPITAL LETTER O WITH MACRON
    $ent{'omacr'}       = chr(0x014D);  #  LATIN SMALL LETTER O WITH MACRON
    $ent{'ominus'}      = chr(0x2296);  #  CIRCLED MINUS
    $ent{'oplus'}       = chr(0x2295);  #  CIRCLED PLUS
    $ent{'or'}          = chr(0x2228);  #  LOGICAL OR
    $ent{'orarr'}       = chr(0x21BB);  #  CLOCKWISE OPEN CIRCLE ARROW
    $ent{'order'}       = chr(0x2134);  #  SCRIPT SMALL O
    $ent{'ordf'}        = chr(0x00AA);  #  FEMININE ORDINAL INDICATOR
    $ent{'ordm'}        = chr(0x00BA);  #  MASCULINE ORDINAL INDICATOR
    $ent{'oS'}          = chr(0x24C8);  #  CIRCLED LATIN CAPITAL LETTER S
    $ent{'Oslash'}      = chr(0x00D8);  #  LATIN CAPITAL LETTER O WITH STROKE
    $ent{'oslash'}      = chr(0x00F8);  #  LATIN SMALL LETTER O WITH STROKE
    $ent{'osol'}        = chr(0x2298);  #  CIRCLED DIVISION SLASH
    $ent{'Otilde'}      = chr(0x00D5);  #  LATIN CAPITAL LETTER O WITH TILDE
    $ent{'otilde'}      = chr(0x00F5);  #  LATIN SMALL LETTER O WITH TILDE
    $ent{'otimes'}      = chr(0x2297);  #  CIRCLED TIMES
    $ent{'Ouml'}        = chr(0x00D6);  #  LATIN CAPITAL LETTER O WITH DIAERESIS
    $ent{'ouml'}        = chr(0x00F6);  #  LATIN SMALL LETTER O WITH DIAERESIS
    $ent{'par'}         = chr(0x2225);  #  PARALLEL TO
    $ent{'para'}        = chr(0x00B6);  #  PILCROW SIGN
    $ent{'part'}        = chr(0x2202);  #  PARTIAL DIFFERENTIAL
    $ent{'Pcy'}         = chr(0x041F);  #  CYRILLIC CAPITAL LETTER PE
    $ent{'pcy'}         = chr(0x043F);  #  CYRILLIC SMALL LETTER PE
    $ent{'percnt'}      = chr(0x0025);  #  PERCENT SIGN
    $ent{'period'}      = chr(0x002E);  #  FULL STOP
    $ent{'permil'}      = chr(0x2030);  #  PER MILLE SIGN
    $ent{'Pgr'}         = chr(0x03A0);  #  GREEK CAPITAL LETTER PI
    $ent{'pgr'}         = chr(0x03C0);  #  GREEK SMALL LETTER PI
    $ent{'PHgr'}        = chr(0x03A6);  #  GREEK CAPITAL LETTER PHI
    $ent{'phgr'}        = chr(0x03C6);  #  GREEK SMALL LETTER PHI
    $ent{'phiv'}        = chr(0x03D5);  #  GREEK PHI SYMBOL
    $ent{'phmmat'}      = chr(0x2133);  #  SCRIPT CAPITAL M
    $ent{'phone'}       = chr(0x260E);  #  BLACK TELEPHONE
    $ent{'piv'}         = chr(0x03D6);  #  GREEK PI SYMBOL
    $ent{'planck'}      = chr(0x210F);  #  PLANCK CONSTANT OVER TWO PI
    $ent{'plus'}        = chr(0x002B);  #  PLUS SIGN
    $ent{'plusb'}       = chr(0x229E);  #  SQUARED PLUS
    $ent{'plusdo'}      = chr(0x2214);  #  DOT PLUS
    $ent{'plusmn'}      = chr(0x00B1);  #  PLUS-MINUS SIGN
    $ent{'pound'}       = chr(0x00A3);  #  POUND SIGN
    $ent{'pr'}          = chr(0x227A);  #  PRECEDES
    $ent{'pre'}         = chr(0x227C);  #  PRECEDES OR EQUAL TO
    $ent{'prime'}       = chr(0x2032);  #  PRIME
    $ent{'Prime'}       = chr(0x2033);  #  DOUBLE PRIME
    $ent{'prnsim'}      = chr(0x22E8);  #  PRECEDES BUT NOT EQUIVALENT TO
    $ent{'prod'}        = chr(0x220F);  #  N-ARY PRODUCT
    $ent{'prsim'}       = chr(0x227E);  #  PRECEDES OR EQUIVALENT TO
    $ent{'PSgr'}        = chr(0x03A8);  #  GREEK CAPITAL LETTER PSI
    $ent{'psgr'}        = chr(0x03C8);  #  GREEK SMALL LETTER PSI
    $ent{'puncsp'}      = chr(0x2008);  #  PUNCTUATION SPACE
    $ent{'quest'}       = chr(0x003F);  #  QUESTION MARK
    $ent{'quot'}        = chr(0x0022);  #  QUOTATION MARK
    $ent{'rAarr'}       = chr(0x21DB);  #  RIGHTWARDS TRIPLE ARROW
    $ent{'Racute'}      = chr(0x0154);  #  LATIN CAPITAL LETTER R WITH ACUTE
    $ent{'racute'}      = chr(0x0155);  #  LATIN SMALL LETTER R WITH ACUTE
    $ent{'radic'}       = chr(0x221A);  #  SQUARE ROOT
    $ent{'rang'}        = chr(0x232A);  #  RIGHT-POINTING ANGLE BRACKET
    $ent{'raquo'}       = chr(0x00BB);  #  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    $ent{'rarr'}        = chr(0x2192);  #  RIGHTWARDS ARROW
    $ent{'Rarr'}        = chr(0x21A0);  #  RIGHTWARDS TWO HEADED ARROW
    $ent{'rArr'}        = chr(0x21D2);  #  RIGHTWARDS DOUBLE ARROW
    $ent{'rarr2'}       = chr(0x21C9);  #  RIGHTWARDS PAIRED ARROWS
    $ent{'rarrhk'}      = chr(0x21AA);  #  RIGHTWARDS ARROW WITH HOOK
    $ent{'rarrlp'}      = chr(0x21AC);  #  RIGHTWARDS ARROW WITH LOOP
    $ent{'rarrtl'}      = chr(0x21A3);  #  RIGHTWARDS ARROW WITH TAIL
    $ent{'rarrw'}       = chr(0x219D);  #  RIGHTWARDS WAVE ARROW
    $ent{'Rcaron'}      = chr(0x0158);  #  LATIN CAPITAL LETTER R WITH CARON
    $ent{'rcaron'}      = chr(0x0159);  #  LATIN SMALL LETTER R WITH CARON
    $ent{'Rcedil'}      = chr(0x0156);  #  LATIN CAPITAL LETTER R WITH CEDILLA
    $ent{'rcedil'}      = chr(0x0157);  #  LATIN SMALL LETTER R WITH CEDILLA
    $ent{'rceil'}       = chr(0x2309);  #  RIGHT CEILING
    $ent{'rcub'}        = chr(0x007D);  #  RIGHT CURLY BRACKET
    $ent{'Rcy'}         = chr(0x0420);  #  CYRILLIC CAPITAL LETTER ER
    $ent{'rcy'}         = chr(0x0440);  #  CYRILLIC SMALL LETTER ER
    $ent{'rdquo'}       = chr(0x201D);  #  RIGHT DOUBLE QUOTATION MARK
    $ent{'real'}        = chr(0x211C);  #  BLACK-LETTER CAPITAL R
    $ent{'rect'}        = chr(0x25AD);  #  WHITE RECTANGLE
    $ent{'reg'}         = chr(0x00AE);  #  REGISTERED SIGN
    $ent{'rfloor'}      = chr(0x230B);  #  RIGHT FLOOR
    $ent{'Rgr'}         = chr(0x03A1);  #  GREEK CAPITAL LETTER RHO
    $ent{'rgr'}         = chr(0x03C1);  #  GREEK SMALL LETTER RHO
    $ent{'rhard'}       = chr(0x21C1);  #  RIGHTWARDS HARPOON WITH BARB DOWNWARDS
    $ent{'rharu'}       = chr(0x21C0);  #  RIGHTWARDS HARPOON WITH BARB UPWARDS
    $ent{'rhov'}        = chr(0x03F1);  #  GREEK RHO SYMBOL
    $ent{'ring'}        = chr(0x02DA);  #  RING ABOVE
    $ent{'rlarr2'}      = chr(0x21C4);  #  RIGHTWARDS ARROW OVER LEFTWARDS ARROW
    $ent{'rlhar2'}      = chr(0x21CC);  #  RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    $ent{'rpar'}        = chr(0x0029);  #  RIGHT PARENTHESIS
    $ent{'rsaquo'}      = chr(0x203A);  #  SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    $ent{'rsh'}         = chr(0x21B1);  #  UPWARDS ARROW WITH TIP RIGHTWARDS
    $ent{'rsqb'}        = chr(0x005D);  #  RIGHT SQUARE BRACKET
    $ent{'rsquo'}       = chr(0x2019);  #  RIGHT SINGLE QUOTATION MARK
    $ent{'rthree'}      = chr(0x22CC);  #  RIGHT SEMIDIRECT PRODUCT
    $ent{'rtimes'}      = chr(0x22CA);  #  RIGHT NORMAL FACTOR SEMIDIRECT PRODUCT
    $ent{'rtri'}        = chr(0x25B9);  #  WHITE RIGHT-POINTING SMALL TRIANGLE
    $ent{'rtrie'}       = chr(0x22B5);  #  CONTAINS AS NORMAL SUBGROUP OR EQUAL TO
    $ent{'rtrif'}       = chr(0x25B8);  #  BLACK RIGHT-POINTING SMALL TRIANGLE
    $ent{'rx'}          = chr(0x211E);  #  PRESCRIPTION TAKE
    $ent{'Sacute'}      = chr(0x015A);  #  LATIN CAPITAL LETTER S WITH ACUTE
    $ent{'sacute'}      = chr(0x015B);  #  LATIN SMALL LETTER S WITH ACUTE
    $ent{'sbquo'}       = chr(0x201A);  #  SINGLE LOW-9 QUOTATION MARK
    $ent{'sc'}          = chr(0x227B);  #  SUCCEEDS
    $ent{'Scaron'}      = chr(0x0160);  #  LATIN CAPITAL LETTER S WITH CARON
    $ent{'scaron'}      = chr(0x0161);  #  LATIN SMALL LETTER S WITH CARON
    $ent{'sce'}         = chr(0x227D);  #  SUCCEEDS OR EQUAL TO
    $ent{'Scedil'}      = chr(0x015E);  #  LATIN CAPITAL LETTER S WITH CEDILLA
    $ent{'scedil'}      = chr(0x015F);  #  LATIN SMALL LETTER S WITH CEDILLA
    $ent{'Scirc'}       = chr(0x015C);  #  LATIN CAPITAL LETTER S WITH CIRCUMFLEX
    $ent{'scirc'}       = chr(0x015D);  #  LATIN SMALL LETTER S WITH CIRCUMFLEX
    $ent{'scnsim'}      = chr(0x22E9);  #  SUCCEEDS BUT NOT EQUIVALENT TO
    $ent{'scsim'}       = chr(0x227F);  #  SUCCEEDS OR EQUIVALENT TO
    $ent{'Scy'}         = chr(0x0421);  #  CYRILLIC CAPITAL LETTER ES
    $ent{'scy'}         = chr(0x0441);  #  CYRILLIC SMALL LETTER ES
    $ent{'sdot'}        = chr(0x22C5);  #  DOT OPERATOR
    $ent{'sdotb'}       = chr(0x22A1);  #  SQUARED DOT OPERATOR
    $ent{'sect'}        = chr(0x00A7);  #  SECTION SIGN
    $ent{'semi'}        = chr(0x003B);  #  SEMICOLON
    $ent{'setmn'}       = chr(0x2216);  #  SET MINUS
    $ent{'sext'}        = chr(0x2736);  #  SIX POINTED BLACK STAR
    $ent{'sfgr'}        = chr(0x03C2);  #  GREEK SMALL LETTER FINAL SIGMA
    $ent{'Sgr'}         = chr(0x03A3);  #  GREEK CAPITAL LETTER SIGMA
    $ent{'sgr'}         = chr(0x03C3);  #  GREEK SMALL LETTER SIGMA
    $ent{'sharp'}       = chr(0x266F);  #  MUSIC SHARP SIGN
    $ent{'SHCHcy'}      = chr(0x0429);  #  CYRILLIC CAPITAL LETTER SHCHA
    $ent{'shchcy'}      = chr(0x0449);  #  CYRILLIC SMALL LETTER SHCHA
    $ent{'SHcy'}        = chr(0x0428);  #  CYRILLIC CAPITAL LETTER SHA
    $ent{'shcy'}        = chr(0x0448);  #  CYRILLIC SMALL LETTER SHA
    $ent{'shy'}         = chr(0x00AD);  #  SOFT HYPHEN
    $ent{'sim'}         = chr(0x223C);  #  TILDE OPERATOR
    $ent{'sime'}        = chr(0x2243);  #  ASYMPTOTICALLY EQUAL TO
    $ent{'smile'}       = chr(0x2323);  #  SMILE
    $ent{'SOFTcy'}      = chr(0x042C);  #  CYRILLIC CAPITAL LETTER SOFT SIGN
    $ent{'softcy'}      = chr(0x044C);  #  CYRILLIC SMALL LETTER SOFT SIGN
    $ent{'sol'}         = chr(0x002F);  #  SOLIDUS
    $ent{'spades'}      = chr(0x2660);  #  BLACK SPADE SUIT
    $ent{'sqcap'}       = chr(0x2293);  #  SQUARE CAP
    $ent{'sqcup'}       = chr(0x2294);  #  SQUARE CUP
    $ent{'sqsub'}       = chr(0x228F);  #  SQUARE IMAGE OF
    $ent{'sqsube'}      = chr(0x2291);  #  SQUARE IMAGE OF OR EQUAL TO
    $ent{'sqsup'}       = chr(0x2290);  #  SQUARE ORIGINAL OF
    $ent{'sqsupe'}      = chr(0x2292);  #  SQUARE ORIGINAL OF OR EQUAL TO
    $ent{'square'}      = chr(0x25A1);  #  WHITE SQUARE
    $ent{'squf'}        = chr(0x25AA);  #  BLACK SMALL SQUARE
    $ent{'sstarf'}      = chr(0x22C6);  #  STAR OPERATOR
    $ent{'star'}        = chr(0x2606);  #  WHITE STAR
    $ent{'starf'}       = chr(0x2605);  #  BLACK STAR
    $ent{'sub'}         = chr(0x2282);  #  SUBSET OF
    $ent{'Sub'}         = chr(0x22D0);  #  DOUBLE SUBSET
    $ent{'sube'}        = chr(0x2286);  #  SUBSET OF OR EQUAL TO
    $ent{'subne'}       = chr(0x228A);  #  SUBSET OF WITH NOT EQUAL TO
    $ent{'sum'}         = chr(0x2211);  #  N-ARY SUMMATION
    $ent{'sung'}        = chr(0x266A);  #  EIGHTH NOTE
    $ent{'sup'}         = chr(0x2283);  #  SUPERSET OF
    $ent{'Sup'}         = chr(0x22D1);  #  DOUBLE SUPERSET
    $ent{'sup0'}        = chr(0x2070);  #  SUPERSCRIPT ZERO
    $ent{'sup1'}        = chr(0x00B9);  #  SUPERSCRIPT ONE
    $ent{'sup2'}        = chr(0x00B2);  #  SUPERSCRIPT TWO
    $ent{'sup3'}        = chr(0x00B3);  #  SUPERSCRIPT THREE
    $ent{'sup4'}        = chr(0x2074);  #  SUPERSCRIPT FOUR
    $ent{'sup5'}        = chr(0x2075);  #  SUPERSCRIPT FIVE
    $ent{'sup6'}        = chr(0x2076);  #  SUPERSCRIPT SIX
    $ent{'sup7'}        = chr(0x2077);  #  SUPERSCRIPT SEVEN
    $ent{'sup8'}        = chr(0x2078);  #  SUPERSCRIPT EIGHT
    $ent{'sup9'}        = chr(0x2079);  #  SUPERSCRIPT NINE
    $ent{'supe'}        = chr(0x2287);  #  SUPERSET OF OR EQUAL TO
    $ent{'supmin'}      = chr(0x207B);  #  SUPERSCRIPT MINUS
    $ent{'supi'}        = chr(0x2071);  #  SUPERSCRIPT LATIN SMALL LETTER I
    $ent{'supw'}        = chr(0x02B7);  #  MODIFIER LETTER SMALL W
    $ent{'supne'}       = chr(0x228B);  #  SUPERSET OF WITH NOT EQUAL TO
    $ent{'szlig'}       = chr(0x00DF);  #  LATIN SMALL LETTER SHARP S
    $ent{'target'}      = chr(0x2316);  #  POSITION INDICATOR
    $ent{'Tcaron'}      = chr(0x0164);  #  LATIN CAPITAL LETTER T WITH CARON
    $ent{'tcaron'}      = chr(0x0165);  #  LATIN SMALL LETTER T WITH CARON
    $ent{'Tcedil'}      = chr(0x0162);  #  LATIN CAPITAL LETTER T WITH CEDILLA
    $ent{'tcedil'}      = chr(0x0163);  #  LATIN SMALL LETTER T WITH CEDILLA
    $ent{'Tcy'}         = chr(0x0422);  #  CYRILLIC CAPITAL LETTER TE
    $ent{'tcy'}         = chr(0x0442);  #  CYRILLIC SMALL LETTER TE
    $ent{'tdot'}        = chr(0x20DB);  #  COMBINING THREE DOTS ABOVE
    $ent{'telrec'}      = chr(0x2315);  #  TELEPHONE RECORDER
    $ent{'Tgr'}         = chr(0x03A4);  #  GREEK CAPITAL LETTER TAU
    $ent{'tgr'}         = chr(0x03C4);  #  GREEK SMALL LETTER TAU
    $ent{'there4'}      = chr(0x2234);  #  THEREFORE
    $ent{'thetasym'}    = chr(0x03D1);  #  GREEK THETA SYMBOL
    $ent{'THgr'}        = chr(0x0398);  #  GREEK CAPITAL LETTER THETA
    $ent{'thgr'}        = chr(0x03B8);  #  GREEK SMALL LETTER THETA
    $ent{'thinsp'}      = chr(0x2009);  #  THIN SPACE
    $ent{'THORN'}       = chr(0x00DE);  #  LATIN CAPITAL LETTER THORN
    $ent{'thorn'}       = chr(0x00FE);  #  LATIN SMALL LETTER THORN
    $ent{'tilde'}       = chr(0x02DC);  #  SMALL TILDE
    $ent{'times'}       = chr(0x00D7);  #  MULTIPLICATION SIGN
    $ent{'timesb'}      = chr(0x22A0);  #  SQUARED TIMES
    $ent{'top'}         = chr(0x22A4);  #  DOWN TACK
    $ent{'tprime'}      = chr(0x2034);  #  TRIPLE PRIME
    $ent{'trade'}       = chr(0x2122);  #  TRADE MARK SIGN
    $ent{'trie'}        = chr(0x225C);  #  DELTA EQUAL TO
    $ent{'TScy'}        = chr(0x0426);  #  CYRILLIC CAPITAL LETTER TSE
    $ent{'tscy'}        = chr(0x0446);  #  CYRILLIC SMALL LETTER TSE
    $ent{'TSHcy'}       = chr(0x040B);  #  CYRILLIC CAPITAL LETTER TSHE
    $ent{'tshcy'}       = chr(0x045B);  #  CYRILLIC SMALL LETTER TSHE
    $ent{'Tstrok'}      = chr(0x0166);  #  LATIN CAPITAL LETTER T WITH STROKE
    $ent{'tstrok'}      = chr(0x0167);  #  LATIN SMALL LETTER T WITH STROKE
    $ent{'twixt'}       = chr(0x226C);  #  BETWEEN
    $ent{'Uacgr'}       = chr(0x038E);  #  GREEK CAPITAL LETTER UPSILON WITH TONOS
    $ent{'uacgr'}       = chr(0x03CD);  #  GREEK SMALL LETTER UPSILON WITH TONOS
    $ent{'Uacute'}      = chr(0x00DA);  #  LATIN CAPITAL LETTER U WITH ACUTE
    $ent{'uacute'}      = chr(0x00FA);  #  LATIN SMALL LETTER U WITH ACUTE
    $ent{'uarr'}        = chr(0x2191);  #  UPWARDS ARROW
    $ent{'uArr'}        = chr(0x21D1);  #  UPWARDS DOUBLE ARROW
    $ent{'uarr2'}       = chr(0x21C8);  #  UPWARDS PAIRED ARROWS
    $ent{'Ubrcy'}       = chr(0x040E);  #  CYRILLIC CAPITAL LETTER SHORT U
    $ent{'ubrcy'}       = chr(0x045E);  #  CYRILLIC SMALL LETTER SHORT U
    $ent{'Ubreve'}      = chr(0x016C);  #  LATIN CAPITAL LETTER U WITH BREVE
    $ent{'ubreve'}      = chr(0x016D);  #  LATIN SMALL LETTER U WITH BREVE
    $ent{'Ucirc'}       = chr(0x00DB);  #  LATIN CAPITAL LETTER U WITH CIRCUMFLEX
    $ent{'ucirc'}       = chr(0x00FB);  #  LATIN SMALL LETTER U WITH CIRCUMFLEX
    $ent{'Ucy'}         = chr(0x0423);  #  CYRILLIC CAPITAL LETTER U
    $ent{'ucy'}         = chr(0x0443);  #  CYRILLIC SMALL LETTER U
    $ent{'Udblac'}      = chr(0x0170);  #  LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
    $ent{'udblac'}      = chr(0x0171);  #  LATIN SMALL LETTER U WITH DOUBLE ACUTE
    $ent{'udiagr'}      = chr(0x03B0);  #  GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND
    $ent{'Udigr'}       = chr(0x03AB);  #  GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA
    $ent{'udigr'}       = chr(0x03CB);  #  GREEK SMALL LETTER UPSILON WITH DIALYTIKA
    $ent{'Ugr'}         = chr(0x03A5);  #  GREEK CAPITAL LETTER UPSILON
    $ent{'ugr'}         = chr(0x03C5);  #  GREEK SMALL LETTER UPSILON
    $ent{'Ugrave'}      = chr(0x00D9);  #  LATIN CAPITAL LETTER U WITH GRAVE
    $ent{'ugrave'}      = chr(0x00F9);  #  LATIN SMALL LETTER U WITH GRAVE
    $ent{'uharl'}       = chr(0x21BF);  #  UPWARDS HARPOON WITH BARB LEFTWARDS
    $ent{'uharr'}       = chr(0x21BE);  #  UPWARDS HARPOON WITH BARB RIGHTWARDS
    $ent{'uhblk'}       = chr(0x2580);  #  UPPER HALF BLOCK
    $ent{'ulcorn'}      = chr(0x231C);  #  TOP LEFT CORNER
    $ent{'ulcrop'}      = chr(0x230F);  #  TOP LEFT CROP
    $ent{'Umacr'}       = chr(0x016A);  #  LATIN CAPITAL LETTER U WITH MACRON
    $ent{'umacr'}       = chr(0x016B);  #  LATIN SMALL LETTER U WITH MACRON
    $ent{'uml'}         = chr(0x00A8);  #  DIAERESIS
    $ent{'Uogon'}       = chr(0x0172);  #  LATIN CAPITAL LETTER U WITH OGONEK
    $ent{'uogon'}       = chr(0x0173);  #  LATIN SMALL LETTER U WITH OGONEK
    $ent{'uplus'}       = chr(0x228E);  #  MULTISET UNION
    $ent{'upsih'}       = chr(0x03D2);  #  GREEK UPSILON WITH HOOK SYMBOL
    $ent{'urcorn'}      = chr(0x231D);  #  TOP RIGHT CORNER
    $ent{'urcrop'}      = chr(0x230E);  #  TOP RIGHT CROP
    $ent{'Uring'}       = chr(0x016E);  #  LATIN CAPITAL LETTER U WITH RING ABOVE
    $ent{'uring'}       = chr(0x016F);  #  LATIN SMALL LETTER U WITH RING ABOVE
    $ent{'Utilde'}      = chr(0x0168);  #  LATIN CAPITAL LETTER U WITH TILDE
    $ent{'utilde'}      = chr(0x0169);  #  LATIN SMALL LETTER U WITH TILDE
    $ent{'utri'}        = chr(0x25B5);  #  WHITE UP-POINTING SMALL TRIANGLE
    $ent{'utrif'}       = chr(0x25B4);  #  BLACK UP-POINTING SMALL TRIANGLE
    $ent{'Uuml'}        = chr(0x00DC);  #  LATIN CAPITAL LETTER U WITH DIAERESIS
    $ent{'uuml'}        = chr(0x00FC);  #  LATIN SMALL LETTER U WITH DIAERESIS
    $ent{'varr'}        = chr(0x2195);  #  UP DOWN ARROW
    $ent{'vArr'}        = chr(0x21D5);  #  UP DOWN DOUBLE ARROW
    $ent{'Vcy'}         = chr(0x0412);  #  CYRILLIC CAPITAL LETTER VE
    $ent{'vcy'}         = chr(0x0432);  #  CYRILLIC SMALL LETTER VE
    $ent{'vdash'}       = chr(0x22A2);  #  RIGHT TACK
    $ent{'vDash'}       = chr(0x22A8);  #  TRUE
    $ent{'Vdash'}       = chr(0x22A9);  #  FORCES
    $ent{'veebar'}      = chr(0x22BB);  #  XOR
    $ent{'vellip'}      = chr(0x22EE);  #  VERTICAL ELLIPSIS
    $ent{'verbar'}      = chr(0x007C);  #  VERTICAL LINE
    $ent{'Verbar'}      = chr(0x2016);  #  DOUBLE VERTICAL LINE
    $ent{'vltri'}       = chr(0x22B2);  #  NORMAL SUBGROUP OF
    $ent{'vprop'}       = chr(0x221D);  #  PROPORTIONAL TO
    $ent{'vrtri'}       = chr(0x22B3);  #  CONTAINS AS NORMAL SUBGROUP
    $ent{'Vvdash'}      = chr(0x22AA);  #  TRIPLE VERTICAL BAR RIGHT TURNSTILE
    $ent{'Wcirc'}       = chr(0x0174);  #  LATIN CAPITAL LETTER W WITH CIRCUMFLEX
    $ent{'wcirc'}       = chr(0x0175);  #  LATIN SMALL LETTER W WITH CIRCUMFLEX
    $ent{'wedgeq'}      = chr(0x2259);  #  ESTIMATES
    $ent{'weierp'}      = chr(0x2118);  #  SCRIPT CAPITAL P
    $ent{'wreath'}      = chr(0x2240);  #  WREATH PRODUCT
    $ent{'Xgr'}         = chr(0x039E);  #  GREEK CAPITAL LETTER XI
    $ent{'xgr'}         = chr(0x03BE);  #  GREEK SMALL LETTER XI
    $ent{'Yacute'}      = chr(0x00DD);  #  LATIN CAPITAL LETTER Y WITH ACUTE
    $ent{'yacute'}      = chr(0x00FD);  #  LATIN SMALL LETTER Y WITH ACUTE
    $ent{'YAcy'}        = chr(0x042F);  #  CYRILLIC CAPITAL LETTER YA
    $ent{'yacy'}        = chr(0x044F);  #  CYRILLIC SMALL LETTER YA
    $ent{'Ycirc'}       = chr(0x0176);  #  LATIN CAPITAL LETTER Y WITH CIRCUMFLEX
    $ent{'ycirc'}       = chr(0x0177);  #  LATIN SMALL LETTER Y WITH CIRCUMFLEX
    $ent{'Ycy'}         = chr(0x042B);  #  CYRILLIC CAPITAL LETTER YERU
    $ent{'ycy'}         = chr(0x044B);  #  CYRILLIC SMALL LETTER YERU
    $ent{'yen'}         = chr(0x00A5);  #  YEN SIGN
    $ent{'YIcy'}        = chr(0x0407);  #  CYRILLIC CAPITAL LETTER YI
    $ent{'yicy'}        = chr(0x0457);  #  CYRILLIC SMALL LETTER YI
    $ent{'YUcy'}        = chr(0x042E);  #  CYRILLIC CAPITAL LETTER YU
    $ent{'yucy'}        = chr(0x044E);  #  CYRILLIC SMALL LETTER YU
    $ent{'yuml'}        = chr(0x00FF);  #  LATIN SMALL LETTER Y WITH DIAERESIS
    $ent{'Yuml'}        = chr(0x0178);  #  LATIN CAPITAL LETTER Y WITH DIAERESIS
    $ent{'Zacute'}      = chr(0x0179);  #  LATIN CAPITAL LETTER Z WITH ACUTE
    $ent{'zacute'}      = chr(0x017A);  #  LATIN SMALL LETTER Z WITH ACUTE
    $ent{'Zcaron'}      = chr(0x017D);  #  LATIN CAPITAL LETTER Z WITH CARON
    $ent{'zcaron'}      = chr(0x017E);  #  LATIN SMALL LETTER Z WITH CARON
    $ent{'Zcy'}         = chr(0x0417);  #  CYRILLIC CAPITAL LETTER ZE
    $ent{'zcy'}         = chr(0x0437);  #  CYRILLIC SMALL LETTER ZE
    $ent{'Zdot'}        = chr(0x017B);  #  LATIN CAPITAL LETTER Z WITH DOT ABOVE
    $ent{'zdot'}        = chr(0x017C);  #  LATIN SMALL LETTER Z WITH DOT ABOVE
    $ent{'Zgr'}         = chr(0x0396);  #  GREEK CAPITAL LETTER ZETA
    $ent{'zgr'}         = chr(0x03B6);  #  GREEK SMALL LETTER ZETA
    $ent{'ZHcy'}        = chr(0x0416);  #  CYRILLIC CAPITAL LETTER ZHE
    $ent{'zhcy'}        = chr(0x0436);  #  CYRILLIC SMALL LETTER ZHE
    $ent{'zwsp'}        = chr(0x200B);  #  ZERO WIDTH SPACE
    $ent{'zwj'}         = chr(0x200D);  #  ZERO WIDTH JOINER
    $ent{'zwnj'}        = chr(0x200C);  #  ZERO WIDTH NON-JOINER


    # Vietnamese

    $ent{'Ohorn'}        = chr(0x01A0);  #  LATIN CAPITAL LETTER O WITH HORN
    $ent{'ohorn'}        = chr(0x01A1);  #  LATIN SMALL LETTER O WITH HORN
    $ent{'Ohogr'}        = chr(0x1EDC);  #  LATIN CAPITAL LETTER O WITH HORN AND GRAVE
    $ent{'ohogr'}        = chr(0x1EDD);  #  LATIN SMALL LETTER O WITH HORN AND GRAVE
    $ent{'Ohoac'}        = chr(0x1EDA);  #  LATIN CAPITAL LETTER O WITH HORN AND ACUTE
    $ent{'ohoac'}        = chr(0x1EDB);  #  LATIN SMALL LETTER O WITH HORN AND ACUTE
    $ent{'Ohohk'}        = chr(0x1EDE);  #  LATIN CAPITAL LETTER O WITH HORN AND HOOK ABOVE
    $ent{'ohohk'}        = chr(0x1EDF);  #  LATIN SMALL LETTER O WITH HORN AND HOOK ABOVE
    $ent{'Ohotl'}        = chr(0x1EE0);  #  LATIN CAPITAL LETTER O WITH HORN AND TILDE
    $ent{'ohotl'}        = chr(0x1EE1);  #  LATIN SMALL LETTER O WITH HORN AND TILDE
    $ent{'Ohodb'}        = chr(0x1EE2);  #  LATIN CAPITAL LETTER O WITH HORN AND DOT BELOW
    $ent{'ohodb'}        = chr(0x1EE3);  #  LATIN SMALL LETTER O WITH HORN AND DOT BELOW

    $ent{'Uhorn'}        = chr(0x01AF);  #  LATIN CAPITAL LETTER U WITH HORN
    $ent{'uhorn'}        = chr(0x01B0);  #  LATIN SMALL LETTER U WITH HORN
    $ent{'Uhogr'}        = chr(0x1EEA);  #  LATIN CAPITAL LETTER U WITH HORN AND GRAVE
    $ent{'uhogr'}        = chr(0x1EEB);  #  LATIN SMALL LETTER U WITH HORN AND GRAVE
    $ent{'Uhoac'}        = chr(0x1EE8);  #  LATIN CAPITAL LETTER U WITH HORN AND ACUTE
    $ent{'uhoac'}        = chr(0x1EE9);  #  LATIN SMALL LETTER U WITH HORN AND ACUTE
    $ent{'Uhohk'}        = chr(0x1EEC);  #  LATIN CAPITAL LETTER U WITH HORN AND HOOK ABOVE
    $ent{'uhohk'}        = chr(0x1EED);  #  LATIN SMALL LETTER U WITH HORN AND HOOK ABOVE
    $ent{'Uhotl'}        = chr(0x1EEE);  #  LATIN CAPITAL LETTER U WITH HORN AND TILDE
    $ent{'uhotl'}        = chr(0x1EEF);  #  LATIN SMALL LETTER U WITH HORN AND TILDE
    $ent{'Uhodb'}        = chr(0x1EF0);  #  LATIN CAPITAL LETTER U WITH HORN AND DOT BELOW
    $ent{'uhodb'}        = chr(0x1EF1);  #  LATIN SMALL LETTER U WITH HORN AND DOT BELOW

    $ent{'Abrgr'}        = chr(0x1EB0);  #  LATIN CAPITAL LETTER A WITH BREVE AND GRAVE
    $ent{'abrgr'}        = chr(0x1EB1);  #  LATIN SMALL LETTER A WITH BREVE AND GRAVE

    $ent{'Acihk'}        = chr(0x1EA8);  #  LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND HOOK ABOVE
    $ent{'acihk'}        = chr(0x1EA9);  #  LATIN SMALL LETTER A WITH CIRCUMFLEX AND HOOK ABOVE

    $ent{'Ocihk'}        = chr(0x1ED4);  #  LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND HOOK ABOVE
    $ent{'ocihk'}        = chr(0x1ED5);  #  LATIN SMALL LETTER O WITH CIRCUMFLEX AND HOOK ABOVE

    $ent{'Ociac'}        = chr(0x1ED0);  #  LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND ACUTE
    $ent{'ociac'}        = chr(0x1ED1);  #  LATIN SMALL LETTER O WITH CIRCUMFLEX AND ACUTE


    # African clicks

    $ent{'dclick'}       = chr(0x01C0);  #  LATIN LETTER DENTAL CLICK
    $ent{'lclick'}       = chr(0x01C1);  #  LATIN LETTER LATERAL CLICK
    $ent{'aclick'}       = chr(0x01C2);  #  LATIN LETTER ALVEOLAR CLICK
    $ent{'rclick'}       = chr(0x01C3);  #  LATIN LETTER RETROFLEX CLICK


    ###############################################################################
    ## GREEK ENTITIES REMAPPED:

    $ent{'agr'}         = chr(0x03b1); # "a"
    $ent{'Agr'}         = chr(0x0391); # "A"
    $ent{'aiotgr'}      = chr(0x1fb3); # "a|"
    $ent{'Aiotgr'}      = chr(0x1fbc); # "A|"
    $ent{'arigr'}       = chr(0x1f81); # "<a|"
    $ent{'Arigr'}       = chr(0x1f89); # "<A|"
    $ent{'asigr'}       = chr(0x1f80); # ">a|"
    $ent{'Asigr'}       = chr(0x1f88); # ">A|"
    $ent{'aaigr'}       = chr(0x1fb4); # "'a|"
    $ent{'Aaigr'}       = chr(0x0391) . chr(0x0301) . chr(0x0345); # "'A|"
    $ent{'agigr'}       = chr(0x1fb2); # "`a|"
    $ent{'Agigr'}       = chr(0x0391) . chr(0x0300) . chr(0x0345); # "`A|"
    $ent{'acigr'}       = chr(0x1fb7); # "=a|"
    $ent{'Acigr'}       = chr(0x0391) . chr(0x0342) . chr(0x0345); # "=A|"
    $ent{'araigr'}      = chr(0x1f85); # "<'a|"
    $ent{'Araigr'}      = chr(0x1f8d); # "<'A|"
    $ent{'asaigr'}      = chr(0x1f84); # ">'a|"
    $ent{'Asaigr'}      = chr(0x1f8c); # ">'A|"
    $ent{'argigr'}      = chr(0x1f83); # "<`a|"
    $ent{'Argigr'}      = chr(0x1f8b); # "<`A|"
    $ent{'asgigr'}      = chr(0x1f82); # ">`a|"
    $ent{'Asgigr'}      = chr(0x1f8a); # ">`A|"
    $ent{'arcigr'}      = chr(0x1f87); # "<=a|"
    $ent{'Arcigr'}      = chr(0x1f8f); # "<=A|"
    $ent{'ascigr'}      = chr(0x1f86); # ">=a|"
    $ent{'Ascigr'}      = chr(0x1f8e); # ">=A|"
    $ent{'arougr'}      = chr(0x1f01); # "<a"
    $ent{'Arougr'}      = chr(0x1f09); # "<A"
    $ent{'asmogr'}      = chr(0x1f00); # ">a"
    $ent{'Asmogr'}      = chr(0x1f08); # ">A"
    $ent{'agragr'}      = chr(0x1f70); # "`a"
    $ent{'Agragr'}      = chr(0x1fba); # "`A"
    $ent{'aacugr'}      = chr(0x1f71); # "'a"
    $ent{'Aacugr'}      = chr(0x1fbb); # "'A"
    $ent{'acirgr'}      = chr(0x1fb6); # "=a"
    $ent{'Acirgr'}      = chr(0x0391) . chr(0x0342); # "=A"
    $ent{'aragr'}       = chr(0x1f05); # "<'a"
    $ent{'Aragr'}       = chr(0x1f0d); # "<'A"
    $ent{'asagr'}       = chr(0x1f04); # ">'a"
    $ent{'Asagr'}       = chr(0x1f0c); # ">'A"
    $ent{'arggr'}       = chr(0x1f03); # "<`a"
    $ent{'Arggr'}       = chr(0x1f0b); # "<`A"
    $ent{'asggr'}       = chr(0x1f02); # ">`a"
    $ent{'Asggr'}       = chr(0x1f0a); # ">`A"
    $ent{'arcgr'}       = chr(0x1f07); # "<=a"
    $ent{'Arcgr'}       = chr(0x1f0f); # "<=A"
    $ent{'ascgr'}       = chr(0x1f06); # ">=a"
    $ent{'Ascgr'}       = chr(0x1f0e); # ">=A"

    $ent{'bgr'}         = chr(0x03b2); # "b"
    $ent{'Bgr'}         = chr(0x0392); # "B"

    $ent{'ggr'}         = chr(0x03b3); # "g"
    $ent{'Ggr'}         = chr(0x0393); # "G"

    $ent{'dgr'}         = chr(0x03b4); # "d"
    $ent{'Dgr'}         = chr(0x0394); # "D"

    $ent{'egr'}         = chr(0x03b5); # "e"
    $ent{'Egr'}         = chr(0x0395); # "E"
    $ent{'erougr'}      = chr(0x1f11); # "<e"
    $ent{'Erougr'}      = chr(0x1f19); # "<E"
    $ent{'esmogr'}      = chr(0x1f10); # ">e"
    $ent{'Esmogr'}      = chr(0x1f18); # ">E"
    $ent{'egragr'}      = chr(0x1f72); # "`e"
    $ent{'Egragr'}      = chr(0x1fc8); # "`E"
    $ent{'eacugr'}      = chr(0x1f73); # "'e"
    $ent{'Eacugr'}      = chr(0x1fc9); # "'E"
    $ent{'ecirgr'}      = chr(0x3b5) . chr(0x342); # "=e"
    $ent{'Ecirgr'}      = chr(0x395) . chr(0x342); # "=E"
    $ent{'eragr'}       = chr(0x1f15); # "<'e"
    $ent{'Eragr'}       = chr(0x1f1d); # "<'E"
    $ent{'esagr'}       = chr(0x1f14); # ">'e"
    $ent{'Esagr'}       = chr(0x1f1c); # ">'E"
    $ent{'erggr'}       = chr(0x1f13); # "<`e"
    $ent{'Erggr'}       = chr(0x1f1b); # "<`E"
    $ent{'esggr'}       = chr(0x1f12); # ">`e"
    $ent{'Esggr'}       = chr(0x1f1a); # ">`E"
    $ent{'ercgr'}       = chr(0x03b5) . chr(0x0314) . chr(0x0342); # "<=e"
    $ent{'Ercgr'}       = chr(0x0395) . chr(0x0314) . chr(0x0342); # "<=E"
    $ent{'escgr'}       = chr(0x03b5) . chr(0x0313) . chr(0x0342); # ">=e"
    $ent{'Escgr'}       = chr(0x0395) . chr(0x0313) . chr(0x0342); # ">=E"

    $ent{'zgr'}         = chr(0x03b6); # "z"
    $ent{'Zgr'}         = chr(0x0396); # "Z"

    $ent{'eegr'}        = chr(0x03b7); # "h"
    $ent{'EEgr'}        = chr(0x0397); # "H"
    $ent{'eeiotgr'}     = chr(0x1fc3); # "h|"
    $ent{'EEiotgr'}     = chr(0x1fcc); # "H|"
    $ent{'eerigr'}      = chr(0x1f91); # "<h|"
    $ent{'EErigr'}      = chr(0x1f99); # "<H|"
    $ent{'eesigr'}      = chr(0x1f90); # ">h|"
    $ent{'EEsigr'}      = chr(0x1f98); # ">H|"
    $ent{'eeaigr'}      = chr(0x1fc4); # "'h|"
    $ent{'EEaigr'}      = chr(0x397) . chr(0x301) . chr(0x345); # "'H|"
    $ent{'eegigr'}      = chr(0x1fc2); # "`h|"
    $ent{'EEgigr'}      = chr(0x397) . chr(0x300) . chr(0x345); # "`H|"
    $ent{'eecigr'}      = chr(0x1fc7); # "=h|"
    $ent{'EEcigr'}      = chr(0x397) . chr(0x342) . chr(0x345); # "=H|"
    $ent{'eeraigr'}     = chr(0x1f95); # "<'h|"
    $ent{'EEraigr'}     = chr(0x1f9d); # "<'H|"
    $ent{'eesaigr'}     = chr(0x1f94); # ">'h|"
    $ent{'EEsaigr'}     = chr(0x1f9c); # ">'H|"
    $ent{'eergigr'}     = chr(0x1f93); # "<`h|"
    $ent{'EErgigr'}     = chr(0x1f9b); # "<`H|"
    $ent{'eesgigr'}     = chr(0x1f92); # ">`h|"
    $ent{'EEsgigr'}     = chr(0x1f9a); # ">`H|"
    $ent{'eercigr'}     = chr(0x1f97); # "<=h|"
    $ent{'EErcigr'}     = chr(0x1f9f); # "<=H|"
    $ent{'eescigr'}     = chr(0x1f96); # ">=h|"
    $ent{'EEscigr'}     = chr(0x1f9e); # ">=H|"
    $ent{'eerougr'}     = chr(0x1f21); # "<h"
    $ent{'EErougr'}     = chr(0x1f29); # "<H"
    $ent{'eesmogr'}     = chr(0x1f20); # ">h"
    $ent{'EEsmogr'}     = chr(0x1f28); # ">H"
    $ent{'eegragr'}     = chr(0x1f74); # "`h"
    $ent{'EEgragr'}     = chr(0x1fca); # "`H"
    $ent{'eeacugr'}     = chr(0x1f75); # "'h"
    $ent{'EEacugr'}     = chr(0x1fcb); # "'H"
    $ent{'eecirgr'}     = chr(0x1fc6); # "=h"
    $ent{'EEcirgr'}     = chr(0x0397) . chr(0x0342); # "=H"
    $ent{'eeragr'}      = chr(0x1f25); # "<'h"
    $ent{'EEragr'}      = chr(0x1f2d); # "<'H"
    $ent{'eesagr'}      = chr(0x1f24); # ">'h"
    $ent{'EEsagr'}      = chr(0x1f2c); # ">'H"
    $ent{'eerggr'}      = chr(0x1f23); # "<`h"
    $ent{'EErggr'}      = chr(0x1f2b); # "<`H"
    $ent{'eesggr'}      = chr(0x1f22); # ">`h"
    $ent{'EEsggr'}      = chr(0x1f2a); # ">`H"
    $ent{'eercgr'}      = chr(0x1f27); # "<=h"
    $ent{'EErcgr'}      = chr(0x1f2f); # "<=H"
    $ent{'eescgr'}      = chr(0x1f26); # ">=h"
    $ent{'EEscgr'}      = chr(0x1f2e); # ">=H"

    $ent{'thgr'}        = chr(0x03b8); # "j"
    $ent{'THgr'}        = chr(0x0398); # "J"

    $ent{'igr'}         = chr(0x03b9); # "i"
    $ent{'Igr'}         = chr(0x0399); # "I"
    $ent{'irougr'}      = chr(0x1f31); # "<i"
    $ent{'Irougr'}      = chr(0x1f39); # "<I"
    $ent{'ismogr'}      = chr(0x1f30); # ">i"
    $ent{'Ismogr'}      = chr(0x1f38); # ">I"
    $ent{'igragr'}      = chr(0x1f76); # "`i"
    $ent{'Igragr'}      = chr(0x1fda); # "`I"
    $ent{'iacugr'}      = chr(0x1f77); # "'i"
    $ent{'Iacugr'}      = chr(0x1fdb); # "'I"
    $ent{'icirgr'}      = chr(0x1fd6); # "=i"
    $ent{'Icirgr'}      = chr(0x0399) . chr(0x0342); # "=I"
    $ent{'iragr'}       = chr(0x1f35); # "<'i"
    $ent{'Iragr'}       = chr(0x1f3d); # "<'I"
    $ent{'isagr'}       = chr(0x1f34); # ">'i"
    $ent{'Isagr'}       = chr(0x1f3c); # ">'I"
    $ent{'irggr'}       = chr(0x1f33); # "<`i"
    $ent{'Irggr'}       = chr(0x1f3b); # "<`I"
    $ent{'isggr'}       = chr(0x1f32); # ">`i"
    $ent{'Isggr'}       = chr(0x1f3a); # ">`I"
    $ent{'ircgr'}       = chr(0x1f37); # "<=i"
    $ent{'Ircgr'}       = chr(0x1f3f); # "<=I"
    $ent{'iscgr'}       = chr(0x1f36); # ">=i"
    $ent{'Iscgr'}       = chr(0x1f3e); # ">=I"

    $ent{'idigr'}       = chr(0x03ca); # "\"i"
    $ent{'Idigr'}       = chr(0x03aa); # "\"I"
    $ent{'igdgr'}       = chr(0x1fd2); # "`\"i"
    $ent{'iadgr'}       = chr(0x1fd3); # "'\"i"
    $ent{'icdgr'}       = chr(0x1fd7); # "=\"i"

    $ent{'kgr'}         = chr(0x03ba); # "k"
    $ent{'Kgr'}         = chr(0x039a); # "K"

    $ent{'lgr'}         = chr(0x03bb); # "l"
    $ent{'Lgr'}         = chr(0x039b); # "L"

    $ent{'mgr'}         = chr(0x03bc); # "m"
    $ent{'Mgr'}         = chr(0x039c); # "M"

    $ent{'ngr'}         = chr(0x03bd); # "n"
    $ent{'Ngr'}         = chr(0x039d); # "N"

    $ent{'xgr'}         = chr(0x03be); # "x"
    $ent{'Xgr'}         = chr(0x039e); # "X"

    $ent{'ogr'}         = chr(0x03bf); # "o"
    $ent{'Ogr'}         = chr(0x039f); # "O"
    $ent{'orougr'}      = chr(0x1f41); # "<o"
    $ent{'Orougr'}      = chr(0x1f49); # "<O"
    $ent{'osmogr'}      = chr(0x1f40); # ">o"
    $ent{'Osmogr'}      = chr(0x1f48); # ">O"
    $ent{'ogragr'}      = chr(0x1f78); # "`o"
    $ent{'Ogragr'}      = chr(0x1ff8); # "`O"
    $ent{'oacugr'}      = chr(0x1f79); # "'o"
    $ent{'Oacugr'}      = chr(0x1ff9); # "'O"
    $ent{'ocirgr'}      = chr(0x03bf) . chr(0x0342); # "=o"
    $ent{'Ocirgr'}      = chr(0x039f) . chr(0x0342); # "=O"
    $ent{'oragr'}       = chr(0x1f45); # "<'o"
    $ent{'Oragr'}       = chr(0x1f4d); # "<'O"
    $ent{'osagr'}       = chr(0x1f44); # ">'o"
    $ent{'Osagr'}       = chr(0x1f4c); # ">'O"
    $ent{'orggr'}       = chr(0x1f43); # "<`o"
    $ent{'Orggr'}       = chr(0x1f4b); # "<`O"
    $ent{'osggr'}       = chr(0x1f42); # ">`o"
    $ent{'Osggr'}       = chr(0x1f4a); # ">`O"
    $ent{'orcgr'}       = chr(0x03bf) . chr(0x0314) . chr(0x0342); # "<=o"
    $ent{'Orcgr'}       = chr(0x039f) . chr(0x0314) . chr(0x0342); # "<=O"
    $ent{'oscgr'}       = chr(0x03bf) . chr(0x0313) . chr(0x0342); # ">=o"
    $ent{'Oscgr'}       = chr(0x039f) . chr(0x0313) . chr(0x0342); # ">=O"

    $ent{'pgr'}         = chr(0x03c0); # "p"
    $ent{'Pgr'}         = chr(0x03a0); # "P"

    $ent{'rgr'}         = chr(0x03c1); # "r"
    $ent{'Rgr'}         = chr(0x03a1); # "R"
    $ent{'rrougr'}      = chr(0x1fe5); # "<r"
    $ent{'Rrougr'}      = chr(0x1fec); # "<R"
    $ent{'rsmogr'}      = chr(0x1fe4); # ">r"
    $ent{'Rsmogr'}      = chr(0x03a1) . chr(0x0313); # ">R"

    $ent{'sgr'}         = chr(0x03c3); # "s"
    $ent{'Sgr'}         = chr(0x03a3); # "S"
    $ent{'sfgr'}        = chr(0x03c2); # "c"

    $ent{'tgr'}         = chr(0x03c4); # "t"
    $ent{'Tgr'}         = chr(0x03a4); # "T"

    $ent{'ugr'}         = chr(0x3c5); # "u"
    $ent{'Ugr'}         = chr(0x3a5); # "U"
    $ent{'urougr'}      = chr(0x1f51); # "<u"
    $ent{'Urougr'}      = chr(0x1f59); # "<U"
    $ent{'usmogr'}      = chr(0x1f50); # ">u"
    $ent{'Usmogr'}      = chr(0x03a5) . chr(0x0313); # ">U"
    $ent{'ugragr'}      = chr(0x1f7a); # "`u"
    $ent{'Ugragr'}      = chr(0x1fea); # "`U"
    $ent{'uacugr'}      = chr(0x1f7b); # "'u"
    $ent{'Uacugr'}      = chr(0x1feb); # "'U"
    $ent{'ucirgr'}      = chr(0x1fe6); # "=u"
    $ent{'Ucirgr'}      = chr(0x03a5) . chr(0x0342); # "=U"
    $ent{'uragr'}       = chr(0x1f55); # "<'u"
    $ent{'Uragr'}       = chr(0x1f5d); # "<'U"
    $ent{'usagr'}       = chr(0x1f54); # ">'u"
    $ent{'Usagr'}       = chr(0x03a5) . chr(0x0313) . chr(0x0301); # ">'U"
    $ent{'urggr'}       = chr(0x1f53); # "<`u"
    $ent{'Urggr'}       = chr(0x1f5b); # "<`U"
    $ent{'usggr'}       = chr(0x1f52); # ">`u"
    $ent{'Usggr'}       = chr(0x03a5) . chr(0x0313) . chr(0x0300); # ">`U"
    $ent{'urcgr'}       = chr(0x1f57); # "<=u"
    $ent{'Urcgr'}       = chr(0x1f5f); # "<=U"
    $ent{'uscgr'}       = chr(0x1f56); # ">=u"
    $ent{'Uscgr'}       = chr(0x03a5) . chr(0x0313) . chr(0x0342); # ">=U"

    $ent{'udigr'}       = chr(0x03cb); # "\"u"
    $ent{'Udigr'}       = chr(0x03ab); # "\"U"
    $ent{'ugdgr'}       = chr(0x1fe2); # "`\"u"
    $ent{'uadgr'}       = chr(0x1fe3); # "'\"u"
    $ent{'ucdgr'}       = chr(0x1fe7); # "=\"u"

    $ent{'phgr'}        = chr(0x03c6); # "f"
    $ent{'PHgr'}        = chr(0x03a6); # "F"

    $ent{'khgr'}        = chr(0x03c7); # "q"
    $ent{'KHgr'}        = chr(0x03a7); # "Q"

    $ent{'psgr'}        = chr(0x03c8); # "y"
    $ent{'PSgr'}        = chr(0x03a8); # "Y"

    $ent{'ohgr'}        = chr(0x03c9); # "w"
    $ent{'OHgr'}        = chr(0x03a9); # "W"
    $ent{'ohiotgr'}     = chr(0x1ff3); # "w|"
    $ent{'OHiotgr'}     = chr(0x1ffc); # "W|"
    $ent{'ohrigr'}      = chr(0x1fa1); # "<w|"
    $ent{'OHrigr'}      = chr(0x1fa9); # "<W|"
    $ent{'ohsigr'}      = chr(0x1fa0); # ">w|"
    $ent{'OHsigr'}      = chr(0x1fa8); # ">W|"
    $ent{'ohaigr'}      = chr(0x1ff4); # "'w|"
    $ent{'OHaigr'}      = chr(0x1ffb) . chr(0x0345); # "'W|"
    $ent{'ohgigr'}      = chr(0x1ff2); # "`w|"
    $ent{'OHgigr'}      = chr(0x1ffa) . chr(0x0345); # "`W|"
    $ent{'ohcigr'}      = chr(0x1ff7); # "=w|"
    $ent{'OHcigr'}      = chr(0x03a9) . chr(0x0342) . chr(0x0345); # "=W|"
    $ent{'ohraigr'}     = chr(0x1fa5); # "<'w|"
    $ent{'OHraigr'}     = chr(0x1fad); # "<'W|"
    $ent{'ohsaigr'}     = chr(0x1fa4); # ">'w|"
    $ent{'OHsaigr'}     = chr(0x1fac); # ">'W|"
    $ent{'ohrgigr'}     = chr(0x1fa3); # "<`w|"
    $ent{'OHrgigr'}     = chr(0x1fab); # "<`W|"
    $ent{'ohsgigr'}     = chr(0x1fa2); # ">`w|"
    $ent{'OHsgigr'}     = chr(0x1faa); # ">`W|"
    $ent{'ohrcigr'}     = chr(0x1fa7); # "<=w|"
    $ent{'OHrcigr'}     = chr(0x1faf); # "<=W|"
    $ent{'ohscigr'}     = chr(0x1fa6); # ">=w|"
    $ent{'OHscigr'}     = chr(0x1fae); # ">=W|"
    $ent{'ohrougr'}     = chr(0x1f61); # "<w"
    $ent{'OHrougr'}     = chr(0x1f69); # "<W"
    $ent{'ohsmogr'}     = chr(0x1f60); # ">w"
    $ent{'OHsmogr'}     = chr(0x1f68); # ">W"
    $ent{'ohgragr'}     = chr(0x1f7c); # "`w"
    $ent{'OHgragr'}     = chr(0x1ffa); # "`W"
    $ent{'ohacugr'}     = chr(0x1f7d); # "'w"
    $ent{'OHacugr'}     = chr(0x1ffb); # "'W"
    $ent{'ohcirgr'}     = chr(0x1ff6); # "=w"
    $ent{'OHcirgr'}     = chr(0x03a9) . chr(0x0342); # "=W"
    $ent{'ohragr'}      = chr(0x1f65); # "<'w"
    $ent{'OHragr'}      = chr(0x1f6d); # "<'W"
    $ent{'ohsagr'}      = chr(0x1f64); # ">'w"
    $ent{'OHsagr'}      = chr(0x1f6c); # ">'W"
    $ent{'ohrggr'}      = chr(0x1f63); # "<`w"
    $ent{'OHrggr'}      = chr(0x1f6b); # "<`W"
    $ent{'ohsggr'}      = chr(0x1f62); # ">`w"
    $ent{'OHsggr'}      = chr(0x1f6a); # ">`W"
    $ent{'ohrcgr'}      = chr(0x1f67); # "<=w"
    $ent{'OHrcgr'}      = chr(0x1f6f); # "<=W"
    $ent{'ohscgr'}      = chr(0x1f66); # ">=w"
    $ent{'OHscgr'}      = chr(0x1f6e); # ">=W"

    # punctuation marks

    $ent{'ckgr'}        = chr(0x00b7); # Greek Ano Teleia, semicolon. "&middot;" Technically: chr(0x0387), preferred Unicode: U+00B7
    $ent{'qmgr'}        = chr(0x037e); # Greek Question mark, looks like semi-colon.

    # additional entities not in TEI

    $ent{'amacgr'}      = chr(0x03b1) . chr(0x0304); # "\\=a"
    $ent{'Amacgr'}      = chr(0x0391) . chr(0x0304); # "\\=A"
    $ent{'abregr'}      = chr(0x03b1) . chr(0x0306); # ")a"
    $ent{'Abregr'}      = chr(0x0391) . chr(0x0306); # ")A"

    $ent{'jgr'}         = chr(0x03f3); # Greek j.


    ###############################################################################
    ## DIRECTIONAL CHARACTERS
    ##
    ## See https://www.w3.org/International/questions/qa-bidi-unicode-controls.en
    ##
    ## Implicit Directional Marks
    $ent{'lrm'}         = chr(0x200E);  # LEFT-TO-RIGHT MARK
    $ent{'rlm'}         = chr(0x200F);  # RIGHT-TO-LEFT MARK
    $ent{'alm'}         = chr(0x061C);  # ARABIC LETTER MARK

    ## Explicit Directional Embeddings
    $ent{'lre'}         = chr(0x202A);  # LEFT-TO-RIGHT EMBEDDING
    $ent{'rle'}         = chr(0x202B);  # RIGHT-TO-LEFT EMBEDDING
    $ent{'lro'}         = chr(0x202D);  # LEFT-TO-RIGHT OVERRIDE
    $ent{'rlo'}         = chr(0x202E);  # RIGHT-TO-LEFT OVERRIDE
    $ent{'pdf'}         = chr(0x200C);  # POP DIRECTIONAL FORMATTING

    ## Explicit Directional Isolates
    $ent{'lri'}         = chr(0x2066);  # LEFT-TO-RIGHT ISOLATE
    $ent{'rli'}         = chr(0x2067);  # RIGHT-TO-LEFT ISOLATE
    $ent{'fsi'}         = chr(0x2068);  # FIRST STRONG ISOLATE
    $ent{'pdi'}         = chr(0x2069);  # POP DIRECTIONAL ISOLATE

    ###############################################################################
    ## Combining diacritics

    $ent{'cgj'}         = chr(0x034F);  # COMBINING GRAPHEME JOINER

    $ent{'c_grave'}     = chr(0x0300);  # COMBINING GRAVE ACCENT
    $ent{'c_acute'}     = chr(0x0301);  # COMBINING ACUTE ACCENT
    $ent{'c_circ'}      = chr(0x0302);  # COMBINING CIRCUMFLEX ACCENT
    $ent{'c_tilde'}     = chr(0x0303);  # COMBINING TILDE
    $ent{'c_macr'}      = chr(0x0304);  # COMBINING MACRON
    $ent{'c_overline'}  = chr(0x0305);  # COMBINING OVERLINE
    $ent{'c_breve'}     = chr(0x0306);  # COMBINING BREVE
    $ent{'c_dota'}      = chr(0x0307);  # COMBINING DOT ABOVE
    $ent{'c_uml'}       = chr(0x0308);  # COMBINING DIAERESIS
    $ent{'c_hook'}      = chr(0x0309);  # COMBINING HOOK ABOVE
    $ent{'c_ring'}      = chr(0x030A);  # COMBINING RING ABOVE
    $ent{'c_dblac'}     = chr(0x030B);  # COMBINING DOUBLE ACUTE ACCENT
    $ent{'c_caron'}     = chr(0x030C);  # COMBINING CARON
    $ent{'c_vert'}      = chr(0x030D);  # COMBINING VERTICAL LINE ABOVE
    $ent{'c_dbvert'}    = chr(0x030E);  # COMBINING DOUBLE VERTICAL LINE ABOVE
    $ent{'c_dbgrav'}    = chr(0x030F);  # COMBINING DOUBLE GRAVE ACCENT
    $ent{'c_chdbnd'}    = chr(0x0310);  # COMBINING CANDRABINDU
    $ent{'c_ibreve'}    = chr(0x0311);  # COMBINING INVERTED BREVE
    $ent{'c_tcomma'}    = chr(0x0312);  # COMBINING TURNED COMMA ABOVE
    $ent{'c_comma'}     = chr(0x0313);  # COMBINING COMMA ABOVE
    $ent{'c_rcomma'}    = chr(0x0314);  # COMBINING REVERSED COMMA ABOVE
    $ent{'c_commar'}    = chr(0x0315);  # COMBINING COMMA ABOVE RIGHT


    ###############################################################################
    # Hebrew

    $ent{'healef'}          = chr(0x5D0);   # ALEF
    $ent{'hebet'}           = chr(0x5D1);   # BET
    $ent{'hegimel'}         = chr(0x5D2);   # GIMEL
    $ent{'hedalet'}         = chr(0x5D3);   # DALET
    $ent{'hehe'}            = chr(0x5D4);   # HE
    $ent{'hevav'}           = chr(0x5D5);   # VAV
    $ent{'hezayin'}         = chr(0x5D6);   # ZAYIN
    $ent{'hehet'}           = chr(0x5D7);   # HET
    $ent{'hetet'}           = chr(0x5D8);   # TET
    $ent{'heyod'}           = chr(0x5D9);   # YOD
    $ent{'hefinalkaf'}      = chr(0x5DA);   # FINAL KAF
    $ent{'hekaf'}           = chr(0x5DB);   # KAF
    $ent{'helamed'}         = chr(0x5DC);   # LAMED
    $ent{'hefinalmem'}      = chr(0x5DD);   # FINAL MEM
    $ent{'hemem'}           = chr(0x5DE);   # MEM
    $ent{'hefinalnun'}      = chr(0x5DF);   # FINAL NUN
    $ent{'henun'}           = chr(0x5E0);   # NUN
    $ent{'hesamekh'}        = chr(0x5E1);   # SAMEKH
    $ent{'heayin'}          = chr(0x5E2);   # AYIN
    $ent{'hefinalpe'}       = chr(0x5E3);   # FINAL PE
    $ent{'hepe'}            = chr(0x5E4);   # PE
    $ent{'hefinaltsadi'}    = chr(0x5E5);   # FINAL TSADI
    $ent{'hetsadi'}         = chr(0x5E6);   # TSADI
    $ent{'heqof'}           = chr(0x5E7);   # QOF
    $ent{'heresh'}          = chr(0x5E8);   # RESH
    $ent{'heshin'}          = chr(0x5E9);   # SHIN
    $ent{'hetav'}           = chr(0x5EA);   # TAV

    $ent{'hesheva'}         = chr(0x5B0);   # SHEVA
    $ent{'hehatafsegol'}    = chr(0x5B1);   # HATAF SEGOL
    $ent{'hehatafpatah'}    = chr(0x5B2);   # HATAF PATAH
    $ent{'hehatafqamats'}   = chr(0x5B3);   # HATAF QAMATS
    $ent{'hehiriq'}         = chr(0x5B4);   # HIRIQ
    $ent{'hetsere'}         = chr(0x5B5);   # TSERE
    $ent{'hesegol'}         = chr(0x5B6);   # SEGOL
    $ent{'hepatah'}         = chr(0x5B7);   # PATAH
    $ent{'heqamats'}        = chr(0x5B8);   # QAMATS
    $ent{'heholam'}         = chr(0x5B9);   # HOLAM

    $ent{'hequbuts'}        = chr(0x5BB);   # QUBUTS
    $ent{'hedagesh'}        = chr(0x5BC);   # DAGESH

    $ent{'hemaqaf'}         = chr(0x5BE);   # MAQAF

    $ent{'heshindot'}       = chr(0x5C1);   # SHINDOT
    $ent{'hesindot'}        = chr(0x5C2);   # SINDOT

    ###############################################################################

    # Astronomical and astrological signs (followed by the text variant selector).

    $ent{'Sun'}         = chr(0x2609) . chr(0xFE0E);
    $ent{'Moon'}        = chr(0x263D) . chr(0xFE0E); # First quarter
    $ent{'Moon2'}       = chr(0x263E) . chr(0xFE0E); # Last quarter
    $ent{'Mercury'}     = chr(0x263F) . chr(0xFE0E);
    $ent{'Venus'}       = chr(0x2640) . chr(0xFE0E);
    $ent{'Earth'}       = chr(0x2295) . chr(0xFE0E);
    $ent{'Earth2'}      = chr(0x2641) . chr(0xFE0E); # Alternative: circle with cross on top
    $ent{'Mars'}        = chr(0x2642) . chr(0xFE0E);
    $ent{'Jupiter'}     = chr(0x2643) . chr(0xFE0E);
    $ent{'Saturn'}      = chr(0x2644) . chr(0xFE0E);
    $ent{'Uranus'}      = chr(0x2645) . chr(0xFE0E);
    $ent{'Uranus2'}     = chr(0x26E2) . chr(0xFE0E);
    $ent{'Neptune'}     = chr(0x2646) . chr(0xFE0E);
    $ent{'Pluto'}       = chr(0x2647) . chr(0xFE0E);

    $ent{'Aries'}       = chr(0x2648) . chr(0xFE0E);
    $ent{'Taurus'}      = chr(0x2649) . chr(0xFE0E);
    $ent{'Gemini'}      = chr(0x264A) . chr(0xFE0E);
    $ent{'Cancer'}      = chr(0x264B) . chr(0xFE0E);
    $ent{'Leo'}         = chr(0x264C) . chr(0xFE0E);
    $ent{'Virgo'}       = chr(0x264D) . chr(0xFE0E);
    $ent{'Libra'}       = chr(0x264E) . chr(0xFE0E);
    $ent{'Scorpius'}    = chr(0x264F) . chr(0xFE0E);
    $ent{'Sagittarius'} = chr(0x2650) . chr(0xFE0E);
    $ent{'Capricorn'}   = chr(0x2651) . chr(0xFE0E);
    $ent{'Aquarius'}    = chr(0x2652) . chr(0xFE0E);
    $ent{'Pisces'}      = chr(0x2653) . chr(0xFE0E);

    $ent{'Ascending'}   = chr(0x260A) . chr(0xFE0E);
    $ent{'Descending'}  = chr(0x260B) . chr(0xFE0E);

    ###############################################################################

    $ent{'jcaron'}      = 'j' . chr(0x030C); # j with caron
    $ent{'Jcaron'}      = 'J' . chr(0x030C); # J with caron
    $ent{'pcaron'}      = 'p' . chr(0x030C); # p with caron
    $ent{'Pcaron'}      = 'P' . chr(0x030C); # P with caron
    $ent{'ycaron'}      = 'y' . chr(0x030C); # y with caron
    $ent{'Ycaron'}      = 'Y' . chr(0x030C); # Y with caron

    $ent{'ymacr'}       = chr(0x0233); # y with macron
    $ent{'Ymacr'}       = chr(0x0232); # Y with macron

    $ent{'Etilde'}      = chr(0x1EBC); # E with tilde
    $ent{'etilde'}      = chr(0x1EBD); # e with tilde
    $ent{'Ytilde'}      = chr(0x1EF8); # Y with tilde
    $ent{'ytilde'}      = chr(0x1EF9); # y with tilde
    $ent{'ctilde'}      = 'c' . chr(0x0303); # c with tilde

    $ent{'Ebreve'}      = chr(0x114); # E with breve
    $ent{'ebreve'}      = chr(0x115); # e with breve
    $ent{'Ibreve'}      = chr(0x12C); # I with breve
    $ent{'ibreve'}      = chr(0x12D); # i with breve
    $ent{'Obreve'}      = chr(0x14E); # O with breve
    $ent{'obreve'}      = chr(0x14F); # o with breve

    $ent{'Hbreveb'}     = chr(0x1E2A); # H with breve below
    $ent{'hbreveb'}     = chr(0x1E2B); # h with breve below

    $ent{'Ddotb'}       = chr(0x1E0C); # D with dot below
    $ent{'ddotb'}       = chr(0x1E0D); # d with dot below
    $ent{'Kdotb'}       = chr(0x1E32); # K with dot below
    $ent{'kdotb'}       = chr(0x1E33); # k with dot below
    $ent{'Ldotb'}       = chr(0x1E36); # L with dot below
    $ent{'ldotb'}       = chr(0x1E37); # l with dot below
    $ent{'Ndotb'}       = chr(0x1E46); # N with dot below
    $ent{'ndotb'}       = chr(0x1E47); # n with dot below
    $ent{'Rdotb'}       = chr(0x1E5A); # R with dot below
    $ent{'rdotb'}       = chr(0x1E5B); # r with dot below
    $ent{'Sdotb'}       = chr(0x1E62); # S with dot below
    $ent{'sdotb'}       = chr(0x1E63); # s with dot below
    $ent{'Tdotb'}       = chr(0x1E6C); # T with dot below
    $ent{'tdotb'}       = chr(0x1E6D); # t with dot below

    $ent{'Ndot'}        = chr(0x1E44); # N with dot above
    $ent{'ndot'}        = chr(0x1E45); # n with dot above

    $ent{'Utildeb'}     = chr(0x1E74); # U with tilde below
    $ent{'utildeb'}     = chr(0x1E75); # u with tilde below

    $ent{'aeacute'}     = chr(0x01FD); # ae ligature with acute
    $ent{'cslash'}      = chr(0x023C); # c with slash

    $ent{'Oogon'}       = chr(0x01EA);  # O ogonek
    $ent{'oogon'}       = chr(0x01EB);  # o ogonek

    $ent{'Esmall'}      = chr(0x1D07);  # small letter E

    $ent{'glots'}       = chr(0x0294);  # Latin letter glottal stop

    $ent{'longs'}       = chr(0x017F);  # long s

    $ent{'yogh'}        = chr(0x021D);  # yogh

    $ent{'Crev'}        = chr(0x2183);  # Reversed C (as used in Roman numerals)

    $ent{'okina'}       = chr(0x02BB);  # modifier letter turned comma
    $ent{'tcomma'}      = chr(0x02BB);  # modifier letter turned comma

    $ent{'rhring'}      = chr(0x02BE);  # modifier letter right half ring
    $ent{'lhring'}      = chr(0x02BF);  # modifier letter left half ring
    $ent{'hamza'}       = chr(0x02BE);  # hamza

    $ent{'lb'}          = chr(0x2114);  # L B BAR SYMBOL

    $ent{'Peso'}        = chr(0x20B1);  # Peso sign
    $ent{'Euro'}        = chr(0x20AC);  # Euro sign

    $ent{'triangle'}    = chr(0x25B3);  # White triangle

    $ent{'asterism'}    = chr(0x2042);  # Asterism

    $ent{'digamma'}     = chr(0x03DC);  # GREEK LETTER DIGAMMA

    $ent{'schwa'}       = chr(0x0259);  # LETTER SCHWA
    $ent{'schwaacu'}    = chr(0x0259) . chr(0x0301); # LETTER SCHWA with acute
    $ent{'schwacirc'}   = chr(0x0259) . chr(0x0302); # LETTER SCHWA with circumflex

    $ent{'ezh'}         = chr(0x0292);  # letter ezh
    $ent{'EZH'}         = chr(0x01B7);  # letter Ezh
    $ent{'esh'}         = chr(0x0283);  # letter esh
    $ent{'ESH'}         = chr(0x01A9);  # letter Esh (looks like Greek capital sigma)

    $ent{'lllig'}       = chr(0x1EFB);  # ll ligature (Welsh)
    $ent{'Lllig'}       = chr(0x1EFA);  # Ll ligature (Welsh)
    $ent{'wwelsh'}      = chr(0x1EFD);  # Middle Welsh w
    $ent{'Wwelsh'}      = chr(0x1EFC);  # Middle Welsh W

    $ent{'turna'}       = chr(0x0250);  # letter turned a
    $ent{'turnacirc'}   = chr(0x0250) . chr(0x0302);  # letter turned a with circumflex

    $ent{'aolig'}       = chr(0xa735);  # ao ligature with acute
    $ent{'AOlig'}       = chr(0xa734);  # AO ligature with acute

    $ent{'aoacute'}     = chr(0xa735) . chr(0x0301); # ao ligature with acute
    $ent{'AOacute'}     = chr(0xa734) . chr(0x0301); # AO ligature with acute

    $ent{'thornstrok'}  = chr(0xA765);  # small letter thorn with stroke
    $ent{'Thornstrok'}  = chr(0xA764);  # capital letter thorn with stroke

    $ent{'sml.s'}       = chr(0x02e2);  # Spacing modifier letter small s

    $ent{'mlrcomma'}    = chr(0x02BD);  # MODIFIER LETTER REVERSED COMMA
    $ent{'lowgrave'}    = chr(0x02CE);  # MODIFIER LETTER LOW GRAVE ACCENT
    $ent{'lowacute'}    = chr(0x02CF);  # MODIFIER LETTER LOW ACUTE ACCENT

    $ent{'N'}           = 'N';          # Capital letter N (used with special meaning in Wolff's dictionary.)

    $ent{'mlprime'}     = chr(0x02B9);  # MODIFIER LETTER PRIME

    $ent{'openO'}       = chr(0x0186);  # LATIN CAPITAL LETTER OPEN O
    $ent{'openo'}       = chr(0x0254);  # LATIN SMALL LETTER OPEN O
    $ent{'openE'}       = chr(0x0190);  # LATIN CAPITAL LETTER OPEN E
    $ent{'opene'}       = chr(0x025B);  # LATIN SMALL LETTER OPEN E

    # Tibetan transcription as used in Jäschke's dictionary and grammar

    $ent{'kspas'}       = 'k' . chr(0x02BD);                    # k with spiritus asper (dasia) -> mapped to spacing symbol!
    $ent{'hspas'}       = 'h' . chr(0x02BD);                    # h with spiritus asper (dasia) -> mapped to spacing symbol!  (MISTAKE?)
    $ent{'espas'}       = 'e' . chr(0x02BD);                    # e with spiritus asper (dasia) -> mapped to spacing symbol!  (Mistake for Greek e with dasia?)
    $ent{'ospas'}       = 'o' . chr(0x02BD);                    # e with spiritus asper (dasia) -> mapped to spacing symbol!  (Mistake for Greek o with dasia?)
    $ent{'tspas'}       = 't' . chr(0x02BD);                    # t with spiritus asper -> mapped to spacing symbol! (JASCHKE)
    $ent{'pspas'}       = 'p' . chr(0x02BD);                    # p with spiritus asper -> mapped to spacing symbol! (JASCHKE)
    $ent{'cspas'}       = 'c' . chr(0x02BD);                    # c with spiritus asper -> mapped to spacing symbol! (JASCHKE)
    $ent{'jspas'}       = 'j' . chr(0x02BD);                    # j with spiritus asper -> mapped to spacing symbol! (JASCHKE, not actually occuring)
    $ent{'gspas'}       = 'g' . chr(0x02BD);                    # g with spiritus asper -> mapped to spacing symbol! (JASCHKE)
    $ent{'dspas'}       = 'd' . chr(0x02BD);                    # d with spiritus asper -> mapped to spacing symbol! (JASCHKE)
    $ent{'bspas'}       = 'b' . chr(0x02BD);                    # b with spiritus asper -> mapped to spacing symbol! (JASCHKE)

    $ent{'cgrave'}      = 'c' . chr(0x0300);                    # c with grave
    $ent{'jgrave'}      = 'j' . chr(0x0300);                    # j with grave

    $ent{'cgrasa'}      = 'c' . chr(0x0300) . chr(0x02BD);      # c with grave and spiritus asper  -> mapped to spacing symbol!
    $ent{'jgrasa'}      = 'j' . chr(0x0300) . chr(0x02BD);      # j with grave and spiritus asper  -> mapped to spacing symbol!

    $ent{'tsadb'}       = 't' . chr(0x0323) . chr(0x02BD);      # t with spiritus asper and dot below -> mapped to spacing symbol!
    $ent{'dsadb'}       = 'd' . chr(0x0323) . chr(0x02BD);      # d with spiritus asper and dot below -> mapped to spacing symbol!

    $ent{'sgradb'}      = 's' . chr(0x0300) . chr(0x0323);      # s with grave and dot below

    $ent{'Kspas'}       = 'K' . chr(0x02BD);                    # K with spiritus asper (dasia) -> mapped to spacing symbol!
    $ent{'Cgrave'}      = 'C' . chr(0x0300);                    # C with grave
    $ent{'Jgrave'}      = 'J' . chr(0x0300);                    # J with grave

    $ent{'Cgrasa'}      = 'C' . chr(0x0300) . chr(0x02BD);      # C with grave and spiritus asper  -> mapped to spacing symbol!
    $ent{'Jgrasa'}      = 'J' . chr(0x0300) . chr(0x02BD);      # J with grave and spiritus asper  -> mapped to spacing symbol!

    $ent{'Tspas'}       = 'T' . chr(0x02BD);                    # T with spiritus asper -> mapped to spacing symbol!
    $ent{'Pspas'}       = 'P' . chr(0x02BD);                    # P with spiritus asper -> mapped to spacing symbol!
    $ent{'Cspas'}       = 'C' . chr(0x02BD);                    # C with spiritus asper -> mapped to spacing symbol!
    $ent{'Gspas'}       = 'G' . chr(0x02BD);                    # G with spiritus asper -> mapped to spacing symbol!
    $ent{'Dspas'}       = 'D' . chr(0x02BD);                    # D with spiritus asper -> mapped to spacing symbol!
    $ent{'Bspas'}       = 'B' . chr(0x02BD);                    # B with spiritus asper -> mapped to spacing symbol!

    $ent{'Tsadb'}       = 'T' . chr(0x0323) . chr(0x02BD);      # T with spiritus asper and dot below -> mapped to spacing symbol!
    $ent{'Dsadb'}       = 'D' . chr(0x0323) . chr(0x02BD);      # D with spiritus asper and dot below -> mapped to spacing symbol!

    $ent{'Sgradb'}      = 'S' . chr(0x0300) . chr(0x0323);      # S with grave and dot below

    $ent{'amaumb'}      = 'a' . chr(0x0304) . chr(0x0324);      # a with macron and umlaut below
    $ent{'emaumb'}      = 'e' . chr(0x0304) . chr(0x0324);      # e with macron and umlaut below
    $ent{'imaumb'}      = 'i' . chr(0x0304) . chr(0x0324);      # i with macron and umlaut below
    $ent{'omaumb'}      = 'o' . chr(0x0304) . chr(0x0324);      # o with macron and umlaut below
    $ent{'umaumb'}      = 'u' . chr(0x0304) . chr(0x0324);      # u with macron and umlaut below

    $ent{'Amaumb'}      = 'A' . chr(0x0304) . chr(0x0324);      # A with macron and umlaut below
    $ent{'Emaumb'}      = 'E' . chr(0x0304) . chr(0x0324);      # E with macron and umlaut below
    $ent{'Imaumb'}      = 'I' . chr(0x0304) . chr(0x0324);      # I with macron and umlaut below
    $ent{'Omaumb'}      = 'O' . chr(0x0304) . chr(0x0324);      # O with macron and umlaut below
    $ent{'Umaumb'}      = 'U' . chr(0x0304) . chr(0x0324);      # U with macron and umlaut below

    $ent{'aacumb'}      = 'a' . chr(0x0301) . chr(0x0324);      # a with acute and umlaut below
    $ent{'eacumb'}      = 'e' . chr(0x0301) . chr(0x0324);      # e with acute and umlaut below
    $ent{'iacumb'}      = 'i' . chr(0x0301) . chr(0x0324);      # i with acute and umlaut below
    $ent{'oacumb'}      = 'o' . chr(0x0301) . chr(0x0324);      # o with acute and umlaut below
    $ent{'uacumb'}      = 'u' . chr(0x0301) . chr(0x0324);      # u with acute and umlaut below

    $ent{'Aacumb'}      = 'A' . chr(0x0301) . chr(0x0324);      # A with acute and umlaut below
    $ent{'Eacumb'}      = 'E' . chr(0x0301) . chr(0x0324);      # E with acute and umlaut below
    $ent{'Iacumb'}      = 'I' . chr(0x0301) . chr(0x0324);      # I with acute and umlaut below
    $ent{'Oacumb'}      = 'O' . chr(0x0301) . chr(0x0324);      # O with acute and umlaut below
    $ent{'Uacumb'}      = 'U' . chr(0x0301) . chr(0x0324);      # U with acute and umlaut below

    $ent{'abreac'}      = chr(0x0103) . chr(0x0301);            # a with breve and acute
    $ent{'ebreac'}      = chr(0x0115) . chr(0x0301);            # e with breve and acute

    $ent{'abreumbbarb'} = chr(0x0103) . chr(0x0324) . chr(0x0331); # a with breve, umlaut below and bar below

    $ent{'amaacumb'}    = 'a' . chr(0x0304) . chr(0x0301) . chr(0x0324); # a with macron, acute and umlaut below


    # Tibetan transcription as used in Das' dictionary

    $ent{'ncirc'}       = 'n' . chr(0x0302);                    # n with circumflex
    $ent{'rbarb'}       = 'r' . chr(0x0331);                    # r with macron below

    # Combining letters (placed above the base letter)

    $ent{'acomb'}      = chr(0x0363); # combining o above
    $ent{'ocomb'}      = chr(0x0366); # combining o above
    $ent{'rcomb'}      = chr(0x036c); # combining r above

    ###############################################################################
    # Things not in Unicode (as a single character)

    # Requiring combining diacritics

    $ent{'dgrave'}      = 'd' . chr(0x0300); # d with grave
    $ent{'lgrave'}      = 'l' . chr(0x0300); # l with grave
    $ent{'mgrave'}      = 'm' . chr(0x0300); # m with grave
    $ent{'ngrave'}      = 'n' . chr(0x0300); # n with grave
    $ent{'rgrave'}      = 'r' . chr(0x0300); # r with grave
    $ent{'sgrave'}      = 's' . chr(0x0300); # s with grave
    $ent{'ygrave'}      = 'y' . chr(0x0300); # y with grave
    $ent{'zgrave'}      = 'z' . chr(0x0300); # z with grave

    $ent{'Dgrave'}      = 'D' . chr(0x0300); # D with grave
    $ent{'Lgrave'}      = 'L' . chr(0x0300); # L with grave
    $ent{'Mgrave'}      = 'M' . chr(0x0300); # M with grave
    $ent{'Ngrave'}      = 'N' . chr(0x0300); # N with grave
    $ent{'Rgrave'}      = 'R' . chr(0x0300); # R with grave
    $ent{'Sgrave'}      = 'S' . chr(0x0300); # S with grave
    $ent{'Ygrave'}      = 'Y' . chr(0x0300); # Y with grave
    $ent{'Zgrave'}      = 'Z' . chr(0x0300); # Z with grave

    $ent{'kacute'}      = 'k' . chr(0x0301); # k with acute
    $ent{'oeacute'}     = chr(0x0153) . chr(0x0301); # oe ligature with acute
    $ent{'OEacute'}     = chr(0x0152) . chr(0x0301); # OE ligature with acute
    $ent{'hacute'}      = 'h' . chr(0x0301); # h with acute
    $ent{'vacute'}      = 'v' . chr(0x0301); # v with acute
    $ent{'Vacute'}      = 'V' . chr(0x0301); # V with acute
    $ent{'tacute'}      = 't' . chr(0x0301); # t with acute
    $ent{'Tacute'}      = 'T' . chr(0x0301); # T with acute
    $ent{'pacute'}      = 'p' . chr(0x0301); # p with acute
    $ent{'Pacute'}      = 'P' . chr(0x0301); # P with acute
    $ent{'xacute'}      = 'x' . chr(0x0301); # x with acute
    $ent{'Xacute'}      = 'X' . chr(0x0301); # X with acute
    $ent{'dacute'}      = 'd' . chr(0x0301); # d with acute
    $ent{'Dacute'}      = 'D' . chr(0x0301); # D with acute
    $ent{'jacute'}      = 'j' . chr(0x0301); # j with acute
    $ent{'Jacute'}      = 'J' . chr(0x0301); # J with acute

    $ent{'Kcirc'}       = 'K' . chr(0x0302); # K with circumflex
    $ent{'kcirc'}       = 'k' . chr(0x0302); # k with circumflex
    $ent{'Rcirc'}       = 'R' . chr(0x0302); # R with circumflex
    $ent{'rcirc'}       = 'r' . chr(0x0302); # r with circumflex
    $ent{'aecirc'}      = chr(0x00e6) . chr(0x0302); # ae ligature with circumflex
    $ent{'ijcirc'}      = chr(0x0133) . chr(0x0302); # ij ligature with circumflex

    $ent{'dtilde'}      = 'd' . chr(0x0303); # d with tilde
    $ent{'gtilde'}      = 'g' . chr(0x0303); # g with tilde
    $ent{'Gtilde'}      = 'G' . chr(0x0303); # G with tilde
    $ent{'htilde'}      = 'h' . chr(0x0303); # h with tilde
    $ent{'Htilde'}      = 'H' . chr(0x0303); # H with tilde
    $ent{'jtilde'}      = 'j' . chr(0x0303); # j with tilde
    $ent{'ltilde'}      = 'l' . chr(0x0303); # s with tilde
    $ent{'mtilde'}      = 'm' . chr(0x0303); # m with tilde
    $ent{'ptilde'}      = 'p' . chr(0x0303); # p with tilde
    $ent{'Ptilde'}      = 'P' . chr(0x0303); # P with tilde
    $ent{'qtilde'}      = 'q' . chr(0x0303); # q with tilde
    $ent{'rtilde'}      = 'r' . chr(0x0303); # r with tilde
    $ent{'stilde'}      = 's' . chr(0x0303); # s with tilde
    $ent{'ttilde'}      = 't' . chr(0x0303); # t with tilde
    $ent{'wtilde'}      = 'w' . chr(0x0303); # w with tilde
    $ent{'Wtilde'}      = 'W' . chr(0x0303); # W with tilde
    $ent{'xtilde'}      = 'x' . chr(0x0303); # x with tilde
    $ent{'Xtilde'}      = 'X' . chr(0x0303); # X with tilde
    $ent{'longstilde'}  = chr(0x017F) . chr(0x0303); # long s with tilde

    $ent{'Pstroke'}     = chr(0xA750); # P with stroke through descender
    $ent{'pstroke'}     = chr(0xA751); # p with stroke through descender

    $ent{'Pflour'}      = chr(0xA752); # P with flourish
    $ent{'pflour'}      = chr(0xA753); # p with flourish

    $ent{'rum'}         = chr(0xA775); # rum (r with stroke through flag)
    $ent{'Rum'}         = chr(0xA776); # small capital Rum (r with stroke through tail)

    $ent{'Asc'}         = chr(0x1D00); # small caps A
    $ent{'Dsc'}         = chr(0x1D05); # small caps D
    $ent{'Esc'}         = chr(0x1D07); # small caps E
    $ent{'Ysc'}         = chr(0x028F); # small caps Y

    $ent{'Escbreve'}    = chr(0x1D07) . chr(0x0306); # small caps E with breve

    $ent{'vdiagstrok'}  = chr(0xA75F); # v with diagonal stroke

    $ent{'suptack'}     = 's' . chr(0x031D); # s with up tack below
    $ent{'sdntack'}     = 's' . chr(0x031E); # s with down tack below

    $ent{'aemacr'}      = chr(0x00E6) . chr(0x0304); # ae ligature with macron
    $ent{'AEmacr'}      = chr(0x00C6) . chr(0x0304); # AE ligature with macron

    $ent{'aemacracu'}   = chr(0x00E6) . chr(0x0304) . chr(0x0301); # ae ligatures with macron and acute

    $ent{'gmacr'}       = 'g' . chr(0x0304); # g with macron
    $ent{'Gmacr'}       = 'G' . chr(0x0304); # G with macron
    $ent{'hmacr'}       = 'h' . chr(0x0304); # h with macron
    $ent{'lmacr'}       = 'l' . chr(0x0304); # l with macron
    $ent{'mmacr'}       = 'm' . chr(0x0304); # m with macron
    $ent{'Mmacr'}       = 'M' . chr(0x0304); # M with macron
    $ent{'nmacr'}       = 'n' . chr(0x0304); # n with macron
    $ent{'pmacr'}       = 'p' . chr(0x0304); # p with macron
    $ent{'qmacr'}       = 'q' . chr(0x0304); # q with macron
    $ent{'rmacr'}       = 'r' . chr(0x0304); # r with macron
    $ent{'vmacr'}       = 'v' . chr(0x0304); # v with macron
    $ent{'Dmacr'}       = 'D' . chr(0x0304); # D with macron
    $ent{'xmacr'}       = 'x' . chr(0x0304); # x with macron
    $ent{'Xmacr'}       = 'X' . chr(0x0304); # X with macron

    $ent{'jbreve'}      = 'j' . chr(0x0306); # j with breve
    $ent{'Jbreve'}      = 'J' . chr(0x0306); # J with breve
    $ent{'mbreve'}      = 'm' . chr(0x0306); # m with breve
    $ent{'Mbreve'}      = 'M' . chr(0x0306); # M with breve
    $ent{'nbreve'}      = 'n' . chr(0x0306); # n with breve
    $ent{'Nbreve'}      = 'N' . chr(0x0306); # N with breve
    $ent{'sbreve'}      = 's' . chr(0x0306); # s with breve
    $ent{'Sbreve'}      = 'S' . chr(0x0306); # S with breve
    $ent{'vbreve'}      = 'v' . chr(0x0306); # v with breve
    $ent{'Vbreve'}      = 'V' . chr(0x0306); # V with breve
    $ent{'ybreve'}      = 'y' . chr(0x0306); # y with breve
    $ent{'Ybreve'}      = 'Y' . chr(0x0306); # Y with breve
    $ent{'zbreve'}      = 'z' . chr(0x0306); # z with breve
    $ent{'Zbreve'}      = 'Z' . chr(0x0306); # Z with breve
    $ent{'xbreve'}      = 'x' . chr(0x0306); # x with breve
    $ent{'Xbreve'}      = 'X' . chr(0x0306); # X with breve

    $ent{'nbrevdotb'}   = 'n' . chr(0x0306) . chr(0x0323); # n with breve and dot b
    $ent{'zbrevdotb'}   = 'z' . chr(0x0306) . chr(0x0323); # z with breve and dot b

    $ent{'nchndrb'}     = 'n' . chr(0x0310); # n with chandrabindu

    $ent{'adota'}       = 'a' . chr(0x0307); # a with dot above
    $ent{'Adota'}       = 'A' . chr(0x0307); # A with dot above
    $ent{'bdota'}       = 'b' . chr(0x0307); # b with dot above
    $ent{'Bdota'}       = 'B' . chr(0x0307); # B with dot above
    $ent{'cdota'}       = 'c' . chr(0x0307); # c with dot above
    $ent{'Cdota'}       = 'C' . chr(0x0307); # C with dot above
    $ent{'ddota'}       = 'd' . chr(0x0307); # d with dot above
    $ent{'edota'}       = 'e' . chr(0x0307); # e with dot above
    $ent{'Edota'}       = 'E' . chr(0x0307); # E with dot above
    $ent{'fdota'}       = 'f' . chr(0x0307); # f with dot above
    $ent{'Fdota'}       = 'F' . chr(0x0307); # F with dot above
    $ent{'gdota'}       = 'g' . chr(0x0307); # g with dot above
    $ent{'Gdota'}       = 'G' . chr(0x0307); # G with dot above
    $ent{'hdota'}       = 'h' . chr(0x0307); # h with dot above
    $ent{'Hdota'}       = 'H' . chr(0x0307); # H with dot above
    $ent{'jdota'}       = 'j' . chr(0x0307); # j with dot above
    $ent{'Jdota'}       = 'J' . chr(0x0307); # J with dot above
    $ent{'kdota'}       = 'k' . chr(0x0307); # k with dot above
    $ent{'ldota'}       = 'l' . chr(0x0307); # l with dot above
    $ent{'mdota'}       = 'm' . chr(0x0307); # m with dot above
    $ent{'ndota'}       = 'n' . chr(0x0307); # n with dot above
    $ent{'Ndota'}       = 'N' . chr(0x0307); # N with dot above
    $ent{'odota'}       = 'o' . chr(0x0307); # o with dot above
    $ent{'pdota'}       = 'p' . chr(0x0307); # p with dot above
    $ent{'rdota'}       = 'r' . chr(0x0307); # r with dot above
    $ent{'sdota'}       = 's' . chr(0x0307); # s with dot above
    $ent{'Sdota'}       = 'S' . chr(0x0307); # S with dot above
    $ent{'Sdota'}       = 'S' . chr(0x0307); # S with dot above
    $ent{'tdota'}       = 't' . chr(0x0307); # t with dot above
    $ent{'udota'}       = 'u' . chr(0x0307); # u with dot above
    $ent{'Udota'}       = 'U' . chr(0x0307); # U with dot above
    $ent{'vdota'}       = 'v' . chr(0x0307); # v with dot above
    $ent{'Vdota'}       = 'V' . chr(0x0307); # V with dot above
    $ent{'xdota'}       = 'x' . chr(0x0307); # x with dot above
    $ent{'Xdota'}       = 'X' . chr(0x0307); # X with dot above
    $ent{'ydota'}       = 'y' . chr(0x0307); # y with dot above
    $ent{'Ydota'}       = 'Y' . chr(0x0307); # Y with dot above
    $ent{'zdota'}       = 'z' . chr(0x0307); # z with dot above
    $ent{'Zdota'}       = 'Z' . chr(0x0307); # z with dot above

    $ent{'ruml'}        = 'r' . chr(0x0308); # r with diaresis
    $ent{'xuml'}        = 'x' . chr(0x0308); # r with diaresis

    $ent{'ering'}       = 'e' . chr(0x030A); # e with ring
    $ent{'mring'}       = 'm' . chr(0x030A); # m with ring
    $ent{'aering'}      = chr(0x00E6) . chr(0x030A); # ae ligatures with ring

    $ent{'Acaron'}      = chr(0x01CD); # A with caron
    $ent{'acaron'}      = chr(0x01CE); # a with caron
    $ent{'Icaron'}      = chr(0x01CF); # I with caron
    $ent{'icaron'}      = chr(0x01D0); # i with caron
    $ent{'Ocaron'}      = chr(0x01D1); # O with caron
    $ent{'ocaron'}      = chr(0x01D2); # o with caron
    $ent{'Ucaron'}      = chr(0x01D3); # U with caron
    $ent{'ucaron'}      = chr(0x01D4); # u with caron

    $ent{'zcardotb'}    = 'z' . chr(0x030C) . chr(0x0323); # z with caron and dot below

    $ent{'adgrave'}     = 'a' . chr(0x030F); # a with double grave
    $ent{'idgrave'}     = 'i' . chr(0x030F); # i with double grave
    $ent{'odgrave'}     = 'o' . chr(0x030F); # o with double grave
    $ent{'rdgrave'}     = 'r' . chr(0x030F); # r with double grave
    $ent{'udgrave'}     = 'u' . chr(0x030F); # u with double grave

    $ent{'prcomma'}     = 'p' . chr(0x0314); # p with reverse comma above
    $ent{'krcomma'}     = 'k' . chr(0x0314); # k with reverse comma above
    $ent{'crcomma'}     = 'c' . chr(0x0314); # c with reverse comma above
    $ent{'trcomma'}     = 't' . chr(0x0314); # t with reverse comma above

    $ent{'cdacdotb'}     = 'c' . chr(0x030B) . chr(0x0323); # c with double acute and dot below

    $ent{'glhringa'}     = 'g' . chr(0x0351); # g with left half ring above

    $ent{'adotb'}       = 'a' . chr(0x0323); # a with dot below
    $ent{'Adotb'}       = 'A' . chr(0x0323); # A with dot below
    $ent{'cdotb'}       = 'c' . chr(0x0323); # c with dot below
    $ent{'Cdotb'}       = 'C' . chr(0x0323); # C with dot below
    $ent{'edotb'}       = 'e' . chr(0x0323); # e with dot below
    $ent{'Edotb'}       = 'E' . chr(0x0323); # E with dot below
    $ent{'Fdotb'}       = 'F' . chr(0x0323); # F with dot below
    $ent{'gdotb'}       = 'g' . chr(0x0323); # g with dot below
    $ent{'Gdotb'}       = 'G' . chr(0x0323); # G with dot below
    $ent{'hdotb'}       = 'h' . chr(0x0323); # h with dot below
    $ent{'Hdotb'}       = 'H' . chr(0x0323); # H with dot below
    $ent{'idotb'}       = 'i' . chr(0x0323); # i with dot below
    $ent{'Idotb'}       = 'I' . chr(0x0323); # I with dot below
    $ent{'jdotb'}       = 'j' . chr(0x0323); # j with dot below
    $ent{'Jdotb'}       = 'J' . chr(0x0323); # J with dot below
    $ent{'ldotb'}       = 'l' . chr(0x0323); # 1 with dot below
    $ent{'Ldotb'}       = 'L' . chr(0x0323); # L with dot below
    $ent{'mdotb'}       = 'm' . chr(0x0323); # m with dot below
    $ent{'Odotb'}       = 'O' . chr(0x0323); # O with dot below
    $ent{'odotb'}       = chr(0x1ECD); # o with dot below
    $ent{'udotb'}       = 'u' . chr(0x0323); # u with dot below
    $ent{'Udotb'}       = 'U' . chr(0x0323); # U with dot below
    $ent{'wdotb'}       = 'w' . chr(0x0323); # w with dot below
    $ent{'xdotb'}       = 'x' . chr(0x0323); # x with dot below
    $ent{'Xdotb'}       = 'X' . chr(0x0323); # X with dot below
    $ent{'zdotb'}       = 'z' . chr(0x0323); # z with dot below
    $ent{'Zdotb'}       = 'Z' . chr(0x0323); # Z with dot below

    $ent{'aumlb'}       = 'a' . chr(0x0324); # a with diaresis below
    $ent{'eumlb'}       = 'e' . chr(0x0324); # e with diaresis below
    $ent{'humlb'}       = 'h' . chr(0x0324); # h with diaresis below
    $ent{'iumlb'}       = 'i' . chr(0x0324); # i with diaresis below
    $ent{'lumlb'}       = 'l' . chr(0x0324); # l with diaresis below
    $ent{'Lumlb'}       = 'L' . chr(0x0324); # L with diaresis below
    $ent{'oumlb'}       = 'o' . chr(0x0324); # o with diaresis below
    $ent{'sumlb'}       = 's' . chr(0x0324); # s with diaresis below
    $ent{'Sumlb'}       = 'S' . chr(0x0324); # S with diaresis below
    $ent{'tumlb'}       = 't' . chr(0x0324); # t with diaresis below
    $ent{'Tumlb'}       = 'T' . chr(0x0324); # T with diaresis below
    $ent{'uumlb'}       = 'u' . chr(0x0324); # u with diaresis below
    $ent{'uumlb'}       = 'u' . chr(0x0324); # u with diaresis below
    $ent{'Uumlb'}       = 'U' . chr(0x0324); # U with diaresis below
    $ent{'zumlb'}       = 'z' . chr(0x0324); # z with diaresis below
    $ent{'Zumlb'}       = 'Z' . chr(0x0324); # Z with diaresis below

    $ent{'ubrevumlb'}   = 'u' . chr(0x0306) . chr(0x0324);  # u with breve and diaresis below

    $ent{'oudb'}        = 'o' . chr(0x0324) . chr(0x0323);  # o with diaresis below and dot below
    $ent{'oubb'}        = 'o' . chr(0x0324) . chr(0x0331);  # o with diaresis below and macron below

    $ent{'eringb'}      = 'e' . chr(0x0325);    # e with ring below
    $ent{'nringb'}      = 'n' . chr(0x0325);    # n with ring below
    $ent{'mringb'}      = 'm' . chr(0x0325);    # m with ring below
    $ent{'rringb'}      = 'r' . chr(0x0325);    # r with ring below

    $ent{'gcomma'}      = 'g' . chr(0x0326);    # g with comma below

    $ent{'acedil'}      = 'a' . chr(0x0327);    # a with cedille
    $ent{'Acedil'}      = 'A' . chr(0x0327);    # A with cedille
    $ent{'dcedil'}      = 'd' . chr(0x0327);    # d with cedille
    $ent{'ecedil'}      = 'e' . chr(0x0327);    # e with cedille
    $ent{'Ecedil'}      = 'E' . chr(0x0327);    # E with cedille
    $ent{'icedil'}      = 'i' . chr(0x0327);    # i with cedille
    $ent{'Icedil'}      = 'I' . chr(0x0327);    # I with cedille
    $ent{'icedilacu'}   = 'i' . chr(0x0327) . chr(0x0301);  # i with cedille and acute
    $ent{'ocedil'}      = 'o' . chr(0x0327);    # o with cedille
    $ent{'Ocedil'}      = 'O' . chr(0x0327);    # O with cedille
    $ent{'ucedil'}      = 'u' . chr(0x0327);    # u with cedille
    $ent{'Ucedil'}      = 'U' . chr(0x0327);    # U with cedille
    $ent{'xcedil'}      = 'x' . chr(0x0327);    # x with cedille
    $ent{'zcedil'}      = 'z' . chr(0x0327);    # z with cedille
    $ent{'Zcedil'}      = 'Z' . chr(0x0327);    # Z with cedille

    $ent{'scircb'}      = 's' . chr(0x032D);    # s with circumflex below
    $ent{'tcircb'}      = 't' . chr(0x032D);    # t with circumflex below
    $ent{'ucircb'}      = 'u' . chr(0x032D);    # u with circumflex below
    $ent{'zcircb'}      = 'z' . chr(0x032D);    # z with circumflex below

    $ent{'abreveb'}     = 'a' . chr(0x032E);    # a with breve below
    $ent{'Abreveb'}     = 'A' . chr(0x032E);    # A with breve below
    $ent{'ebreveb'}     = 'e' . chr(0x032E);    # e with breve below
    $ent{'Ebreveb'}     = 'E' . chr(0x032E);    # E with breve below
    $ent{'ibreveb'}     = 'i' . chr(0x032E);    # i with breve below
    $ent{'obreveb'}     = 'o' . chr(0x032E);    # o with breve below
    $ent{'Obreveb'}     = 'O' . chr(0x032E);    # O with breve below
    $ent{'tbreveb'}     = 't' . chr(0x032E);    # t with breve below
    $ent{'ubreveb'}     = 'u' . chr(0x032E);    # u with breve below

    $ent{'iibrevb'}     = 'i' . chr(0x032F);    # i with inverted breve below


    $ent{'ubowb'}       = 'u' . chr(0x032F);    # u with bow below (inverted breve)
    $ent{'ebowb'}       = 'e' . chr(0x032F);    # e with bow below (inverted breve)
    $ent{'ibowb'}       = 'i' . chr(0x032F);    # i with bow below (inverted breve)

    $ent{'icircb'}      = 'i' . chr(0x032D);    # i with circumflex below

    $ent{'ptildeb'}     = 'p' . chr(0x0330);    # p with tilde below

    $ent{'abarb'}       = 'a' . chr(0x0331);    # a with macron below
    $ent{'Abarb'}       = 'A' . chr(0x0331);    # A with macron below
    $ent{'bbarb'}       = 'b' . chr(0x0331);    # b with macron below
    $ent{'Bbarb'}       = 'B' . chr(0x0331);    # B with macron below
    $ent{'cbarb'}       = 'c' . chr(0x0331);    # c with macron below
    $ent{'Cbarb'}       = 'C' . chr(0x0331);    # C with macron below
    $ent{'dbarb'}       = chr(7695);            # d with macron below
    $ent{'Dbarb'}       = chr(7694);            # D with macron below
    $ent{'ebarb'}       = 'e' . chr(0x0331);    # e with macron below
    $ent{'Ebarb'}       = 'E' . chr(0x0331);    # E with macron below
    $ent{'gbarb'}       = 'g' . chr(0x0331);    # g with macron below
    $ent{'Gbarb'}       = 'G' . chr(0x0331);    # G with macron below
    $ent{'hbarb'}       = chr(7830);            # h with macron below
    $ent{'Hbarb'}       = 'H' . chr(0x0331);    # H with macron below
    $ent{'ibarb'}       = 'i' . chr(0x0331);    # i with macron below
    $ent{'Ibarb'}       = 'I' . chr(0x0331);    # I with macron below
    $ent{'kbarb'}       = 'k' . chr(0x0331);    # k with macron below
    $ent{'Kbarb'}       = 'K' . chr(0x0331);    # K with macron below
    $ent{'lbarb'}       = chr(7739);            # l with macron below
    $ent{'Lbarb'}       = chr(7738);            # L with macron below
    $ent{'mbarb'}       = 'm' . chr(0x0331);    # m with macron below
    $ent{'Mbarb'}       = 'M' . chr(0x0331);    # M with macron below
    $ent{'nbarb'}       = chr(7753);            # n with macron below
    $ent{'Nbarb'}       = 'N' . chr(0x0331);    # N with macron below
    $ent{'obarb'}       = 'o' . chr(0x0331);    # o with macron below
    $ent{'Obarb'}       = 'O' . chr(0x0331);    # O with macron below
    $ent{'pbarb'}       = 'p' . chr(0x0331);    # p with macron below
    $ent{'Pbarb'}       = 'P' . chr(0x0331);    # P with macron below
    $ent{'sbarb'}       = 's' . chr(0x0331);    # s with macron below
    $ent{'Sbarb'}       = 'S' . chr(0x0331);    # S with macron below
    $ent{'tbarb'}       = chr(7791);            # t with macron below
    $ent{'Tbarb'}       = chr(7790);            # T with macron below
    $ent{'ubarb'}       = 'u' . chr(0x0331);    # u with macron below
    $ent{'Ubarb'}       = 'U' . chr(0x0331);    # U with macron below
    $ent{'zbarb'}       = chr(7829);            # z with macron below
    $ent{'Zbarb'}       = chr(7828);            # Z with macron below

    $ent{'asupe'}       = 'a' . chr(0x0364);    # a with small e above
    $ent{'osupe'}       = 'o' . chr(0x0364);    # o with small e above
    $ent{'usupe'}       = 'u' . chr(0x0364);    # u with small e above
    $ent{'Asupe'}       = 'A' . chr(0x0364);    # A with small e above
    $ent{'Osupe'}       = 'O' . chr(0x0364);    # O with small e above
    $ent{'Usupe'}       = 'U' . chr(0x0364);    # U with small e above

    $ent{'bstrok'}      = chr(0x0180);          # b with stroke through stem

    $ent{'abbbb'}       = 'a' . chr(0x0331) . chr(0x0331); # a with two macrons below
    $ent{'Abbbb'}       = 'A' . chr(0x0331) . chr(0x0331); # A with two macrons below


    # Requiring wide combining diacritics
    $ent{'oobreve'}     = 'o' . chr(0x035D) . 'o'; # oo with wide breve

    $ent{'aewmacr'}     = 'a' . chr(0x035E) . 'e'; # two letters ae with wide macron (aemacr is for ligature!)
    $ent{'AEwmacr'}     = 'a' . chr(0x035E) . 'e'; # two letters AE with wide macron
    $ent{'oomacr'}      = 'o' . chr(0x035E) . 'o'; # oo with wide macron
    $ent{'eemacr'}      = 'e' . chr(0x035E) . 'e'; # ee with wide macron
    $ent{'mmmacr'}      = 'm' . chr(0x035E) . 'm'; # mm with wide macron
    $ent{'mnmacr'}      = 'm' . chr(0x035E) . 'n'; # mn with wide macron

    $ent{'chbarb'}      = 'c' . chr(0x035F) . 'h'; # ch with double macron below
    $ent{'Chbarb'}      = 'C' . chr(0x035F) . 'h'; # Ch with double macron below
    $ent{'dhbarb'}      = 'd' . chr(0x035F) . 'h'; # dh with double macron below
    $ent{'Dhbarb'}      = 'D' . chr(0x035F) . 'h'; # Dh with double macron below
    $ent{'ghbarb'}      = 'g' . chr(0x035F) . 'h'; # gh with double macron below
    $ent{'Ghbarb'}      = 'G' . chr(0x035F) . 'h'; # Gh with double macron below
    $ent{'GHbarb'}      = 'G' . chr(0x035F) . 'H'; # GH with double macron below
    $ent{'khbarb'}      = 'k' . chr(0x035F) . 'h'; # Kh with double macron below
    $ent{'Khbarb'}      = 'K' . chr(0x035F) . 'h'; # Kh with double macron below
    $ent{'KHbarb'}      = 'K' . chr(0x035F) . 'H'; # KH with double macron below
    $ent{'shbarb'}      = 's' . chr(0x035F) . 'h'; # sh with double macron below
    $ent{'Shbarb'}      = 'S' . chr(0x035F) . 'h'; # Sh with double macron below
    $ent{'SHbarb'}      = 'S' . chr(0x035F) . 'H'; # SH with double macron below
    $ent{'thbarb'}      = 't' . chr(0x035F) . 'h'; # th with double macron below
    $ent{'Thbarb'}      = 'T' . chr(0x035F) . 'h'; # Th with double macron below
    $ent{'zhbarb'}      = 'z' . chr(0x035F) . 'h'; # zh with double macron below
    $ent{'Zhbarb'}      = 'Z' . chr(0x035F) . 'h'; # Zh with double macron below
    $ent{'ZHbarb'}      = 'Z' . chr(0x035F) . 'H'; # ZH with double macron below

    $ent{'Ecibb'}       = chr(0x00CA) . chr(0x0331); # E with circumflex and macron below
    $ent{'ecibb'}       = chr(0x00EA) . chr(0x0331); # e with circumflex and macron below
    $ent{'icibrb'}      = chr(0x00EE) . chr(0x032E); # i with circumflex and breve below
    $ent{'idtmac'}      = 'i' . chr(0x0307) . chr(0x0304); # i with dot and macron above
    $ent{'Oacbb'}       = chr(0x00D3) . chr(0x0331); # O with acute and macron below
    $ent{'oacbb'}       = chr(0x00F3) . chr(0x0331); # o with acute and macron below
    $ent{'oacub'}       = chr(0x00F3) . chr(0x0324); # o with acute and diaresis below
    $ent{'ocibb'}       = chr(0x00F4) . chr(0x0331); # o with circumflex and macron below
    $ent{'Omacbb'}      = chr(0x014C) . chr(0x0331); # O with macron and macron below
    $ent{'omacbb'}      = chr(0x014D) . chr(0x0331); # o with macron and macron below

    $ent{'iabrevb'}     = 'i' . chr(0x035C) . 'a'; # ia with doube breve below

    $ent{'gntilde'}     = 'g' . chr(0x0360) . 'n'; # gn with double tilde
    $ent{'Gntilde'}     = 'G' . chr(0x0360) . 'n'; # Gn with double tilde
    $ent{'GNtilde'}     = 'G' . chr(0x0360) . 'N'; # GN with double tilde

    $ent{'ngtilde'}     = 'n' . chr(0x0360) . 'g'; # ng with double tilde
    $ent{'Ngtilde'}     = 'N' . chr(0x0360) . 'g'; # Ng with double tilde
    $ent{'NGtilde'}     = 'N' . chr(0x0360) . 'G'; # NG with double tilde

    # More JASCHKE:
    $ent{'etilbarb'}    = chr(0x1EBD) . chr(0x0331);        # e with tilde and bar below (JASCHKE)
    $ent{'otilbarb'}    = chr(0x00F5) . chr(0x0331);        # o with tilde and bar below (JASCHKE)
    $ent{'otilumlb'}    = chr(0x00F5) . chr(0x0324);        # o with tilde and umlaut below (JASCHKE)
    $ent{'scaracu'}     = chr(0x0161) . chr(0x0301);        # s with caron and acute (JASCHKE)
    $ent{'Scaracu'}     = chr(0x0160) . chr(0x0301);        # S with caron and acute (JASCHKE)
    $ent{'zcaracu'}     = 'z' . chr(0x030C) . chr(0x0301);  # z with caron and acute (JASCHKE)
    $ent{'Zcaracu'}     = 'Z' . chr(0x030C) . chr(0x0301);  # Z with caron and acute (JASCHKE)
    $ent{'ccaracu'}     = 'c' . chr(0x030C) . chr(0x0301);  # c with caron and acute (JASCHKE)
    $ent{'Ccaracu'}     = 'C' . chr(0x030C) . chr(0x0301);  # C with caron and acute (JASCHKE)
    $ent{'jcaracu'}     = 'j' . chr(0x030C) . chr(0x0301);  # j with caron and acute (JASCHKE)
    $ent{'Jcaracu'}     = 'J' . chr(0x030C) . chr(0x0301);  # J with caron and acute (JASCHKE)
    $ent{'omacracu'}    = chr(0x014D) . chr(0x0301);        # o with macron and acute (JASCHKE)
    $ent{'obrevbarb'}   = chr(0x014F) . chr(0x0331);        # o with breve and bar below (JASCHKE)
    $ent{'obrevumlb'}   = chr(0x014F) . chr(0x0324);        # o with breve and umlaut below (JASCHKE)
    $ent{'ebrevumlb'}   = chr(0x0115) . chr(0x0324);        # e with breve and umlaut below (JASCHKE)
    $ent{'oacubrevumlb'}   = chr(0x014F) . chr(0x0301) . chr(0x0324);  # o with breve and acute and umlaut below (JASCHKE)
    $ent{'sbrevdotb'}   = 's' . chr(0x0306) . chr(0x0323);  # s with breve and dot below (JASCHKE)
    $ent{'eacubarb'}    = chr(0x00e9) . chr(0x0331);        # e with acute and bar below (JASCHKE)
    $ent{'eacudotb'}    = chr(0x00e9) . chr(0x0323);        # e with acute and dot below (JASCHKE)
    $ent{'oacuumlb'}    = chr(0x00F3) . chr(0x0324);        # o with acute and umlaut below (JASCHKE)
    $ent{'emacracu'}    = chr(0x0113) . chr(0x0301);        # e with macron and acute (JASCHKE)
    $ent{'emacrbarb'}   = chr(0x0113) . chr(0x0331);        # e with macron and bar below (JASCHKE)
    $ent{'emacracubarb'}    = chr(0x0113) . chr(0x0301) . chr(0x0331);  # e with macron and acute and bar below (JASCHKE)
    $ent{'scardotb'}    = chr(0x0161) . chr(0x0323);        # s with caron and dot below (JASCHKE)

    $ent{'aacuumlb'}    = 'a' . chr(0x0301) . chr(0x0324);  # a with acute and umlaut below (JASCHKE)
    $ent{'eacuumlb'}    = 'e' . chr(0x0301) . chr(0x0324);  # e with acute and umlaut below (JASCHKE)
    $ent{'iacuumlb'}    = 'i' . chr(0x0301) . chr(0x0324);  # i with acute and umlaut below (JASCHKE)
    $ent{'oacuumlb'}    = 'o' . chr(0x0301) . chr(0x0324);  # o with acute and umlaut below (JASCHKE)
    $ent{'uacuumlb'}    = 'u' . chr(0x0301) . chr(0x0324);  # u with acute and umlaut below (JASCHKE)
    $ent{'Aacuumlb'}    = 'A' . chr(0x0301) . chr(0x0324);  # A with acute and umlaut below (JASCHKE)
    $ent{'Eacuumlb'}    = 'E' . chr(0x0301) . chr(0x0324);  # E with acute and umlaut below (JASCHKE)
    $ent{'Iacuumlb'}    = 'I' . chr(0x0301) . chr(0x0324);  # I with acute and umlaut below (JASCHKE)
    $ent{'Oacuumlb'}    = 'O' . chr(0x0301) . chr(0x0324);  # O with acute and umlaut below (JASCHKE)
    $ent{'Uacuumlb'}    = 'U' . chr(0x0301) . chr(0x0324);  # U with acute and umlaut below (JASCHKE)

    $ent{'abreac'}      = 'a' . chr(0x0306) . chr(0x0301);  # a with breve and acute
    $ent{'Abreac'}      = 'A' . chr(0x0306) . chr(0x0301);  # A with breve and acute
    $ent{'ebreac'}      = 'e' . chr(0x0306) . chr(0x0301);  # e with breve and acute (JASCHKE)
    $ent{'Ebreac'}      = 'E' . chr(0x0306) . chr(0x0301);  # E with breve and acute
    $ent{'ibreac'}      = 'i' . chr(0x0306) . chr(0x0301);  # i with breve and acute
    $ent{'Ibreac'}      = 'I' . chr(0x0306) . chr(0x0301);  # I with breve and acute
    $ent{'obreac'}      = 'o' . chr(0x0306) . chr(0x0301);  # o with breve and acute
    $ent{'Obreac'}      = 'O' . chr(0x0306) . chr(0x0301);  # O with breve and acute

    $ent{'lowarrow'}    = chr(0x02F1);  # Modifier Letter Low Left Arrowhead (JASCHKE)
    $ent{'lowring'}     = chr(0x02F3);  # Modifier Letter Low Ring (JASCHKE)

    $ent{'Voline'}      = 'V' . chr(0x0305); # V with overline
    $ent{'Xoline'}      = 'X' . chr(0x0305); # V with overline

    # Multiple combining diacritics
    $ent{'eumlacu'}     = chr(0x00eb) . chr(0x0301); # e with diaresis and acute
    $ent{'aringacu'}    = chr(0x00E5) . chr(0x0301); # a with ring and acute

    $ent{'rdotbacu'}    = chr(0x1E5B) . chr(0x0301); # r with dot below and acute

    $ent{'aumlcirc'}    = chr(0x00E4) . chr(0x0302); # a with diaresis and circumflex
    $ent{'oumlcirc'}    = chr(0x00F6) . chr(0x0302); # o with diaresis and circumflex
    $ent{'uumlcirc'}    = chr(0x00FC) . chr(0x0302); # u with diaresis and circumflex

    $ent{'eumlbrev'}    = chr(0x00eb) . chr(0x0306); # e with diaresis and breve

    $ent{'aumlmacr'}    = chr(0x00E4) . chr(0x0304); # a with diaresis and macron
    $ent{'oumlmacr'}    = chr(0x00F6) . chr(0x0304); # o with diaresis and macron

    $ent{'uringacu'}    = chr(0x016F) . chr(0x0301); # u with ring and acute
    $ent{'uringtil'}    = chr(0x016F) . chr(0x0303); # u with ring and tilde

    $ent{'oogoncirc'}   = chr(0x01EB) . chr(0x0302); # o with ogonek and circumflex
    $ent{'oslashcirc'}  = chr(0x00f8) . chr(0x0302); # o slash and circumflex

    $ent{'ubrevacu'}    = chr(0x016D) . chr(0x0301); # u with breve and acute
    $ent{'Ebrevacu'}    = chr(0x0114) . chr(0x0301); # E with breve and acute
    $ent{'ebrevacu'}    = chr(0x0115) . chr(0x0301); # e with breve and acute
    $ent{'Obrevacu'}    = chr(0x014E) . chr(0x0301); # O with breve and acute
    $ent{'obrevacu'}    = chr(0x014F) . chr(0x0301); # o with breve and acute

    $ent{'amacrgra'}    = chr(0x0101) . chr(0x0300); # a with macron and grave
    $ent{'emacrgra'}    = chr(0x0113) . chr(0x0300); # e with macron and grave
    $ent{'imacrgra'}    = chr(0x012B) . chr(0x0300); # i with macron and grave
    $ent{'omacrgra'}    = chr(0x014D) . chr(0x0300); # o with macron and grave
    $ent{'umacrgra'}    = chr(0x016B) . chr(0x0300); # u with macron and grave

    $ent{'amacracu'}    = chr(0x0101) . chr(0x0301); # a with macron and acute
    $ent{'emacracu'}    = chr(0x0113) . chr(0x0301); # e with macron and acute
    $ent{'imacracu'}    = chr(0x012B) . chr(0x0301); # i with macron and acute
    $ent{'Imacracu'}    = chr(0x012A) . chr(0x0301); # I with macron and acute
    $ent{'omacracu'}    = chr(0x014D) . chr(0x0301); # o with macron and acute
    $ent{'umacracu'}    = chr(0x016B) . chr(0x0301); # u with macron and acute
    $ent{'Umacracu'}    = chr(0x016A) . chr(0x0301); # U with macron and acute

    $ent{'amacrcir'}    = chr(0x0101) . chr(0x0302); # a with macron and circumflex
    $ent{'imacrcir'}    = chr(0x012B) . chr(0x0302); # i with macron and circumflex
    $ent{'omacrcir'}    = chr(0x014D) . chr(0x0302); # o with macron and circumflex
    $ent{'umacrcir'}    = chr(0x016B) . chr(0x0302); # u with macron and circumflex

    $ent{'amacrdotb'}   = chr(0x0101) . chr(0x0323); # a with macron and dot below

    $ent{'rdotbcirc'}   = chr(0x1E5B) . chr(0x0302); # r with dot below and circumflex

    $ent{'Amacrtild'}   = chr(0x0100) . chr(0x0303); # A with macron and tilde
    $ent{'amacrtild'}   = chr(0x0101) . chr(0x0303); # a with macron and tilde
    $ent{'Emacrtild'}   = chr(0x0112) . chr(0x0303); # E with macron and tilde
    $ent{'emacrtild'}   = chr(0x0113) . chr(0x0303); # e with macron and tilde
    $ent{'Imacrtild'}   = chr(0x012A) . chr(0x0303); # I with macron and tilde
    $ent{'imacrtild'}   = chr(0x012B) . chr(0x0303); # i with macron and tilde
    $ent{'Omacrtild'}   = chr(0x014C) . chr(0x0303); # O with macron and tilde
    $ent{'omacrtild'}   = chr(0x014D) . chr(0x0303); # o with macron and tilde
    $ent{'Umacrtild'}   = chr(0x016A) . chr(0x0303); # U with macron and tilde
    $ent{'umacrtild'}   = chr(0x016B) . chr(0x0303); # u with macron and tilde

    $ent{'amacrbrev'}   = chr(0x0101) . chr(0x0306); # a with macron and breve
    $ent{'emacrbrev'}   = chr(0x0113) . chr(0x0306); # e with macron and breve
    $ent{'imacrbrev'}   = chr(0x012B) . chr(0x0306); # i with macron and breve
    $ent{'omacrbrev'}   = chr(0x014D) . chr(0x0306); # o with macron and breve
    $ent{'umacrbrev'}   = chr(0x016B) . chr(0x0306); # u with macron and breve
    $ent{'ymacrbrev'}   = chr(0x0233) . chr(0x0306); # y with macron and breve

    $ent{'atildmacr'}   = 'a' . chr(0x0303) . chr(0x0304); # a with tilde and macron
    $ent{'atildbrev'}   = 'a' . chr(0x0303) . chr(0x0306); # a with tilde and breve

    $ent{'edotaac'}     = chr(0x0117) . chr(0x0301); # e with dot above and acute
    $ent{'edotatil'}    = chr(0x0117) . chr(0x0303); # e with dot above and tilde
    $ent{'eumltil'}     = chr(0x00eb) . chr(0x0303); # e with diaresis and tilde

    $ent{'ecircgr'}     = chr(0x03B5) . chr(0x0302); # Greek epsilon with circumflex


    # Special dashes
    $ent{'longdash'}    = chr(0x2014) . chr(0x2014); # long dash: two em-dashes.

    $ent{'special'}     = '[#]';                     # Unknown symbol.

    # Spaces and dots
    $ent{'sp2'}         = '  ';
    $ent{'sp10'}        = '          ';
    $ent{'dots2'}       = '..';
    $ent{'dots10'}      = '..........';
    $ent{'dots20'}      = '....................';
    $ent{'dotfil'}      = '...'; # Concept of filling characters not supported in Unicode.

    $ent{'qprime'}      = chr(0x2057);          # quadruple prime
    $ent{'pprime'}      = chr(0x2033) . chr(0x2034); # Quintuple (pentuple) prime = 2 + 3 primes.


    # Meteorological symbols (used in Scott's South Pole)
    $ent{'snow'}        = '[snow]';             # symbol for snow
    $ent{'storm'}       = '[storm]';            # symbol for storm
    $ent{'mist'}        = '[mist]';             # symbol for mist
    $ent{'aurora'}      = '[aurora]';           # symbol for aurora
    $ent{'ringsun'}     = '[ringsun]';          # symbol for ring around the sun
    $ent{'ringmoon'}    = '[ringmoon]';         # symbol for ring around the moon

    $ent{'handptr'}     = chr(0x261E);          # White right pointing index
    $ent{'diamond'}     = chr(0x25C6);          # Black diamond

    $ent{'Sun'}         = chr(0x2609);          # Symbol for Sun.


    # Greek additions
    $ent{'amacgr'}      =  chr(0x1FB1);     # Greek alpha with macron
    $ent{'Amacgr'}      =  chr(0x1FB9);     # Greek Alpha with macron
    $ent{'abregr'}      =  chr(0x1FB0);     # Greek alpha with breve
    $ent{'Abregr'}      =  chr(0x1FB8);     # Greek Alpha with breve

    $ent{'imacgr'}      =  chr(0x1FD1);     # Greek alpha with macron
    $ent{'Imacgr'}      =  chr(0x1FD9);     # Greek Alpha with macron
    $ent{'ibregr'}      =  chr(0x1FD0);     # Greek alpha with breve
    $ent{'Ibregr'}      =  chr(0x1FD8);     # Greek Alpha with breve

    $ent{'umacgr'}      =  chr(0x1FE1);     # Greek alpha with macron
    $ent{'Umacgr'}      =  chr(0x1FE9);     # Greek Alpha with macron
    $ent{'ubregr'}      =  chr(0x1FE0);     # Greek alpha with breve
    $ent{'Ubregr'}      =  chr(0x1FE8);     # Greek Alpha with breve

    # The following macrons are most likely mistakes for the letters with a 'circumflex' (perispomeni)
    $ent{'emacgr'}      =  chr(0x03B5) . chr(0x0304);   # Greek epsilon with macron
    $ent{'Emacgr'}      =  chr(0x0395) . chr(0x0304);   # Greek Epsilon with macron
    $ent{'eemacgr'}     =  chr(0x03B7) . chr(0x0304);   # Greek eta with macron
    $ent{'EEmacgr'}     =  chr(0x0397) . chr(0x0304);   # Greek Eta with macron
    $ent{'omacgr'}      =  chr(0x03BF) . chr(0x0304);   # Greek omicron with macron
    $ent{'Omacgr'}      =  chr(0x039F) . chr(0x0304);   # Greek Omicron with macron
    $ent{'ohmacgr'}     =  chr(0x03C9) . chr(0x0304);   # Greek omega with macron
    $ent{'OHmacgr'}     =  chr(0x03A9) . chr(0x0304);   # Greek Omega with macron

    $ent{'supn'}        =  chr(0x207F);     # superscript n

    # Lippincott
    $ent{'a1'}          =  "a<sup>1</sup>"; # a with figure 1 above
    $ent{'a2'}          =  "a<sup>2</sup>"; # a with figure 2 above
    $ent{'a3'}          =  "a<sup>3</sup>"; # a with figure 3 above
    $ent{'a4'}          =  "a<sup>4</sup>"; # a with figure 4 above
    $ent{'e1'}          =  "e<sup>1</sup>"; # e with figure 1 above
    $ent{'e2'}          =  "e<sup>2</sup>"; # e with figure 2 above
    $ent{'i1'}          =  "i<sup>1</sup>"; # i with figure 1 above
    $ent{'i2'}          =  "i<sup>2</sup>"; # i with figure 2 above
    $ent{'o1'}          =  "o<sup>1</sup>"; # o with figure 1 above
    $ent{'o2'}          =  "o<sup>2</sup>"; # o with figure 2 above
    $ent{'u1'}          =  "u<sup>1</sup>"; # u with figure 1 above
    $ent{'u2'}          =  "u<sup>2</sup>"; # u with figure 2 above

    $ent{'a2barb'}      =  "a" . chr(0x0331) . "<sup>2</sup>"; # a with figure 2 above and bar below

    $ent{'supG'}        =  "<sup>G</sup>";  # Superior small caps G

    # See '[A-Z]sc' for actual Unicode small caps characters.
    $ent{'scA'}         =  "<sc>a</sc>";    # Small caps A
    $ent{'scB'}         =  "<sc>b</sc>";    # Small caps B
    $ent{'scC'}         =  "<sc>c</sc>";    # Small caps C
    $ent{'scD'}         =  "<sc>d</sc>";    # Small caps D
    $ent{'scE'}         =  "<sc>e</sc>";    # Small caps E
    $ent{'scF'}         =  "<sc>f</sc>";    # Small caps F
    $ent{'scG'}         =  "<sc>g</sc>";    # Small caps G
    $ent{'scH'}         =  "<sc>h</sc>";    # Small caps H
    $ent{'scI'}         =  "<sc>i</sc>";    # Small caps I
    $ent{'scJ'}         =  "<sc>j</sc>";    # Small caps J
    $ent{'scK'}         =  "<sc>k</sc>";    # Small caps K
    $ent{'scL'}         =  "<sc>l</sc>";    # Small caps L
    $ent{'scM'}         =  "<sc>m</sc>";    # Small caps M
    $ent{'scN'}         =  "<sc>n</sc>";    # Small caps N
    $ent{'scO'}         =  "<sc>o</sc>";    # Small caps O
    $ent{'scP'}         =  "<sc>p</sc>";    # Small caps P
    $ent{'scQ'}         =  "<sc>q</sc>";    # Small caps Q
    $ent{'scR'}         =  "<sc>r</sc>";    # Small caps R
    $ent{'scS'}         =  "<sc>s</sc>";    # Small caps S
    $ent{'scT'}         =  "<sc>t</sc>";    # Small caps T
    $ent{'scU'}         =  "<sc>u</sc>";    # Small caps U
    $ent{'scV'}         =  "<sc>v</sc>";    # Small caps V
    $ent{'scW'}         =  "<sc>w</sc>";    # Small caps W
    $ent{'scX'}         =  "<sc>x</sc>";    # Small caps X
    $ent{'scY'}         =  "<sc>y</sc>";    # Small caps Y
    $ent{'scZ'}         =  "<sc>z</sc>";    # Small caps Z

    ###############################################################################
    # Project Gutenberg boilerplate texts

    $ent{'availability.en'} = "This eBook is for the use of anyone anywhere at no cost and with almost no restrictions whatsoever. You may copy it, give it away or re-use it under the terms of the Project Gutenberg License included with this eBook or online at <xref url='https://www.gutenberg.org/'>www.gutenberg.org</xref>.";

    $ent{'availability.nl'} = "Dit eBoek is voor kosteloos gebruik door iedereen overal, met vrijwel geen beperkingen van welke soort dan ook. U mag het kopi&#xEB;ren, weggeven of hergebruiken onder de voorwaarden van de Project Gutenberg Licentie in dit eBoek of on-line op <xref url='https://www.gutenberg.org/'>www.gutenberg.org</xref>.";

    # Common abbreviations in small-caps.

    $ent{'BC'} = "<hi rend='asc'>b.c.</hi>";
    $ent{'AD'} = "<hi rend='asc'>a.d.</hi>";
    $ent{'AH'} = "<hi rend='asc'>a.h.</hi>";
    $ent{'AM'} = "<hi rend='asc'>a.m.</hi>";
    $ent{'PM'} = "<hi rend='asc'>p.m.</hi>";

    # More superscripts
    $ent{'supc'}   = chr(0x1D9C);               # superscript c (cycles)
    $ent{'supa'}   = chr(0x1D43);               # superscript a (years)
    $ent{'supd'}   = chr(0x1D48);               # superscript d (days)
    $ent{'supm'}   = chr(0x1D50);               # superscript m (minutes)
    $ent{'suph'}   = chr(0x02B0);               # superscript h (hours)
    $ent{'sups'}   = chr(0x02E2);               # superscript s (seconds)

    $ent{'supI'}   = chr(0x1D35);               # superscript I
    $ent{'supII'}  = chr(0x1D35) . chr(0x1D35); # superscript II
    $ent{'supIII'} = chr(0x1D35) . chr(0x1D35) . chr(0x1D35); # superscript III
    $ent{'supIV'}  = chr(0x1D35) . chr(0x2C7D); # superscript IV
    $ent{'supV'}   = chr(0x2C7D);               # superscript V
    $ent{'supVI'}  = chr(0x2C7D) . chr(0x1D35); # superscript VI

    # Phantom symbols for proper alignment in tables (rendered with visibility: hidden; in HTML).
    $ent{'ph.comma'}  = "<ab type='phantom'>,</ab>";                       # Phantom comma
    $ent{'ph.period'} = "<ab type='phantom'>.</ab>";                       # Phantom period
    $ent{'ph.zero'}   = "<ab type='phantom'>0</ab>";                       # Phantom zero
    $ent{'ph.czero'}  = "<ab type='phantom'>,0</ab>";                      # Phantom comma zero
    $ent{'ph.czz'}    = "<ab type='phantom'>,00</ab>";                     # Phantom comma zero zero
    $ent{'ph.pzero'}  = "<ab type='phantom'>.0</ab>";                      # Phantom period zero
    $ent{'ph.deg'}    = "<ab type='phantom'>" . chr(0x00B0) . '</ab>';     # Phantom degree sign
    $ent{'ph.pr'}     = "<ab type='phantom'>" . chr(0x2032) . '</ab>';     # Phantom prime
    $ent{'ph.Pr'}     = "<ab type='phantom'>" . chr(0x2033) . '</ab>';     # Phantom double prime
    $ent{'ph.tpr'}    = "<ab type='phantom'>" . chr(0x2034) . '</ab>';     # Phantom triple prime
    $ent{'ph.qpr'}    = "<ab type='phantom'>" . chr(0x2057) . '</ab>';     # Phantom quadruple prime
    $ent{'ph.ppr'}    = "<ab type='phantom'>" . chr(0x2033) . chr(0x2034) . '</ab>'; # Phantom quintuple (pentuple) prime = 2 + 3 primes.

    $ent{'ph.supc'}   = "<ab type='phantom'>" . chr(0x1D9C) . '</ab>';   # Phantom superscript c (cycles)
    $ent{'ph.supa'}   = "<ab type='phantom'>" . chr(0x1D43) . '</ab>';   # Phantom superscript a (years)
    $ent{'ph.supd'}   = "<ab type='phantom'>" . chr(0x1D48) . '</ab>';   # Phantom superscript d (days)
    $ent{'ph.supm'}   = "<ab type='phantom'>" . chr(0x1D50) . '</ab>';   # Phantom superscript m (minutes)
    $ent{'ph.suph'}   = "<ab type='phantom'>" . chr(0x02B0) . '</ab>';   # Phantom superscript h (hours)
    $ent{'ph.sups'}   = "<ab type='phantom'>" . chr(0x02E2) . '</ab>';   # Phantom superscript s (seconds)

    $ent{'ph.supI'}   = "<ab type='phantom'>" . chr(0x1D35) . '</ab>';   # Phantom superscript I
    $ent{'ph.supII'}  = "<ab type='phantom'>" . chr(0x1D35) . chr(0x1D35) . '</ab>';  # Phantom superscript II
    $ent{'ph.supIII'} = "<ab type='phantom'>" . chr(0x1D35) . chr(0x1D35) . chr(0x1D35) . '</ab>'; # Phantom superscript III
    $ent{'ph.supIV'}  = "<ab type='phantom'>" . chr(0x1D35) . chr(0x2C7D) . '</ab>';  # Phantom superscript IV
    $ent{'ph.supV'}   = "<ab type='phantom'>" . chr(0x2C7D) . '</ab>';   # Phantom superscript V
    $ent{'ph.supVI'}  = "<ab type='phantom'>" . chr(0x2C7D) . chr(0x1D35) . '</ab>';  # Phantom superscript VI

    %reverse = ();

    foreach my $key (keys %ent) {
        my $value = $ent{$key};
        if (defined $value) {
            if (defined $reverse{$value}) {
                # print "$key already mapped.\n";
            } else {
                $reverse{$value} = $key;
            }
        }
    }

    # Duplicate entities from above.
    $ent{'peso'}        = chr(0x20B1);  # Peso sign
    $ent{'euro'}        = chr(0x20AC);  # Euro sign
    $ent{'vardollar'}   = '$';          # Variant dollar sign (with diagonal slashes)
    $ent{'florin'}      = chr(0x0192);  # LATIN SMALL LETTER F WITH HOOK

    $ent{'apos'}        = chr(0x2019);  # LEFT SINGLE QUOTATION MARK
    $ent{'commal'}      = ',';          # (comma used as letter)

    $ent{'lsquor'}      = chr(0x201A);  # SINGLE LOW-9 QUOTATION MARK
    $ent{'rdquor'}      = chr(0x201C);  # LEFT DOUBLE QUOTATION MARK
    $ent{'rsquor'}      = chr(0x2018);  # LEFT SINGLE QUOTATION MARK
    $ent{'ldquor'}      = chr(0x201E);  # DOUBLE LOW-9 QUOTATION MARK
    $ent{'idagger'}     = chr(0x2020);  # inverted DAGGER (not Unicode, so using dagger!)
    $ent{'perp'}        = chr(0x22A5);  # UP TACK
    $ent{'Tinv'}        = chr(0x22A5);  # UP TACK (Inversed T)
    $ent{'alefsym'}     = chr(0x2135);  # ALEF SYMBOL
    $ent{'mldr'}        = chr(0x2026);  # HORIZONTAL ELLIPSIS
    $ent{'die'}         = chr(0x00A8);  # DIAERESIS
    $ent{'Dot'}         = chr(0x00A8);  # DIAERESIS
    $ent{'sbsol'}       = chr(0x005C);  # REVERSE SOLIDUS
    $ent{'samalg'}      = chr(0x2210);  # N-ARY COPRODUCT
    $ent{'amalg'}       = chr(0x2210);  # N-ARY COPRODUCT
    $ent{'prop'}        = chr(0x221D);  # PROPORTIONAL TO
    $ent{'spar'}        = chr(0x2225);  # PARALLEL TO
    $ent{'nspar'}       = chr(0x2226);  # NOT PARALLEL TO
    $ent{'thksim'}      = chr(0x223C);  # TILDE OPERATOR
    $ent{'thkap'}       = chr(0x2248);  # ALMOST EQUAL TO
    $ent{'asymp'}       = chr(0x2248);  # ALMOST EQUAL TO
    $ent{'subE'}        = chr(0x2286);  # SUBSET OF OR EQUAL TO
    $ent{'supE'}        = chr(0x2287);  # SUPERSET OF OR EQUAL TO
    $ent{'nsubE'}       = chr(0x2288);  # NEITHER A SUBSET OF NOR EQUAL TO
    $ent{'nsupE'}       = chr(0x2289);  # NEITHER A SUPERSET OF NOR EQUAL TO
    $ent{'vsubnE'}      = chr(0x228A);  # SUBSET OF WITH NOT EQUAL TO
    $ent{'subnE'}       = chr(0x228A);  # SUBSET OF WITH NOT EQUAL TO
    $ent{'vsupnE'}      = chr(0x228B);  # SUPERSET OF WITH NOT EQUAL TO
    $ent{'supnE'}       = chr(0x228B);  # SUPERSET OF WITH NOT EQUAL TO
    $ent{'vsubne'}      = chr(0x228A);  # SUBSET OF WITH NOT EQUAL TO
    $ent{'vsupne'}      = chr(0x228B);  # SUPERSET OF WITH NOT EQUAL TO
    $ent{'ssetmn'}      = chr(0x2216);  # SET MINUS
    $ent{'nges'}        = chr(0x2271);  # NEITHER GREATER-THAN NOR EQUAL TO
    $ent{'nles'}        = chr(0x2270);  # NEITHER LESS-THAN NOR EQUAL TO
    $ent{'gvnE'}        = chr(0x2269);  # GREATER-THAN BUT NOT EQUAL TO
    $ent{'gnE'}         = chr(0x2269);  # GREATER-THAN BUT NOT EQUAL TO
    $ent{'lnE'}         = chr(0x2268);  # LESS-THAN BUT NOT EQUAL TO
    $ent{'lvnE'}        = chr(0x2268);  # LESS-THAN BUT NOT EQUAL TO
    $ent{'les'}         = chr(0x2264);  # LESS-THAN OR EQUAL TO
    $ent{'ges'}         = chr(0x2265);  # GREATER-THAN OR EQUAL TO
    $ent{'vprime'}      = chr(0x2032);  # PRIME
    $ent{'bbar'}        = chr(0x0180);  # b with stroke through stem
    $ent{'ayin'}        = chr(0x02BF);  # modifier letter left half ring
    $ent{'cupre'}       = chr(0x227C);  # PRECEDES OR EQUAL TO
    $ent{'sccue'}       = chr(0x227D);  # SUCCEEDS OR EQUAL TO
    $ent{'sfrown'}      = chr(0x2322);  # FROWN
    $ent{'ssmile'}      = chr(0x2323);  # SMILE
    $ent{'half'}        = chr(0x00BD);  # VULGAR FRACTION ONE HALF
    $ent{'iff'}         = chr(0x21D4);  # LEFT RIGHT DOUBLE ARROW

    # Arrows and shapes
    $ent{'xcirc'}       = chr(0x25CB);  # WHITE CIRCLE
    $ent{'xdtri'}       = chr(0x25BD);  # WHITE DOWN-POINTING TRIANGLE
    $ent{'xharr'}       = chr(0x2194);  # LEFT RIGHT ARROW
    $ent{'xhArr'}       = chr(0x2194);  # LEFT RIGHT ARROW
    $ent{'xlArr'}       = chr(0x21D0);  # LEFTWARDS DOUBLE ARROW
    $ent{'xrArr'}       = chr(0x21D2);  # RIGHTWARDS DOUBLE ARROW
    $ent{'xutri'}       = chr(0x25B3);  # WHITE UP-POINTING TRIANGLE
    $ent{'squ'}         = chr(0x25A1);  # WHITE SQUARE
    $ent{'bullet'}      = chr(0x2022);  # Bullet
    $ent{'maltese'}     = chr(0x2720);  # Maltese cross

    # Metrical symbols
    $ent{'metlong'}     = chr(0x2013);  # metrical long symbol (= EN DASH)
    $ent{'metbrev'}     = chr(0x23D1);  # METRICAL BREVE SYMBOL
    $ent{'metlobr'}     = chr(0x23D2);  # METRICAL LONG OVER BREVE SYMBOL
    $ent{'metbreak'}    = chr(0x201E);  # metrical break (= DOUBLE LOW-9 QUOTATION MARK)

    # Greek letters
    $ent{'sigmav'}      = chr(0x03C2);  # GREEK SMALL LETTER FINAL SIGMA
    $ent{'sigmaf'}      = chr(0x03C2);  # GREEK SMALL LETTER FINAL SIGMA
    $ent{'thetav'}      = chr(0x03D1);  # GREEK THETA SYMBOL
    $ent{'gammad'}      = chr(0x03DC);  # GREEK LETTER DIGAMMA
    $ent{'phis'}        = chr(0x03C6);  # GREEK SMALL LETTER PHI

    $ent{'Alpha'}       = chr(0x0391);  # GREEK CAPITAL LETTER ALPHA
    $ent{'Beta'}        = chr(0x0392);  # GREEK CAPITAL LETTER BETA
    $ent{'Gamma'}       = chr(0x0393);  # GREEK CAPITAL LETTER GAMMA
    $ent{'Delta'}       = chr(0x0394);  # GREEK CAPITAL LETTER DELTA
    $ent{'Epsilon'}     = chr(0x0395);  # GREEK CAPITAL LETTER EPSILON
    $ent{'Zeta'}        = chr(0x0396);  # GREEK CAPITAL LETTER ZETA
    $ent{'Eta'}         = chr(0x0397);  # GREEK CAPITAL LETTER ETA
    $ent{'Theta'}       = chr(0x0398);  # GREEK CAPITAL LETTER THETA
    $ent{'Iota'}        = chr(0x0399);  # GREEK CAPITAL LETTER IOTA
    $ent{'Kappa'}       = chr(0x039A);  # GREEK CAPITAL LETTER KAPPA
    $ent{'Lambda'}      = chr(0x039B);  # GREEK CAPITAL LETTER LAMDA
    $ent{'Mu'}          = chr(0x039C);  # GREEK CAPITAL LETTER MU
    $ent{'Nu'}          = chr(0x039D);  # GREEK CAPITAL LETTER NU
    $ent{'Xi'}          = chr(0x039E);  # GREEK CAPITAL LETTER XI
    $ent{'Omicron'}     = chr(0x039F);  # GREEK CAPITAL LETTER OMICRON
    $ent{'Pi'}          = chr(0x03A0);  # GREEK CAPITAL LETTER PI
    $ent{'Rho'}         = chr(0x03A1);  # GREEK CAPITAL LETTER RHO
    $ent{'Sigma'}       = chr(0x03A3);  # GREEK CAPITAL LETTER SIGMA
    $ent{'Tau'}         = chr(0x03A4);  # GREEK CAPITAL LETTER TAU
    $ent{'Upsilon'}     = chr(0x03A5);  # GREEK CAPITAL LETTER UPSILON
    $ent{'Upsi'}        = chr(0x03A5);  # GREEK CAPITAL LETTER UPSILON
    $ent{'Phi'}         = chr(0x03A6);  # GREEK CAPITAL LETTER PHI
    $ent{'Chi'}         = chr(0x03A7);  # GREEK CAPITAL LETTER CHI
    $ent{'Psi'}         = chr(0x03A8);  # GREEK CAPITAL LETTER PSI
    $ent{'Omega'}       = chr(0x03A9);  # GREEK CAPITAL LETTER OMEGA
    $ent{'alpha'}       = chr(0x03B1);  # GREEK SMALL LETTER ALPHA
    $ent{'beta'}        = chr(0x03B2);  # GREEK SMALL LETTER BETA
    $ent{'gamma'}       = chr(0x03B3);  # GREEK SMALL LETTER GAMMA
    $ent{'delta'}       = chr(0x03B4);  # GREEK SMALL LETTER DELTA
    $ent{'epsilon'}     = chr(0x03B5);  # GREEK SMALL LETTER EPSILON
    $ent{'epsi'}        = chr(0x03B5);  # GREEK SMALL LETTER EPSILON
    $ent{'zeta'}        = chr(0x03B6);  # GREEK SMALL LETTER ZETA
    $ent{'eta'}         = chr(0x03B7);  # GREEK SMALL LETTER ETA
    $ent{'thetas'}      = chr(0x03B8);  # GREEK SMALL LETTER THETA
    $ent{'theta'}       = chr(0x03B8);  # GREEK SMALL LETTER THETA
    $ent{'iota'}        = chr(0x03B9);  # GREEK SMALL LETTER IOTA
    $ent{'kappa'}       = chr(0x03BA);  # GREEK SMALL LETTER KAPPA
    $ent{'lambda'}      = chr(0x03BB);  # GREEK SMALL LETTER LAMDA
    $ent{'mu'}          = chr(0x03BC);  # GREEK SMALL LETTER MU
    $ent{'nu'}          = chr(0x03BD);  # GREEK SMALL LETTER NU
    $ent{'xi'}          = chr(0x03BE);  # GREEK SMALL LETTER XI
    $ent{'omicron'}     = chr(0x03BF);  # GREEK SMALL LETTER OMICRON
    $ent{'pi'}          = chr(0x03C0);  # GREEK SMALL LETTER PI
    $ent{'rho'}         = chr(0x03C1);  # GREEK SMALL LETTER RHO
    $ent{'sigma'}       = chr(0x03C3);  # GREEK SMALL LETTER SIGMA
    $ent{'tau'}         = chr(0x03C4);  # GREEK SMALL LETTER TAU
    $ent{'upsilon'}     = chr(0x03C5);  # GREEK SMALL LETTER UPSILON
    $ent{'upsi'}        = chr(0x03C5);  # GREEK SMALL LETTER UPSILON
    $ent{'phi'}         = chr(0x03C6);  # GREEK SMALL LETTER PHI
    $ent{'chi'}         = chr(0x03C7);  # GREEK SMALL LETTER CHI
    $ent{'psi'}         = chr(0x03C8);  # GREEK SMALL LETTER PSI
    $ent{'omega'}       = chr(0x03C9);  # GREEK SMALL LETTER OMEGA

    $ent{'b.Gamma'}     = chr(0x0393);  # GREEK CAPITAL LETTER GAMMA
    $ent{'b.Delta'}     = chr(0x0394);  # GREEK CAPITAL LETTER DELTA
    $ent{'b.Theta'}     = chr(0x0398);  # GREEK CAPITAL LETTER THETA
    $ent{'b.Lambda'}    = chr(0x039B);  # GREEK CAPITAL LETTER LAMDA
    $ent{'b.Xi'}        = chr(0x039E);  # GREEK CAPITAL LETTER XI
    $ent{'b.Pi'}        = chr(0x03A0);  # GREEK CAPITAL LETTER PI
    $ent{'b.Sigma'}     = chr(0x03A3);  # GREEK CAPITAL LETTER SIGMA
    $ent{'b.Upsi'}      = chr(0x03A5);  # GREEK CAPITAL LETTER UPSILON
    $ent{'b.Phi'}       = chr(0x03A6);  # GREEK CAPITAL LETTER PHI
    $ent{'b.Psi'}       = chr(0x03A8);  # GREEK CAPITAL LETTER PSI
    $ent{'b.Omega'}     = chr(0x03A9);  # GREEK CAPITAL LETTER OMEGA
    $ent{'b.alpha'}     = chr(0x03B1);  # GREEK SMALL LETTER ALPHA
    $ent{'b.beta'}      = chr(0x03B2);  # GREEK SMALL LETTER BETA
    $ent{'b.gamma'}     = chr(0x03B3);  # GREEK SMALL LETTER GAMMA
    $ent{'b.delta'}     = chr(0x03B4);  # GREEK SMALL LETTER DELTA
    $ent{'b.epsiv'}     = chr(0x03B5);  # GREEK SMALL LETTER EPSILON
    $ent{'b.epsis'}     = chr(0x03B5);  # GREEK SMALL LETTER EPSILON
    $ent{'b.epsi'}      = chr(0x03B5);  # GREEK SMALL LETTER EPSILON
    $ent{'b.zeta'}      = chr(0x03B6);  # GREEK SMALL LETTER ZETA
    $ent{'b.eta'}       = chr(0x03B7);  # GREEK SMALL LETTER ETA
    $ent{'b.thetas'}    = chr(0x03B8);  # GREEK SMALL LETTER THETA
    $ent{'b.iota'}      = chr(0x03B9);  # GREEK SMALL LETTER IOTA
    $ent{'b.kappa'}     = chr(0x03BA);  # GREEK SMALL LETTER KAPPA
    $ent{'b.lambda'}    = chr(0x03BB);  # GREEK SMALL LETTER LAMDA
    $ent{'b.mu'}        = chr(0x03BC);  # GREEK SMALL LETTER MU
    $ent{'b.nu'}        = chr(0x03BD);  # GREEK SMALL LETTER NU
    $ent{'b.xi'}        = chr(0x03BE);  # GREEK SMALL LETTER XI
    $ent{'b.pi'}        = chr(0x03C0);  # GREEK SMALL LETTER PI
    $ent{'b.rho'}       = chr(0x03C1);  # GREEK SMALL LETTER RHO
    $ent{'b.sigmav'}    = chr(0x03C2);  # GREEK SMALL LETTER FINAL SIGMA
    $ent{'b.sigma'}     = chr(0x03C3);  # GREEK SMALL LETTER SIGMA
    $ent{'b.tau'}       = chr(0x03C4);  # GREEK SMALL LETTER TAU
    $ent{'b.upsi'}      = chr(0x03C5);  # GREEK SMALL LETTER UPSILON
    $ent{'b.phis'}      = chr(0x03C6);  # GREEK SMALL LETTER PHI
    $ent{'b.chi'}       = chr(0x03C7);  # GREEK SMALL LETTER CHI
    $ent{'b.psi'}       = chr(0x03C8);  # GREEK SMALL LETTER PSI
    $ent{'b.omega'}     = chr(0x03CE);  # GREEK SMALL LETTER OMEGA WITH TONOS
    $ent{'b.thetav'}    = chr(0x03D1);  # GREEK THETA SYMBOL
    $ent{'b.phiv'}      = chr(0x03D5);  # GREEK PHI SYMBOL
    $ent{'b.piv'}       = chr(0x03D6);  # GREEK PI SYMBOL
    $ent{'b.gammad'}    = chr(0x03DC);  # GREEK LETTER DIGAMMA
    $ent{'b.kappav'}    = chr(0x03F0);  # GREEK KAPPA SYMBOL
    $ent{'b.rhov'}      = chr(0x03F1);  # GREEK RHO SYMBOL

    # Normalize codes to the NFC form.
    foreach my $key (keys %ent) {
        my $nfcValue = NFC($ent{$key});
        if ($ent{$key} ne $nfcValue) {
            # print STDERR "    \$ent{'$key'}    = " . utf2chr($nfcValue) . ";\n";
            $ent{$key} = $nfcValue;
        }
    }
}


# Get an attribute value (if the attribute is present)
#
# Usage:
#   getAttrVal($attrName, $attrs)
# Parameters:
#   $attrName: the name of which the attribute value is required.
#   $attrs: string with SGML style attributes:  A=abc B="test" C="aap"
#           empty string when not present.

sub getAttrVal {
    my $attrName = shift;
    my $attrs = shift;

    if ($attrs =~ /$attrName\s*=\s*([\w.-]+)/i) {
        return $1;
    } elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i) {
        return $1;
    }
    return '';
}


# Map SGML entities to Unicode in UTF-8
#
# Usage:
#   sgml2utf($string)
# Parameter:
#   $string: the string to be converted to UTF-8.

sub sgml2utf {
    my $string = shift;
    return sgml2utf_common($string, 0);
}

sub sgml2utf_html {
    my $string = shift;
    return sgml2utf_common($string, 1);
}

sub sgml2utf_common {
    my $remainder = shift;
    my $forHtml = shift;
    my $result = '';

    while ($remainder =~ /\&(#?[a-z0-9._-]+);/i) {
        $result .= $`;
        my $entity = $1;
        $remainder = $';

        my $char = '';
        if ($forHtml == 1 && $entity eq 'lt') {
            $char = '&lt;';
        } elsif ($forHtml == 1 && $entity eq 'gt') {
            $char = '&gt;';
        } elsif ($forHtml == 1 && $entity eq 'quot') {
            $char = '&quot;';
        } elsif ($forHtml == 1 && $entity eq 'amp') {
            $char = '&amp;';
        } elsif (defined $ent{$entity}) {
            $char = $ent{$entity};
        } elsif ($entity =~ /#x([a-f0-9]+)/i) {
            $char = chr(hex($1));
        } elsif ($entity =~ /#([0-9]+)/) {
            $char = chr($1);
        } elsif ($entity =~ /^frac([0-9])([0-9]+)$/) {
            $char = handleFraction($1, $2, $result, $remainder);
        } elsif ($entity =~ /^frac([0-9]+)-([0-9]+)$/) {
            $char = handleFraction($1, $2, $result, $remainder);
        } elsif ($entity =~ /^time([0-9])([0-9]+)$/) {
            $char = handleMusicalTime($1, $2);
        } else {
            $char = '&' . $entity . ';';
            print STDERR "ERROR:   unmapped SGML entity: $char\n";
        }
        $result .= $char;
    }
    $result .= $remainder;
    return $result;
}

sub handleFraction {
    my $numerator = shift;
    my $denominator = shift;
    my $before = shift;
    my $after = shift;

    # Insert a zero-width space before (after) the fraction if no whitespace is already present before (after).
    my $leftBoundary = ($before =~ /\s$/) ? '' : chr(0x200B);
    my $rightBoundary = ($after =~ /^\s/) ? '' : chr(0x200B);

    return  $leftBoundary . $numerator . chr(0x2044) . $denominator . $rightBoundary;
}

sub handleMusicalTime {
    my $top = shift;
    my $bottom = shift;

    return  '<ab type="musictime"><ab type="top">' . $top . '</ab><ab type="bottom">' .  $bottom . '</ab></ab>';
}


# Map Unicode to (numeric) SGML entities
#
# Usage:
#   utf2sgml($string)
# Parameter:
#   $string: the string to be converted to UTF-8.

sub utf2sgml {
    my $string = shift;

    my @chars = split(//, $string);
    foreach (@chars) {
        if (ord($_) > 127) {
            $_ = '&#' . ord($_) . ';';
        }
    }
    return join('', @chars);
}


sub translateEntity($) {
    my $entity = shift;
    if (defined $ent{$entity}) {
        return $ent{$entity};
    } elsif ($entity =~ /^frac([0-9])([0-9]+)$/) {
        return $1 . '/' . $2;
    } elsif ($entity =~ /^frac([0-9]+)-([0-9]+)$/) {
        return $1 . '/' . $2;
    }
    # print STDERR "ERROR:   unmapped SGML entity: $entity\n";
    return '';
}


# Map Unicode to SGML entities, trying to use named entities when possible.
#
# Usage:
#   utf2entities($string)
# Parameter:
#   $string: the string to be converted to entities.

sub utf2entities {
    my $string = shift;

    my @chars = split(//, $string);
    foreach (@chars) {
        if (ord($_) > 127) {
            if ($reverse{$_}) {
                $_ = '&' . $reverse{$_} . ';';
            } else {
                $_ = '&#' . ord($_) . ';';
            }
        }
    }
    return join('', @chars);
}

sub utf2numericEntities {
    my $string = shift;

    my @chars = split(//, $string);
    foreach (@chars) {
        if (ord($_) > 127) {
            $_ = '&#x' . sprintf('%04X', ord($_)) . ';';
        }
    }
    return join('', @chars);
}


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
    $string =~ s/\['=o]/\&omacracu;/g;                  #  o with macron and acute (JASCHKE)
    $string =~ s/\['=a]/\&amacracu;/g;                  #  a with macron and acute (JASCHKE)
    $string =~ s/\[=e=]/\&emacrbarb;/g;                 # e with macron and bar below (JASCHKE)
    $string =~ s/\['=e=]/\&emacracubarb;/g;             # e with macron and acute and bar below (JASCHKE)
    $string =~ s/\[\)o=]/\&obrevbarb;/g;                #  o with breve and bar below (JASCHKE)
    $string =~ s/\[\)o:]/\&obrevumlb;/g;                #  o with breve and umlaut below (JASCHKE)
    $string =~ s/\[\)e:]/\&ebrevumlb;/g;                #  e with breve and umlaut below (JASCHKE)
    $string =~ s/\['\)o:]/\&oacubrevumlb;/g;            #  o with breve and acute and umlaut below (JASCHKE)
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
