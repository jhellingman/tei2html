
package LanguageNames;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getLanguage);


BEGIN
{
    %langNameHash = ();

    # ISO 639-1 Language Codes (and variants)

    $langNameHash{"aa"}        = "Afar";
    $langNameHash{"ab"}        = "Abkhazian";
    $langNameHash{"af"}        = "Afrikaans";
    $langNameHash{"am"}        = "Amharic";
    $langNameHash{"an"}        = "Aragonese";
    $langNameHash{"ar"}        = "Arabic";
    $langNameHash{"ar-latn"}   = "Arabic (Latin transcription)";
    $langNameHash{"as"}        = "Assamese";
    $langNameHash{"ay"}        = "Aymara";
    $langNameHash{"az"}        = "Azerbaijani";
    $langNameHash{"ba"}        = "Bashkir";
    $langNameHash{"be"}        = "Byelorussian (Belarusian)";
    $langNameHash{"bg"}        = "Bulgarian";
    $langNameHash{"bh"}        = "Bihari";
    $langNameHash{"bi"}        = "Bislama";
    $langNameHash{"bn"}        = "Bengali (Bangla)";
    $langNameHash{"bo"}        = "Tibetan";
    $langNameHash{"bo-latn"}   = "Tibetan (Latin transcription)";
    $langNameHash{"br"}        = "Breton";
    $langNameHash{"bs"}        = "Bosnian";
    $langNameHash{"ca"}        = "Catalan";
    $langNameHash{"co"}        = "Corsican";
    $langNameHash{"cs"}        = "Czech";
    $langNameHash{"cy"}        = "Welsh";
    $langNameHash{"da"}        = "Danish";
    $langNameHash{"de"}        = "German";
    $langNameHash{"dz"}        = "Bhutani";
    $langNameHash{"el"}        = "Greek";
    $langNameHash{"el-latn"}   = "Greek (Latin transcription)";
    $langNameHash{"en"}        = "English";
    $langNameHash{"en-1200"}   = "English (13th century)";
    $langNameHash{"en-1500"}   = "English (16th century)";
    $langNameHash{"en-1600"}   = "English (17th century)";
    $langNameHash{"en-1700"}   = "English (18th century)";
    $langNameHash{"en-1800"}   = "English (19th century)";
    $langNameHash{"en-uk"}     = "English (United Kingdom)";
    $langNameHash{"en-us"}     = "English (United States)";
    $langNameHash{"eo"}        = "Esperanto";
    $langNameHash{"es"}        = "Spanish";
    $langNameHash{"et"}        = "Estonian";
    $langNameHash{"eu"}        = "Basque";
    $langNameHash{"fa"}        = "Farsi";
    $langNameHash{"fi"}        = "Finnish";
    $langNameHash{"fj"}        = "Fiji";
    $langNameHash{"fo"}        = "Faeroese";
    $langNameHash{"fr"}        = "French";
    $langNameHash{"fy"}        = "Frisian";
    $langNameHash{"fy-wwo"}    = "Frisian (Westerwold)";
    $langNameHash{"ga"}        = "Irish";
    $langNameHash{"gd"}        = "Gaelic (Scottish)";
    $langNameHash{"gl"}        = "Galician";
    $langNameHash{"gn"}        = "Guarani";
    $langNameHash{"gu"}        = "Gujarati";
    $langNameHash{"gv"}        = "Gaelic (Manx)";
    $langNameHash{"ha"}        = "Hausa";
    $langNameHash{"he"}        = "Hebrew";
    $langNameHash{"he-latn"}   = "Hebrew (Latin transcription)";
    $langNameHash{"hi"}        = "Hindi";
    $langNameHash{"hi-latn"}   = "Hindi (Latin transcription)";
    $langNameHash{"hr"}        = "Croatian";
    $langNameHash{"ht"}        = "Haitian Creole";
    $langNameHash{"hu"}        = "Hungarian";
    $langNameHash{"hy"}        = "Armenian";
    $langNameHash{"ia"}        = "Interlingua";
    $langNameHash{"id"}        = "Indonesian";
    $langNameHash{"ie"}        = "Interlingue";
    $langNameHash{"ii"}        = "Sichuan Yi";
    $langNameHash{"ik"}        = "Inupiak";
    $langNameHash{"io"}        = "Ido";
    $langNameHash{"is"}        = "Icelandic";
    $langNameHash{"it"}        = "Italian";
    $langNameHash{"iu"}        = "Inuktitut";
    $langNameHash{"ja"}        = "Japanese";
    $langNameHash{"jp-hira"}   = "Japanese (Hiragana)";
    $langNameHash{"jp-latn"}   = "Japanese (Latin transcription)";
    $langNameHash{"jv"}        = "Javanese";
    $langNameHash{"ka"}        = "Georgian";
    $langNameHash{"ka-latn"}   = "Georgian (Latin transcription)";
    $langNameHash{"kk"}        = "Kazakh";
    $langNameHash{"kl"}        = "Greenlandic";
    $langNameHash{"km"}        = "Cambodian";
    $langNameHash{"kn"}        = "Kannada";
    $langNameHash{"ko"}        = "Korean";
    $langNameHash{"ks"}        = "Kashmiri";
    $langNameHash{"ku"}        = "Kurdish";
    $langNameHash{"ky"}        = "Kirghiz";
    $langNameHash{"la"}        = "Latin";
    $langNameHash{"la-x-bio"}  = "Latin (Biological nomenclature)";
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
    $langNameHash{"my-latn"}   = "Burmese (Latin transcription)";
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
    $langNameHash{"nl-ach"}    = "Dutch (Achterhoek)";
    $langNameHash{"nl-be"}     = "Dutch (Belgium)";
    $langNameHash{"nl-dia"}    = "Dutch (unspecified dialect)";
    $langNameHash{"nl-gro"}    = "Dutch (Groningen)";
    $langNameHash{"nl-lim"}    = "Dutch (Limburg)";
    $langNameHash{"nl-nl"}     = "Dutch (Netherlands)";
    $langNameHash{"nl-obr"}    = "Dutch (Oost-Brabant)";
    $langNameHash{"nl-ovl"}    = "Dutch (Oost-Vlaanderen)";
    $langNameHash{"nl-wbr"}    = "Dutch (West-Brabant)";
    $langNameHash{"nl-wvl"}    = "Dutch (West-Vlaanderen)";
    $langNameHash{"nl-zee"}    = "Dutch (Zeeland)";
    $langNameHash{"nn"}        = "Norwegian (Nynorsk)";
    $langNameHash{"no"}        = "Norwegian";
    $langNameHash{"oc"}        = "Occitan";
    $langNameHash{"om"}        = "Oromo (Afan, Galla)";
    $langNameHash{"or"}        = "Oriya";
    $langNameHash{"pa"}        = "Punjabi";
    $langNameHash{"pl"}        = "Polish";
    $langNameHash{"ps"}        = "Pashto (Pushto)";
    $langNameHash{"pt"}        = "Portuguese";
    $langNameHash{"pt-br"}     = "Portuguese (Brazil)";
    $langNameHash{"qu"}        = "Quechua";
    $langNameHash{"rm"}        = "Rhaeto-Romance";
    $langNameHash{"rn"}        = "Kirundi (Rundi)";
    $langNameHash{"ro"}        = "Romanian";
    $langNameHash{"ru"}        = "Russian";
    $langNameHash{"ru-latn"}   = "Russian (Latin transcription)";
    $langNameHash{"rw"}        = "Kinyarwanda (Ruanda)";
    $langNameHash{"sa"}        = "Sanskrit";
    $langNameHash{"sa-latn"}   = "Sanskrit (Latin transcription)";
    $langNameHash{"sd"}        = "Sindhi";
    $langNameHash{"sd-latn"}   = "Sindhi (Latin transcription)";
    $langNameHash{"sg"}        = "Sangro";
    $langNameHash{"sh"}        = "Serbo-Croatian";
    $langNameHash{"si"}        = "Sinhalese";
    $langNameHash{"sk"}        = "Slovak";
    $langNameHash{"sl"}        = "Slovenian";
    $langNameHash{"sm"}        = "Samoan";
    $langNameHash{"sn"}        = "Shona";
    $langNameHash{"so"}        = "Somali";
    $langNameHash{"sq"}        = "Albanian";
    $langNameHash{"sr"}        = "Serbian";
    $langNameHash{"sr-latn"}   = "Serbian (Latin script)";
    $langNameHash{"ss"}        = "Siswati";
    $langNameHash{"st"}        = "Sesotho";
    $langNameHash{"su"}        = "Sundanese";
    $langNameHash{"sv"}        = "Swedish";
    $langNameHash{"sw"}        = "Swahili (Kiswahili)";
    $langNameHash{"sy"}        = "Syriac";
    $langNameHash{"ta"}        = "Tamil";
    $langNameHash{"ta-latn"}   = "Tamil (Latin transcription)";
    $langNameHash{"te"}        = "Telugu";
    $langNameHash{"tg"}        = "Tajik";
    $langNameHash{"th"}        = "Thai";
    $langNameHash{"ti"}        = "Tigrinya";
    $langNameHash{"tk"}        = "Turkmen";
    $langNameHash{"tl"}        = "Tagalog";
    $langNameHash{"tl-1900"}   = "Tagalog (19th and early 20th century orthography)";
    $langNameHash{"tl-bayb"}   = "Tagalog (in Baybayin script)";
    $langNameHash{"tn"}        = "Setswana";
    $langNameHash{"to"}        = "Tonga";
    $langNameHash{"tr"}        = "Turkish";
    $langNameHash{"ts"}        = "Tsonga";
    $langNameHash{"tt"}        = "Tatar";
    $langNameHash{"tw"}        = "Twi";
    $langNameHash{"ug"}        = "Uighur";
    $langNameHash{"uk"}        = "Ukrainian";
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
    $langNameHash{"zh-cn"}     = "Chinese (Simplified)";
    $langNameHash{"zh-tw"}     = "Chinese (Traditional)";
    $langNameHash{"zh-latn"}   = "Chinese (Latin transcription)";
    $langNameHash{"zu"}        = "Zulu";


    # Three letter codes

    $langNameHash{"grc"}        = "Greek (classical)";

    $langNameHash{"bik"}        = "Bicolano or Bikol";
    $langNameHash{"bis"}        = "Bisayan (unspecified)";
    $langNameHash{"ceb"}        = "Cebuano";
    $langNameHash{"crb"}        = "Chavacano, Chabacano or Zamboangue&ntilde;o";
    $langNameHash{"hil"}        = "Hiligaynon";
    $langNameHash{"ilo"}        = "Ilocano, Iloko or Ilokano";
    $langNameHash{"pag"}        = "Pangasin&aacute;n";
    $langNameHash{"pam"}        = "Kapampangan";
    $langNameHash{"war"}        = "W&aacute;ray-W&aacute;ray";
    $langNameHash{"phi"}        = "Philippine (Other)";
    $langNameHash{"ifu"}        = "Ifugao";

    $langNameHash{"sit"}            = "Sino-Tibetan (Other)";
    $langNameHash{"sit-ao"}         = "Ao Naga, unspecified dialect";
    $langNameHash{"sit-ao-mongsen"} = "Ao Naga, Mongsen dialect";
    $langNameHash{"sit-ao-chongli"} = "Ao Naga, Chongli dialect";
    $langNameHash{"sit-sema"}       = "Sema Naga";
    $langNameHash{"sit-angami"}     = "Angami Naga";
    $langNameHash{"mni"}            = "Meitei or Manipuri";
    $langNameHash{"mni-old"}        = "Old Meitei or Old Manipuri";

    $langNameHash{"haw"}        = "Hawaiian";
    $langNameHash{"kha"}        = "Khasi";

    $langNameHash{"gad"}        = "Gaddang";

    $langNameHash{"xx"}         = "unknown language";
    $langNameHash{"und"}        = "undetermined language";

    $langNameHash{"obab"}       = "Old Babylonian (Latin transcription)";
}


sub getLanguage($)
{
    my $code = shift;
    my $language = $langNameHash{$code};
    if (defined $language)
    {
        $language = "Language with code $code";
    }
    return $langNameHash{$code};
}
