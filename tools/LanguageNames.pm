
package LanguageNames;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getLanguage);


BEGIN {
    %langNameHash = ();

    # ISO 639-1 Language Codes (and variants)

    $langNameHash{"aa"}        = "Afar";
    $langNameHash{"ab"}        = "Abkhazian";
    $langNameHash{"af"}        = "Afrikaans";
    $langNameHash{"am"}        = "Amharic";
    $langNameHash{"an"}        = "Aragonese";
    $langNameHash{"ang"}       = "Anglo-Saxon";
    $langNameHash{"ar"}        = "Arabic";
    $langNameHash{"ar-Latn"}   = "Arabic (Latin transcription)";
    $langNameHash{"as"}        = "Assamese";
    $langNameHash{"as-Latn"}   = "Assamese (Latin transcription)";
    $langNameHash{"ay"}        = "Aymara";
    $langNameHash{"az"}        = "Azerbaijani";
    $langNameHash{"ba"}        = "Bashkir";
    $langNameHash{"be"}        = "Byelorussian (Belarusian)";
    $langNameHash{"bg"}        = "Bulgarian";
    $langNameHash{"bh"}        = "Bihari";
    $langNameHash{"bi"}        = "Bislama";
    $langNameHash{"bn"}        = "Bengali (Bangla)";
    $langNameHash{"bn-Latn"}   = "Bengali (Latin transcription)";
    $langNameHash{"bo"}        = "Tibetan";
    $langNameHash{"bo-Latn"}   = "Tibetan (Latin transcription)";
    $langNameHash{"br"}        = "Breton";
    $langNameHash{"bs"}        = "Bosnian";
    $langNameHash{"ca"}        = "Catalan";
    $langNameHash{"co"}        = "Corsican";
    $langNameHash{"cs"}        = "Czech";
    $langNameHash{"cs-cz"}     = "Czech (Czech Republic)";
    $langNameHash{"cy"}        = "Welsh";
    $langNameHash{"da"}        = "Danish";
    $langNameHash{"de"}        = "German";
    $langNameHash{"dz"}        = "Bhutani";
    $langNameHash{"el"}        = "Greek";
    $langNameHash{"el-Latn"}   = "Greek (Latin transcription)";
    $langNameHash{"en"}        = "English";
    $langNameHash{"en-1200"}   = "English (13th century)";
    $langNameHash{"en-1300"}   = "English (14th century)";
    $langNameHash{"en-1400"}   = "English (15th century)";
    $langNameHash{"en-1500"}   = "English (16th century)";
    $langNameHash{"en-1600"}   = "English (17th century)";
    $langNameHash{"en-1700"}   = "English (18th century)";
    $langNameHash{"en-1800"}   = "English (19th century)";
    $langNameHash{"en-UK"}     = "English (United Kingdom)";
    $langNameHash{"en-US"}     = "English (United States)";
    $langNameHash{"en-Phon"}   = "English (Phonetic notation)";
    $langNameHash{"eo"}        = "Esperanto";
    $langNameHash{"es"}        = "Spanish";
    $langNameHash{"es-ES"}     = "Spanish (Spain)";
    $langNameHash{"es-MX"}     = "Spanish (Mexico)";
    $langNameHash{"et"}        = "Estonian";
    $langNameHash{"eu"}        = "Basque";
    $langNameHash{"fa"}        = "Farsi";
    $langNameHash{"fi"}        = "Finnish";
    $langNameHash{"fj"}        = "Fiji";
    $langNameHash{"fo"}        = "Faeroese";
    $langNameHash{"fr"}        = "French";
    $langNameHash{"fr-1400"}   = "French (15th century)";
    $langNameHash{"fy"}        = "Frisian";
    $langNameHash{"fy-wwo"}    = "Frisian (Westerwold)";
    $langNameHash{"ga"}        = "Irish";
    $langNameHash{"gd"}        = "Gaelic (Scottish)";
    $langNameHash{"gl"}        = "Galician";
    $langNameHash{"gn"}        = "Guarani";
    $langNameHash{"gu"}        = "Gujarati";
    $langNameHash{"gu-Latn"}   = "Gujarati (Latin transcription)";
    $langNameHash{"gv"}        = "Gaelic (Manx)";
    $langNameHash{"ha"}        = "Hausa";
    $langNameHash{"he"}        = "Hebrew";
    $langNameHash{"he-Latn"}   = "Hebrew (Latin transcription)";
    $langNameHash{"hi"}        = "Hindi";
    $langNameHash{"hi-Latn"}   = "Hindi (Latin transcription)";
    $langNameHash{"hr"}        = "Croatian";
    $langNameHash{"ht"}        = "Haitian Creole";
    $langNameHash{"hu"}        = "Hungarian";
    $langNameHash{"hy"}        = "Armenian";
    $langNameHash{"hy-Latn"}   = "Armenian (Latin transcription)";
    $langNameHash{"ia"}        = "Interlingua";
    $langNameHash{"id"}        = "Indonesian";
    $langNameHash{"ie"}        = "Interlingue";
    $langNameHash{"ii"}        = "Sichuan Yi";
    $langNameHash{"ik"}        = "Inupiak";
    $langNameHash{"io"}        = "Ido";
    $langNameHash{"iro"}       = "Iroquoian";
    $langNameHash{"is"}        = "Icelandic";
    $langNameHash{"it"}        = "Italian";
    $langNameHash{"iu"}        = "Inuktitut";
    $langNameHash{"iu-Latn"}   = "Inuktitut (Latin script)";
    $langNameHash{"ja"}        = "Japanese";
    $langNameHash{"ja-Hira"}   = "Japanese (Hiragana)";
    $langNameHash{"ja-Kana"}   = "Japanese (Katakana)";
    $langNameHash{"ja-Latn"}   = "Japanese (Latin transcription)";
    $langNameHash{"jv"}        = "Javanese";
    $langNameHash{"ka"}        = "Georgian";
    $langNameHash{"ka-Latn"}   = "Georgian (Latin transcription)";
    $langNameHash{"ki"}        = "Kikuyu";
    $langNameHash{"kg"}        = "Kikongo";
    $langNameHash{"kk"}        = "Kazakh";
    $langNameHash{"kl"}        = "Greenlandic";
    $langNameHash{"km"}        = "Cambodian";
    $langNameHash{"kn"}        = "Kannada";
    $langNameHash{"ko"}        = "Korean";
    $langNameHash{"ks"}        = "Kashmiri";
    $langNameHash{"ku"}        = "Kurdish";
    $langNameHash{"ky"}        = "Kirghiz";
    $langNameHash{"la"}        = "Latin";
    $langNameHash{"la-x-bio"}  = "Latin (Biological names)";
    $langNameHash{"li"}        = "Limburgish (Limburger)";
    $langNameHash{"ln"}        = "Lingala";
    $langNameHash{"lo"}        = "Laothian";
    $langNameHash{"lt"}        = "Lithuanian";
    $langNameHash{"lv"}        = "Latvian (Lettish)";
    $langNameHash{"mg"}        = "Malagasy";
    $langNameHash{"mi"}        = "Maori";
    $langNameHash{"mk"}        = "Macedonian";
    $langNameHash{"ml"}        = "Malayalam";
    $langNameHash{"mn"}        = "Mongolian";
    $langNameHash{"mo"}        = "Moldavian";
    $langNameHash{"mr"}        = "Marathi";
    $langNameHash{"ms"}        = "Malay";
    $langNameHash{"mt"}        = "Maltese";
    $langNameHash{"my"}        = "Burmese";
    $langNameHash{"my-Latn"}   = "Burmese (Latin transcription)";
    $langNameHash{"na"}        = "Nauru";
    $langNameHash{"nb"}        = "Norwegian (Bokm&aring;l)";
    $langNameHash{"ne"}        = "Nepali";
    $langNameHash{"nl"}        = "Dutch";
    $langNameHash{"nl-1400"}   = "Dutch (15th century)";
    $langNameHash{"nl-1500"}   = "Dutch (16th century)";
    $langNameHash{"nl-1600"}   = "Dutch (17th century)";
    $langNameHash{"nl-1700"}   = "Dutch (18th century)";
    $langNameHash{"nl-1800"}   = "Dutch (19th century)";
    $langNameHash{"nl-1900"}   = "Dutch (spelling De Vries-Te Winkel)";
    $langNameHash{"nl-ZA-1920"} = "Dutch (Simplified spelling; South Africa)";
    $langNameHash{"nl-ach"}    = "Dutch (Achterhoek)";
    $langNameHash{"nl-BE"}     = "Dutch (Belgium)";
    $langNameHash{"nl-dia"}    = "Dutch (unspecified dialect)";
    $langNameHash{"nl-gro"}    = "Dutch (Groningen)";
    $langNameHash{"nl-lim"}    = "Dutch (Limburg)";
    $langNameHash{"nl-NL"}     = "Dutch (Netherlands)";
    $langNameHash{"nl-obr"}    = "Dutch (Oost-Brabant)";
    $langNameHash{"nl-ovl"}    = "Dutch (Oost-Vlaanderen)";
    $langNameHash{"nl-wbr"}    = "Dutch (West-Brabant)";
    $langNameHash{"nl-wvl"}    = "Dutch (West-Vlaanderen)";
    $langNameHash{"nl-zee"}    = "Dutch (Zeeland)";
    $langNameHash{"nn"}        = "Norwegian (Nynorsk)";
    $langNameHash{"no"}        = "Norwegian";
    $langNameHash{"oc"}        = "Occitan";
    $langNameHash{"oj"}        = "Ojibwa";
    $langNameHash{"om"}        = "Oromo (Afan, Galla)";
    $langNameHash{"or"}        = "Oriya";
    $langNameHash{"pa"}        = "Punjabi";
    $langNameHash{"pl"}        = "Polish";
    $langNameHash{"ps"}        = "Pashto (Pushto)";
    $langNameHash{"pt"}        = "Portuguese";
    $langNameHash{"pt-BR"}     = "Portuguese (Brazil)";
    $langNameHash{"qu"}        = "Quechua";
    $langNameHash{"rm"}        = "Rhaeto-Romance";
    $langNameHash{"rn"}        = "Kirundi (Rundi)";
    $langNameHash{"ro"}        = "Romanian";
    $langNameHash{"ru"}        = "Russian";
    $langNameHash{"ru-Latn"}   = "Russian (Latin transcription)";
    $langNameHash{"rw"}        = "Kinyarwanda (Ruanda)";
    $langNameHash{"sa"}        = "Sanskrit";
    $langNameHash{"sa-Latn"}   = "Sanskrit (Latin transcription)";
    $langNameHash{"sd"}        = "Sindhi";
    $langNameHash{"sd-Latn"}   = "Sindhi (Latin transcription)";
    $langNameHash{"see"}       = "Seneca";
    $langNameHash{"sg"}        = "Sangro";
    $langNameHash{"sh"}        = "Serbo-Croatian";
    $langNameHash{"si"}        = "Sinhalese";
    $langNameHash{"si-Latn"}   = "Sinhalese (Latin transcription)";
    $langNameHash{"sk"}        = "Slovak";
    $langNameHash{"sl"}        = "Slovenian";
    $langNameHash{"sm"}        = "Samoan";
    $langNameHash{"sn"}        = "Shona";
    $langNameHash{"so"}        = "Somali";
    $langNameHash{"sq"}        = "Albanian";
    $langNameHash{"sr"}        = "Serbian";
    $langNameHash{"sr-Latn"}   = "Serbian (Latin script)";
    $langNameHash{"ss"}        = "Siswati";
    $langNameHash{"st"}        = "Sesotho";
    $langNameHash{"su"}        = "Sundanese";
    $langNameHash{"sv"}        = "Swedish";
    $langNameHash{"sw"}        = "Swahili (Kiswahili)";
    $langNameHash{"sy"}        = "Syriac";
    $langNameHash{"ta"}        = "Tamil";
    $langNameHash{"ta-Latn"}   = "Tamil (Latin transcription)";
    $langNameHash{"te"}        = "Telugu";
    $langNameHash{"te-Latn"}   = "Telugu (Latin transcription)";
    $langNameHash{"tg"}        = "Tajik";
    $langNameHash{"th"}        = "Thai";
    $langNameHash{"ti"}        = "Tigrinya";
    $langNameHash{"tk"}        = "Turkmen";
    $langNameHash{"tl"}        = "Tagalog";
    $langNameHash{"tl-1900"}   = "Tagalog (19th and early 20th century orthography)";
    $langNameHash{"tl-Tglg"}   = "Tagalog (in old Tagalog or Baybayin script)";
    $langNameHash{"tn"}        = "Setswana";
    $langNameHash{"to"}        = "Tonga";
    $langNameHash{"tr"}        = "Turkish";
    $langNameHash{"ts"}        = "Tsonga";
    $langNameHash{"tt"}        = "Tatar";
    $langNameHash{"tw"}        = "Twi";
    $langNameHash{"ug"}        = "Uighur";
    $langNameHash{"uk"}        = "Ukrainian";
    $langNameHash{"uk-Latn"}   = "Ukrainian (Latin transcription)";
    $langNameHash{"ur"}        = "Urdu";
    $langNameHash{"uz"}        = "Uzbek";
    $langNameHash{"vi"}        = "Vietnamese";
    $langNameHash{"vo"}        = "Volap&uuml;k";
    $langNameHash{"wa"}        = "Wallon";
    $langNameHash{"wo"}        = "Wolof";
    $langNameHash{"xh"}        = "Xhosa";
    $langNameHash{"yi"}        = "Yiddish";
    $langNameHash{"yi"}        = "Yiddish";
    $langNameHash{"yo"}        = "Yoruba";
    $langNameHash{"zh"}        = "Chinese";
    $langNameHash{"zh-CN"}     = "Chinese (Simplified)";
    $langNameHash{"zh-TW"}     = "Chinese (Traditional)";
    $langNameHash{"zh-Latn"}   = "Chinese (Latin transcription)";
    $langNameHash{"zu"}        = "Zulu";

    # Three letter codes
    $langNameHash{"akk"}            = "Akkadian";
    $langNameHash{"akk-Latn"}       = "Akkadian (Latin transcription)";
    $langNameHash{"alq"}            = "Algonquian";
    $langNameHash{"ang"}            = "Old English";
    $langNameHash{"bnc"}            = "Bontoc";
    $langNameHash{"bik"}            = "Bicolano or Bikol";
    $langNameHash{"bis"}            = "Bisayan (unspecified)";
    $langNameHash{"brx"}            = "Bodo langauge";
    $langNameHash{"brx-Latn"}       = "Bodo langauge (Latin transcription)";
    $langNameHash{"ceb"}            = "Cebuano";
    $langNameHash{"com"}            = "Comanche";
    $langNameHash{"crb"}            = "Chavacano, Chabacano or Zamboangue&ntilde;o";
    $langNameHash{"dak"}            = "Dakota";
    $langNameHash{"egy"}            = "Egyptian (ancient)";
    $langNameHash{"esx"}            = "Eskimo-Aleut languages";
    $langNameHash{"gad"}            = "Gaddang";
    $langNameHash{"grc"}            = "Greek (classical)";
    $langNameHash{"grc-Latn"}       = "Greek (classical, Latin transcription)";
    $langNameHash{"grt"}            = "Garo";
    $langNameHash{"hai"}            = "Haida";
    $langNameHash{"haw"}            = "Hawaiian";
    $langNameHash{"hax"}            = "Southern Haida";
    $langNameHash{"hdn"}            = "Northern Haida";
    $langNameHash{"hil"}            = "Hiligaynon";
    $langNameHash{"ibl"}            = "Ibaloi";
    $langNameHash{"ifu"}            = "Ifugao";
    $langNameHash{"ilo"}            = "Ilocano, Iloko or Ilokano";
    $langNameHash{"kam"}            = "Kamba";
    $langNameHash{"kar"}            = "Karen";
    $langNameHash{"kha"}            = "Khasi";
    $langNameHash{"kij"}            = "Kilivila";
    $langNameHash{"lad"}            = "Ladino";
    $langNameHash{"mas"}            = "Maasai";
    $langNameHash{"mjw"}            = "Karbi language";
    $langNameHash{"mni"}            = "Meitei or Manipuri";
    $langNameHash{"nah"}            = "Nahuatl (Aztec)";
    $langNameHash{"nbc"}            = "Chang";
    $langNameHash{"njh"}            = "Lhota";
    $langNameHash{"njm"}            = "Angami";
    $langNameHash{"njn"}            = "Liangmai";
    $langNameHash{"njo"}            = "Ao";
    $langNameHash{"non"}            = "Old Norse";
    $langNameHash{"nsa"}            = "Sangtam";
    $langNameHash{"nsm"}            = "Sema";
    $langNameHash{"nzm"}            = "Zeme";
    $langNameHash{"ota"}            = "Ottoman Turkish";
    $langNameHash{"ota-Latn"}       = "Ottoman Turkish (Latin transcription)";
    $langNameHash{"pag"}            = "Pangasin&aacute;n";
    $langNameHash{"pam"}            = "Kapampangan";
    $langNameHash{"phi"}            = "Philippine (Other)";
    $langNameHash{"rue"}            = "Rusyn";
    $langNameHash{"sit"}            = "Sino-Tibetan (Other)";
    $langNameHash{"tcz"}            = "Thadou";
    $langNameHash{"tsg"}            = "Tausug";
    $langNameHash{"war"}            = "W&aacute;ray-W&aacute;ray";
    $langNameHash{"win"}            = "Winnebago";
    $langNameHash{"xac"}            = "Kachari";
    $langNameHash{"yua"}            = "Yucatec Maya";

    # Special codes
    $langNameHash{"mis"}            = "uncoded languages";
    $langNameHash{"mul"}            = "multiple languages";
    $langNameHash{"und"}            = "undetermined";
    $langNameHash{"zxx"}            = "no linguistic content / not applicable";

    # Non-standard extensions
    $langNameHash{"mni-old"}        = "Old Meitei or Old Manipuri";
    $langNameHash{"sit-angami"}     = "Angami Naga"; # -> njm
    $langNameHash{"sit-ao"}         = "Ao Naga, unspecified dialect"; # -> njo
    $langNameHash{"sit-ao-chongli"} = "Ao Naga, Chongli dialect";
    $langNameHash{"sit-ao-mongsen"} = "Ao Naga, Mongsen dialect";
    $langNameHash{"sit-sema"}       = "Sema Naga"; # -> nsm
}


sub getLanguage($) {
    my $code = shift;
    my $language = $langNameHash{$code};
    if (defined $language) {
        $language = "Language with code $code";
    }
    return $langNameHash{$code};
}
