# Introduction #

Besides the main XSLT scripts, `tei2html` includes a number of Perl scripts to accomplish various tasks. Many of these are quick hacks to get things done.

## `tei2html.pl` ##

The main 'glue' script. This will run the various commands to actually run the `tei2html` XSLT scripts.

Syntax: `perl.pl -S tei2html.pl [options] filename`

| **Option** | **Action** |
|:-----------|:-----------|
| `-x` | Convert SGML file to XML |
| `-h` | Generate HTML |
| `-e` | Generate ePub |
| `-t` | Generate plain vanilla ASCII (_needs manual cleanup!_) |
| `-p` | Generate PDF (_using Prince XML_) |
| `-r` | Generate word-usage report |
| `-c` filename | Include additional CSS file |

Default options `-xhtr`.

## `ucwords.pl` ##

Perl script to list word-frequencies in an XML file. This script will recognize the `@lang` tag, and write a word-frequency list per language encountered. Words in the output will be color-coded, based on frequency and appearance in a spell-check dictionary.

Syntax: `perl -S ucwords.pl filename`

## `fixpb.pl` ##

Perl script to fix page numbers, as recorded in the `@n` attribute in `<pb>` elements. This will also set the `@id` attribute to `pb#`, where # is the current page number.

Syntax:

`perl -S fixpb.pl filename start offset`

_filename_: the file of which the page numbers need to be updated

_start_: the first page number that needs to be updated.

_offset_: the offset to be applied to pages after _start_; can be a positive or negative integer.

## `catpars.pl` ##

Perl script to unwrap paragraphs, such that they appear on one line. Handle with care!

## `quotes.pl` ##

Perl script to replace ASCII double-quotes with curly quotes. May need some manual verification and correction where quotes and tags interfere with the simple algorithm used.

Issues:

  * Open quotes before SGML tags and non-letters go wrong.
  * Can only handle double quotes (single quotes are much harder to automate as they need to be disambiguated from apostrophes, but see below.)
  * 

## `aposquote.pl` ##

Perl script to replace ASCII single quotes with curly quotes or apostrophes. Will not handle all cases, and will need manual verification and corrections.

## `pgpp.pl` ##

Initials script run on the output from PG Distributed Proofreaders, when converting that to TEI (A manual process, the resulting output is still very far removed from being an actual TEI file).