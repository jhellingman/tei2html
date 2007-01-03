
package LanguageNames;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getLanguage);


BEGIN
{

	%langNameHash = ();

	$langNameHash{"af"}			= "Afrikaans";
	$langNameHash{"ar"}			= "Arabic";
	$langNameHash{"ar-latn"}	= "Arabic (Latin transcription)";
	$langNameHash{"as"}			= "Assamese";
	$langNameHash{"cy"}			= "Welsh";
	$langNameHash{"da"}			= "Danish";
	$langNameHash{"de"}			= "German";
	$langNameHash{"el"}			= "Greek";
	$langNameHash{"en"}			= "English";
	$langNameHash{"en-1500"}	= "English (16th century)";
	$langNameHash{"en-1600"}	= "English (17th century)";
	$langNameHash{"en-1700"}	= "English (18th century)";
	$langNameHash{"en-1800"}	= "English (19th century)";
	$langNameHash{"en-uk"}		= "English (United Kingdom)";
	$langNameHash{"en-us"}		= "English (United States)";
	$langNameHash{"es"}			= "Spanish";
	$langNameHash{"et"}			= "Estonian";
	$langNameHash{"fa"}			= "Persian";
	$langNameHash{"fi"}			= "Finnish";
	$langNameHash{"fr"}			= "French";
	$langNameHash{"fy"}			= "Frisian";
	$langNameHash{"gd"}			= "Scots Gaelic";
	$langNameHash{"he"}			= "Hebrew";
	$langNameHash{"he-latn"}	= "Hebrew (Latin transcription)";
	$langNameHash{"hi"}			= "Hindi";
	$langNameHash{"hi-latn"}	= "Hindi (Latin transcription)";
	$langNameHash{"hr"}			= "Croatian";
	$langNameHash{"it"}			= "Italian";
	$langNameHash{"jp"}			= "Japanese";
	$langNameHash{"jp-hira"}	= "Japanese (Hiragana)";
	$langNameHash{"jp-latn"}	= "Japanese (Latin transcription)";
	$langNameHash{"la"}			= "Latin";
	$langNameHash{"la-x-bio"}	= "Latin (Biological nomenclature)";
	$langNameHash{"nl"}			= "Dutch";
	$langNameHash{"nl-1500"}	= "Dutch (16th century)";
	$langNameHash{"nl-1600"}	= "Dutch (17th century)";
	$langNameHash{"nl-1700"}	= "Dutch (18th century)";
	$langNameHash{"nl-1800"}	= "Dutch (19th century)";
	$langNameHash{"nl-1900"}	= "Dutch (spelling De Vries-Te Winkel)";
	$langNameHash{"pl"}			= "Polish";
	$langNameHash{"pt"}			= "Portuguese";
	$langNameHash{"ro"}			= "Romanian";
	$langNameHash{"ru"}			= "Russian";
	$langNameHash{"ru-latn"}	= "Russian (Latin transcription)";
	$langNameHash{"sa"}			= "Sanskrit";
	$langNameHash{"sa-latn"}	= "Sanskrit (Latin transcription)";
	$langNameHash{"sd"}			= "Sindhi";
	$langNameHash{"sd-latn"}	= "Sindhi (Latin transcription)";
	$langNameHash{"se"}			= "Swedish";
	$langNameHash{"sr"}			= "Serbian";
	$langNameHash{"sr-latn"}    = "Serbian (Latin script)";
	$langNameHash{"sy"}			= "Syriac";
	$langNameHash{"tl"}			= "Tagalog";
	$langNameHash{"tl-1900"}	= "Tagalog (19th and early 20th century)";
	$langNameHash{"zh-latn"}	= "Chinese (Latin transcription)";

	$langNameHash{"grc"}		= "Greek (classical)";

	$langNameHash{"bik"}		= "Bicolano or Bikol";
	$langNameHash{"bis"}		= "Bisayan (unspecified)";
	$langNameHash{"ceb"}		= "Cebuano";
	$langNameHash{"crb"}		= "Chavacano, Chabacano or Zamboangue&ntilde;o";
	$langNameHash{"hil"}		= "Hiligaynon";
	$langNameHash{"ilo"}		= "Ilocano, Iloko or Ilokano";
	$langNameHash{"pag"}		= "Pangasin&aacute;n";
	$langNameHash{"pam"}		= "Kapampangan";
	$langNameHash{"war"}		= "W&aacute;ray-W&aacute;ray";
	$langNameHash{"haw"}		= "Hawaiian";
	$langNameHash{"kha"}		= "Khasi";


	$langNameHash{"gad"}		= "Gaddang";

	$langNameHash{"xx"}			= "unknown language";
	$langNameHash{"und"}		= "undetermined language";

	$langNameHash{"obab"}		= "Old Babylonian (Latin transcription)";


}



sub getLanguage
{
	my $code = shift;
	return $langNameHash{$code};
}

