
# Installation instructions for macOS

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
cpanm Image::Size
cpanm File::chdir
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

For compressing .png images, install `Zopflipng`, either:

```bash
brew install zopfli
```

or:

```bash
git clone https://github.com/google/zopfli.git
cd zopfli
make zopflipng
```

For creating QR codes, use `qrencode`

```bash
brew install qrencode
```

For handling embedded mathematical formulas in TeX format, use `MathJax`, this can be installed using pnpm:

```bash
pnpm add -g mathjax
pnpm add -g mathjax-node-cli
```

Note: On Windows, the version of mathjax-node-cli installed doesn't work. A fix has been proposed, but not
applied. To obtain it, check out the fixed code from https://github.com/cabo/mathjax-node-cli/tree/master, and 
manually copy it over the version in your pnpm store.

This should be possible with:

```bash
pnpm add -g github:cabo/mathjax-node-cli
```

