# SKILL: pptools (Perl helpers) runbook

Purpose: quick notes and prerequisites for the Perl scripts under pptools/.

What these scripts do
- Prepare and post-process TEI and media from Project Gutenberg / Distributed Proofreaders.
- Examples: prepare-images.pl, tagSegments.pl, tagPoetry.pl, to7zip.pl, optimg.pl, pgreport.pl, pgpreview.pl, and many small utilities.

Prerequisites & environment
- Perl (system Perl or perlbrew) — scripts are standard Perl, but may use CPAN modules; check the script headers for `use` lines.
- External binaries (often required by scripts):
  - ImageMagick (convert/identify) for image operations
  - 7zip or equivalent for compression tasks
  - Standard Unix tools (tar, zip, sed, awk) depending on the script
- Correct file encodings and filenames (some scripts assume UTF-8 or ASCII filenames)

Running & debugging
- Run scripts with `perl scriptname.pl` and add -v or -d prints if needed.
- If a script fails, search the top of the file for comments that indicate expected input directories or file naming conventions.
- Many scripts expect to be run in a specific repository layout (samples/, images/). Re-run transforms on a small sample to reproduce issues.

Risk & maintenance
- Scripts may be brittle across platforms — document required external tools and versions.
- Consider adding a small README or usage header to the most-used scripts listing dependencies and example invocations.