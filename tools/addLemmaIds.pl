

# add lemma ids to a digitized dictionary in TEI encoding

# Pattern  
#
#        <p><b>Lemma</b>, text of lemma
#        <p><b>Two words</b>, text of lemma
#        <p><b>Caf&eacute;</b>, text of lemma
#        <p><b>Lemma</b>, I). first meaning.--II). second meaning
#
# To be replaced with 
#
#        <p id=lemma><b>Lemma</b>, text of lemma
#        <p id=two_words><b>Two words</b>, text of lemma
#        <p id=cafe><b>Caf&eacute;</b>, text of lemma
#        <p id=lemma><b>Lemma</b>, <ab id=lemma_1>I)</ab>. first meaning.--<ab id=lemma_2>II)</ab>. second meaning
#
# And references to be replaced as follows:
#
#        z. lemma -> z. <ref target=lemma>lemma</a>
#        z. lemma No 2.-> z. <ref target=lemma2>lemma No 2.</a>


%lemmaHash = ();
%collisionHash = ();


$patLemma = /<p><hi rend=bold>(.*?)</hi>/;
$patMeaningNumber = /&mdash;([0-9]*)\./;


$patCrossReference = /zie (men|ook) ([a-z]+)/;
$patCrossReference = /z. ([a-z]+)/;
$patCrossReference = /([a-z]+) \((z. a.)|(zie aldaar)\)/;

# multiple references:
$patCrossReference = /zie (men|ook|verder|echter onder) ([a-z]+)( en ([a-z]+))/;

# Optionally, we can link from all words for which we have a lemma.


sub createIds
{
    # find paragraphs starting with bold words and comma
    # extract lemma
    # insert id tag.

    # Special case: Greek lemma (not bold)
    # - just use greek letters in ID.

    # Special case: multiple meanings (numbered 1) 2) 3)
    # - tag the numbers with <ab> and numbered id. (lemma_1, lemma_2, etc.) (register collision on lemma)

}


sub createRefs
{
    # find potential cross references (words in italics, preceeded with "zie" or something similar.
    # lookup whether we have an id for it.
    # link to it.

    # special case: collision:
    # - handle by adding reference to lemma_X. This will need to be manually resolved.

}


sub createId
{
    # strip diacritics
    # replace spaces with underscores
    # fold to lowercase
    # check for possible collision (add letter to end to avoid collision)  (lemma_a, lemma_b, etc.) (register collision on lemma)

}





