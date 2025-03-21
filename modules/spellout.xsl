<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xsl">

  <xsl:function name="f:spell-out" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="number"/>

    <xsl:variable name="number" select="xs:string($number)"/>

    <xsl:sequence select="
      if (matches($number, '^[0-9]+$')) then f:spell-out-integer($lang, xs:integer($number))
      else if (matches($number, '^[0-9]+\.[0-9]+$')) then f:spell-out-decimal($lang, xs:decimal($number))
      else $number"/>
  </xsl:function>

  <!-- power and log functions not in saxon-HE, so make do with poor-man’s versions. -->
  <xsl:function name="f:power1000" as="xs:integer">
    <xsl:param name="group" as="xs:integer"/>
    <xsl:sequence select="if ($group = 0) then 1 else f:power1000($group - 1) * 1000"/>
  </xsl:function>

  <xsl:function name="f:log1000" as="xs:integer">
    <xsl:param name="number" as="xs:integer"/>
    <xsl:sequence select="xs:integer(ceiling(string-length(xs:string($number)) div 3)) - 1"/>
  </xsl:function>

  <!-- Language selection -->
  <xsl:function name="f:spell-out-digits">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="number" as="xs:string"/>

    <xsl:sequence select="if ($lang = 'nl') then f:nl-spell-out-digits($number) else f:en-spell-out-digits($number)"/>
  </xsl:function>

  <xsl:function name="f:spell-out-integer" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="number" as="xs:integer"/>

    <xsl:sequence select="if ($lang = 'nl') then f:nl-spell-out($number) else f:en-spell-out($number)"/>
  </xsl:function>

  <xsl:function name="f:spell-out-decimal" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="number" as="xs:decimal"/>

    <xsl:sequence select="if ($lang = 'nl') then f:nl-spell-out-decimal($number) else f:en-spell-out-decimal($number)"/>
  </xsl:function>

  <!-- English -->

  <xsl:variable name="en-cardinal" as="map(xs:integer, xs:string)" select="map {
      0:  'zero',
      1:  'one',
      2:  'two',
      3:  'three',
      4:  'four',
      5:  'five',
      6:  'six',
      7:  'seven',
      8:  'eight',
      9:  'nine',
      10: 'ten',
      11: 'eleven',
      12: 'twelve',
      13: 'thirteen',
      14: 'fourteen',
      15: 'fifteen',
      16: 'sixteen',
      17: 'seventeen',
      18: 'eighteen',
      19: 'nineteen',
      20: 'twenty',
      30: 'thirty',
      40: 'forty',
      50: 'fifty',
      60: 'sixty',
      70: 'seventy',
      80: 'eighty',
      90: 'ninety'
     }"/>

  <xsl:variable name="en-group" as="map(xs:integer, xs:string)" select="map {
      1:  'thousand',
      2:  'million',
      3:  'billion',
      4:  'trillion',
      5:  'quadrillion',
      6:  'quintillion',
      7:  'sextillion',
      8:  'septillion',
      9:  'octillion',
      10: 'nonillion',
      11: 'decillion',
      12: 'undecillion',
      13: 'duodecillion',
      14: 'tredecillion',
      15: 'quattuordecillion',
      16: 'quindecillion',
      17: 'sexdecillion',
      18: 'septendecillion',
      19: 'octodecillion',
      20: 'novemdecillion',
      21: 'vigintillion'
     }"/>

  <xsl:function name="f:en-spell-out" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:sequence select="if ($number &lt; 21)
                    then $en-cardinal($number)
                    else if ($number &lt; 100)
                      then f:en-spell-out-tens($number)
                      else if ($number &lt; 1000)
                        then f:en-spell-out-hundreds($number)
                        else f:en-spell-out-thousands($number)"/>
  </xsl:function>

  <xsl:variable name="en-special-fractions" as="map(xs:string, xs:string)" select="map {
      '1': 'one tenth',
      '2': 'one fifth',
      '4': 'two fifths',
      '5': 'a half',
      '6': 'three fifths',
      '8': 'four fifths',
      '01': 'one hundredth',
      '25': 'one quarter',
      '75': 'three quarters',
      '001': 'one thousandth',
      '125': 'one eigth',
      '375': 'three eigths',
      '625': 'five eigths',
      '875': 'seven eigths',
      '0625': 'one sixteenth',
      '1875': 'three sixteenths',
      '3125': 'five sixteenths',
      '4375': 'seven sixteenths',
      '5625': 'nine sixteenths',
      '6875': 'eleven sixteenths',
      '8125': 'thirteen sixteenths',
      '9375': 'fifteen sixteenths'
    }"/>

  <xsl:function name="f:en-spell-out-decimal" as="xs:string">
    <xsl:param name="decimal" as="xs:decimal"/>

    <xsl:variable name="integer-part" select="xs:integer(substring-before(xs:string($decimal), '.'))" as="xs:integer"/>
    <xsl:variable name="fractional-part" select="substring-after(xs:string($decimal), '.')" as="xs:string"/>

    <!-- remove trailing zeros from the fractional-part -->
    <xsl:variable name="fractional-part" select="replace($fractional-part, '([0-9]+?)0*', '$1')"/>

    <xsl:sequence select="f:en-spell-out($integer-part) ||
      (if ($en-special-fractions($fractional-part)) then ' and ' || $en-special-fractions($fractional-part)
       else if (string-length($fractional-part) = 1) then ' and ' || f:en-spell-out(xs:integer($fractional-part)) || ' tenths'
       else if (string-length($fractional-part) = 2) then ' and ' || f:en-spell-out(xs:integer($fractional-part)) || ' hundredths'
       else if (string-length($fractional-part) = 3) then ' and ' || f:en-spell-out(xs:integer($fractional-part)) || ' thousandths'
       else ' point ' || f:en-spell-out-digits($fractional-part))"/>
  </xsl:function>

  <xsl:function name="f:en-spell-out-digits" as="xs:string">
    <xsl:param name="number" as="xs:string"/>

    <xsl:variable name="result">
      <xsl:for-each select="string-to-codepoints($number)">
        <xsl:value-of select="$en-cardinal(xs:integer(codepoints-to-string(.)))"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="normalize-space($result)"/>
  </xsl:function>

  <xsl:function name="f:en-spell-out-tens" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:variable name="tens" select="10 * floor($number div 10)"/>
    <xsl:variable name="remainder" select="xs:integer(floor($number mod 10))"/>

    <xsl:sequence select="$en-cardinal($tens) || (if ($remainder) then '-' || $en-cardinal($remainder) else '')"/>
  </xsl:function>

  <xsl:function name="f:en-spell-out-hundreds" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:variable name="hundreds" select="xs:integer(floor($number div 100))"/>
    <xsl:variable name="remainder" select="xs:integer(floor($number mod 100))"/>

    <xsl:sequence select="$en-cardinal($hundreds) || ' hundred' || (if ($remainder) then ' ' || f:en-spell-out($remainder) else '')"/>
  </xsl:function>

  <xsl:function name="f:en-spell-out-thousands" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:variable name="group" select="f:log1000($number)" as="xs:integer"/>
    <xsl:variable name="power" select="f:power1000($group)" as="xs:integer"/>
    <xsl:variable name="count" select="xs:integer(floor($number div $power))"/>
    <xsl:variable name="remainder" select="xs:integer(floor($number mod $power))"/>

    <xsl:sequence select="f:en-spell-out($count) || ' ' || $en-group($group) || (if ($remainder) then ' ' || f:en-spell-out($remainder) else '')"/>
  </xsl:function>

  <!-- Dutch -->

  <xsl:variable name="nl-cardinal" as="map(xs:integer, xs:string)" select="map {
      0: 'nul',
      1: 'een',
      2: 'twee',
      3: 'drie',
      4: 'vier',
      5: 'vijf',
      6: 'zes',
      7: 'zeven',
      8: 'acht',
      9: 'negen',
      10: 'tien',
      11: 'elf',
      12: 'twaalf',
      13: 'dertien',
      14: 'veertien',
      15: 'vijftien',
      16: 'zestien',
      17: 'zeventien',
      18: 'achttien',
      19: 'negentien',
      20: 'twintig',
      30: 'dertig',
      40: 'veertig',
      50: 'vijftig',
      60: 'zestig',
      70: 'zeventig',
      80: 'tachtig',
      90: 'negentig'
     }"/>

  <xsl:variable name="nl-group" as="map(xs:integer, xs:string)" select="map {
     1: 'duizend',
     2: 'miljoen',
     3: 'miljard',
     4: 'biljoen',
     5: 'biljard',
     6: 'triljoen',
     7: 'triljard',
     8: 'quadriljoen',
     9: 'quadriljard',
     10: 'quintiljoen',
     11: 'quintiljard',
     12: 'sextiljoen',
     13: 'sextiljard',
     14: 'septiljoen',
     15: 'septiljard',
     16: 'octiljoen',
     17: 'octiljard',
     18: 'noniljoen',
     19: 'noniljard',
     20: 'deciljoen',
     21: 'deciljard'
    }"/>

  <xsl:function name="f:nl-spell-out" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:value-of select="if ($number = 1) then 'één'
                  else if ($number &lt; 21)
                    then $nl-cardinal($number)
                    else if ($number &lt; 100)
                      then f:nl-spell-out-tens($number)
                      else if ($number &lt; 1000)
                        then f:nl-spell-out-hundreds($number)
                        else f:nl-spell-out-thousands($number)"/>
  </xsl:function>

  <xsl:variable name="nl-special-fractions" as="map(xs:string, xs:string)" select="map {
      '1': 'één tiende',
      '2': 'één vijfde',
      '4': 'twee vijfde',
      '5': 'een half',
      '6': 'drie vijfde',
      '8': 'vier vijfde',
      '01': 'één honderste',
      '25': 'een kwart',
      '75': 'drie kwart',
      '001': 'één duizendste',
      '125': 'één achtste',
      '375': 'drie achtste',
      '625': 'vijf achtste',
      '875': 'zeven achtste',
      '0625': 'één zestiende',
      '1875': 'drie zestiende',
      '3125': 'vijf zestiende',
      '4375': 'zeven zestiende',
      '5625': 'negen zestiende',
      '6875': 'elf zestiende',
      '8125': 'dertien zestiende',
      '9375': 'vijftien zestiende'
    }"/>

  <xsl:function name="f:nl-spell-out-decimal" as="xs:string">
    <xsl:param name="decimal" as="xs:decimal"/>

    <xsl:variable name="integer-part" select="xs:integer(substring-before(xs:string($decimal), '.'))" as="xs:integer"/>
    <xsl:variable name="fractional-part" select="substring-after(xs:string($decimal), '.')" as="xs:string"/>

    <!-- remove trailing zeros from the fractional-part -->
    <xsl:variable name="fractional-part" select="replace($fractional-part, '([0-9]+?)0*', '$1')"/>

    <xsl:sequence select="f:nl-spell-out($integer-part) ||
      (if ($nl-special-fractions($fractional-part)) then ' en ' || $nl-special-fractions($fractional-part)
       else if (string-length($fractional-part) = 1) then ' en ' || f:nl-spell-out(xs:integer($fractional-part)) || ' tienden'
       else if (string-length($fractional-part) = 2) then ' en ' || f:nl-spell-out(xs:integer($fractional-part)) || ' hondersten'
       else if (string-length($fractional-part) = 3) then ' en ' || f:nl-spell-out(xs:integer($fractional-part)) || ' duizendsten'
       else ' komma ' || f:nl-spell-out-digits($fractional-part))"/>
  </xsl:function>

  <xsl:function name="f:nl-spell-out-digits" as="xs:string">
    <xsl:param name="number" as="xs:string"/>

    <xsl:variable name="result">
      <xsl:for-each select="string-to-codepoints($number)">
        <xsl:value-of select="$nl-cardinal(xs:integer(codepoints-to-string(.)))"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="normalize-space($result)"/>
  </xsl:function>

  <xsl:function name="f:nl-spell-out-tens" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:variable name="tens" select="10 * floor($number div 10)"/>
    <xsl:variable name="remainder" select="xs:integer(floor($number mod 10))"/>

    <xsl:value-of select="(if ($remainder) then $nl-cardinal($remainder) else '') || (if ($remainder = (2, 3)) then 'ën' else 'en') || $nl-cardinal($tens)"/>
  </xsl:function>

  <xsl:function name="f:nl-spell-out-hundreds" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:variable name="hundreds" select="xs:integer(floor($number div 100))"/>
    <xsl:variable name="remainder" select="xs:integer(floor($number mod 100))"/>

    <xsl:value-of select="(if ($hundreds > 1) then $nl-cardinal($hundreds) else '') || 'honderd' || (if ($remainder) then f:nl-spell-out($remainder) else '')"/>
  </xsl:function>

  <xsl:function name="f:nl-spell-out-thousands" as="xs:string">
    <xsl:param name="number" as="xs:decimal"/>
    <xsl:variable name="group" select="xs:integer(ceiling(string-length(xs:string($number)) div 3)) - 1"/>
    <xsl:variable name="power" select="f:power1000($group)"/>
    <xsl:variable name="count" select="xs:integer(floor($number div $power))"/>
    <xsl:variable name="remainder" select="xs:integer(floor($number mod $power))"/>

    <xsl:value-of select="
        (if ($group > 1 or $count > 1) then f:nl-spell-out($count) else '')
        || (if ($group = 1) then '' else ' ')
        || $nl-group($group)
        || (if ($remainder) then ' ' || f:nl-spell-out($remainder) else '')"/>
  </xsl:function>

</xsl:stylesheet>
