
package LanguageNames;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getLanguage);


BEGIN
{
    %langNameHash = ();

    $langNameHash{"af"}         = "Afrikaans";
    $langNameHash{"ar"}         = "Arabic";
    $langNameHash{"ar-latn"}    = "Arabic (Latin transcription)";
    $langNameHash{"as"}         = "Assamese";

    $langNameHash{"bn"}         = "Bengali";
    $langNameHash{"bo"}         = "Tibetan";
    $langNameHash{"bo-latn"}    = "Tibetan (Latin transcription)";

    $langNameHash{"cy"}         = "Welsh";

    $langNameHash{"da"}         = "Danish";
    $langNameHash{"de"}         = "German";

    $langNameHash{"el"}         = "Greek";
    $langNameHash{"el-latn"}    = "Greek (Latin transcription)";
    $langNameHash{"en"}         = "English";
    $langNameHash{"en-1500"}    = "English (16th century)";
    $langNameHash{"en-1600"}    = "English (17th century)";
    $langNameHash{"en-1700"}    = "English (18th century)";
    $langNameHash{"en-1800"}    = "English (19th century)";
    $langNameHash{"en-uk"}      = "English (United Kingdom)";
    $langNameHash{"en-us"}      = "English (United States)";
    $langNameHash{"eo"}         = "Esperanto";
    $langNameHash{"es"}         = "Spanish";
    $langNameHash{"et"}         = "Estonian";
    $langNameHash{"eu"}         = "Basque";

    $langNameHash{"fa"}         = "Persian";
    $langNameHash{"fi"}         = "Finnish";
    $langNameHash{"fr"}         = "French";
    $langNameHash{"fy"}         = "Frisian";
    $langNameHash{"fy-wwo"}     = "Frisian (Westerwold)";

    $langNameHash{"gd"}         = "Scots Gaelic";

    $langNameHash{"he"}         = "Hebrew";
    $langNameHash{"he-latn"}    = "Hebrew (Latin transcription)";
    $langNameHash{"hi"}         = "Hindi";
    $langNameHash{"hi-latn"}    = "Hindi (Latin transcription)";
    $langNameHash{"hr"}         = "Croatian";

    $langNameHash{"it"}         = "Italian";

    $langNameHash{"jp"}         = "Japanese";
    $langNameHash{"jp-hira"}    = "Japanese (Hiragana)";
    $langNameHash{"jp-latn"}    = "Japanese (Latin transcription)";

    $langNameHash{"la"}         = "Latin";
    $langNameHash{"la-x-bio"}   = "Latin (Biological nomenclature)";

    $langNameHash{"my"}         = "Burmese";
    $langNameHash{"my-latn"}    = "Burmese (Latin transcription)";

    $langNameHash{"nl"}         = "Dutch";
    $langNameHash{"nl-nl"}      = "Dutch (Netherlands)";
    $langNameHash{"nl-be"}      = "Dutch (Belgium)";

    $langNameHash{"nl-1400"}    = "Dutch (15th century)";
    $langNameHash{"nl-1500"}    = "Dutch (16th century)";
    $langNameHash{"nl-1600"}    = "Dutch (17th century)";
    $langNameHash{"nl-1700"}    = "Dutch (18th century)";
    $langNameHash{"nl-1800"}    = "Dutch (19th century)";
    $langNameHash{"nl-1900"}    = "Dutch (spelling De Vries-Te Winkel)";

    $langNameHash{"nl-dia"}     = "Dutch (unspecified dialect)";
    $langNameHash{"nl-ach"}     = "Dutch (Achterhoek)";
    $langNameHash{"nl-gro"}     = "Dutch (Groningen)";
    $langNameHash{"nl-lim"}     = "Dutch (Limburg)";
    $langNameHash{"nl-obr"}     = "Dutch (Oost-Brabant)";
    $langNameHash{"nl-ovl"}     = "Dutch (Oost-Vlaanderen)";
    $langNameHash{"nl-wbr"}     = "Dutch (West-Brabant)";
    $langNameHash{"nl-wvl"}     = "Dutch (West-Vlaanderen)";
    $langNameHash{"nl-zee"}     = "Dutch (Zeeland)";

    $langNameHash{"no"}         = "Norwegian";
    $langNameHash{"nn"}         = "Norwegian (Nynorsk)";
    $langNameHash{"nb"}         = "Norwegian (Bokm&aring;l)";

    $langNameHash{"pl"}         = "Polish";
    $langNameHash{"pt"}         = "Portuguese";
    $langNameHash{"pt-br"}      = "Portuguese (Brazil)";

    $langNameHash{"ro"}         = "Romanian";
    $langNameHash{"ru"}         = "Russian";
    $langNameHash{"ru-latn"}    = "Russian (Latin transcription)";

    $langNameHash{"sa"}         = "Sanskrit";
    $langNameHash{"sa-latn"}    = "Sanskrit (Latin transcription)";
    $langNameHash{"sd"}         = "Sindhi";
    $langNameHash{"sd-latn"}    = "Sindhi (Latin transcription)";
    $langNameHash{"se"}         = "Swedish";
    $langNameHash{"sr"}         = "Serbian";
    $langNameHash{"sr-latn"}    = "Serbian (Latin script)";
    $langNameHash{"sy"}         = "Syriac";

    $langNameHash{"ta"}         = "Tamil";
    $langNameHash{"ta-latn"}    = "Tamil (Latin transcription)";
    $langNameHash{"tl"}         = "Tagalog";
    $langNameHash{"tl-1900"}    = "Tagalog (19th and early 20th century orthography)";
    $langNameHash{"tl-bayb"}    = "Tagalog (in Baybayin script)";
    $langNameHash{"tm"}         = "Tamil";
    $langNameHash{"tm-latn"}    = "Tamil (Latin transcription)";
    $langNameHash{"tr"}         = "Turkish";

    $langNameHash{"zh"}         = "Chinese";
    $langNameHash{"zh-latn"}    = "Chinese (Latin transcription)";

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



sub getLanguage
{
    my $code = shift;
    return $langNameHash{$code};
}

