
# Installation instructions for Mac

Install the latest Perl version, cpanminus and the open-sp SGML processing tools:

```bash
brew install perl
brew install cpanminus
brew install open-sp
```

Make sure you have at least Perl 3.36.

```bash
perl -v
```

Load required packages

```bash
cpanm DateTime
cpanm Math::Round
cpanm XML::XPath
cpanm HTML::Entities
cpanm Roman
```

Find your local Perl library:

```bash
perl -V:'installsitelib'
```

Copy the following files to your local Perl library:

```bash
PERL_INSTALL_SITE_LIB=$(perl -MConfig -e 'print $Config{installsitelib}')
cp tools/SgmlSupport.pm $PERL_INSTALL_SITE_LIB
cp tools/LanguageNames.pm $PERL_INSTALL_SITE_LIB
cp pptools/PgdpSupport.pm $PERL_INSTALL_SITE_LIB
```

Add the following to your `.bashrc` or `.env_vars` file:

```bash
export TEI2HTML_HOME=/Users/jhellingman/sandboxes/tei2html
export SAXON_HOME=/opt/homebrew/bin/saxon
export PATH=$TEI2HTML_HOME/tools:$TEI2HTML_HOME/pptools:$PATH
```

Compile the `patc` processor and place it in your bin (or in `pptools`, to avoid a name-clash with its own folder)

```bash
cd $TEI2HTML_HOME/tools/patc/src
make
chmod +x patc
cp patc ../../../pptools/
```


# Mostly optional utilities

Zopflipng, either:

```bash
brew install zopfli
```

or:

```bash
git clone https://github.com/google/zopfli.git
cd zopfli
make zopflipng
```

qrencode

```bash
brew install qrencode
```
