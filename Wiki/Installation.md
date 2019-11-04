# Required Downloads #

The `tei2html` code has a range of dependencies on third-party software. This page lists those.

## Saxon ##

An XSLT 3.0 processor is required for `tei2html`, any XSLT 3.0 processor should work, however, I've developed these stylesheets with Saxon (using the freely available version Saxon HE).

You should download a reasonable recent version of Saxon. For example the Saxon SA product from [saxonica.com](http://www.saxonica.com/products.html).

The perl scripts assume that `saxon9he.jar` is placed in the `tools/lib/` subdirectory.

## Java ##

Saxon requires Java.

Make sure that the java executables can be found on the path.

If you do not have Java, you can download it from http://java.com/en/

## Perl ##

If you are using the provided Perl scripts to glue things together,
you'll need a Perl interpreter, and it will have to work together with the PerlMagick extension. To make
this work, you'll need to install matching versions of both.

### Perl 5.20 ###

My advise is to download [Strawberry Perl](http://strawberryperl.com/). For Windows, use either the 32 or 64 bits version, to match your system.

After installing Perl, install [ImageMagick](http://www.imagemagick.org/script/index.php), again, matching the 32 or 64 bits version of
your system. When installing, make sure to also tick the option to install the C headers.

Then, run `cpan force install Image::Magick` to get the required packages in Perl.

Some errors might be shown during this process, but in my configuration it still worked.


### Packages used ###

TODO.

## SX, NSGML ##

_Optional, only needed you want to use SGML as source format._

SX is an SGML to XML translator, and NSGML is an SGML validator, part of the SP package. Since XSLT only supports XML, you will need both those two tools to be able to work with SGML. They can be downloaded from [James Clark website](http://www.jclark.com/). For windows, get [sp 1.3.4](ftp://ftp.jclark.com/pub/sp/win32/sp1_3_4.zip).

To enable SX and NSGML to understand your document types, you need to configure a catalog of DTDs (Which maps public DTDs to local resources containing their definitions). The scripts assume this is located in a file named `tools/pubtext/CATALOG`.

You will need to add the `teilite.dtd` to the CATALOG. This DTD can be found here: http://www.tei-c.org/Vault/P4/Lite/DTD/

A short explanation of Catalog files can be found in the SP documentation on James Clark's website referenced above.

## ZIP ##

To compress ePub files, you will need a zip utility. `tei2html` uses [info-zip](http://www.info-zip.org/Zip.html) to handle the peculiar requirements of the ePub format. (See e.g. [this blog entry on creating ePub files](http://www.snee.com/bobdc.blog/2008/03/creating-epub-files.html).)

## Node.js ##

_Optional, only needed when you use mathematical formulas in TeX notation._

To convert mathematical formulas in TeX format to a format that can be included in static HTML pages, you will need to install the following:

  * Node.js (see the [node.js website](https://nodejs.org/en/)).
  * mathjax-node-cli ([source at GitHub](https://github.com/mathjax/mathjax-node-cli), most conveniently installed by using `npm` after installing Node.js.

## Patc ##

_Optional, only needed when you use the transcription schemes I use in SGML._

Patc (pattern changer) is a small utility written in C to do multiple find-and-replace actions at once. You will need a C compiler to get it to work. It enables you to execute multiple find-replace actions in an efficient way. Mostly used to change the transliteration of non-Roman scripts I've used. If you don't use that, you'll not need it. (I've successfully compiled this on a variety of platforms, including Unix, and Windows; a solution file for Visual Studio 7.0 is included; contact me if you need a Windows binary.)

## epubcheck ##

_Optional, only needed if you want to check generated ePubs._

Epubcheck is a tool to validate epub books, it can be obtained from: https://github.com/IDPF/epubcheck

This tool also requires Java; the scripts assume you use `epubcheck-3.0.1.jar`, placed in the tools/lib subdirectory.
