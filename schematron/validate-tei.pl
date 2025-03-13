#!/usr/bin/perl
use strict;
use warnings;

# Define file paths (update as needed)
my $schxslt_jar    = "schxslt-cli-1.7.4.jar";  # SchXslt CLI
my $saxon_jar      = "saxon-he-10.6.jar";      # Saxon XSLT processor
my $schematron_file = "tei-validation.sch";    # Your Schematron rules
my $xslt_file      = "schematron-report.xsl";  # XSLT for HTML output
my $xml_file       = shift or die "Usage: perl validate-tei.pl input.xml\n";
my $report_file    = "validation-report.xml";  # XML output
my $html_report    = "validation-report.html"; # Final HTML report

# Check if required files exist
die "Error: SchXslt JAR not found!\n" unless -e $schxslt_jar;
die "Error: Saxon JAR not found!\n" unless -e $saxon_jar;
die "Error: Schematron file not found!\n" unless -e $schematron_file;
die "Error: XSLT file not found!\n" unless -e $xslt_file;
die "Error: XML file '$xml_file' not found!\n" unless -e $xml_file;

# See: https://github.com/schxslt/schxslt

# Run Schematron validation
print "🔍 Validating $xml_file...\n";
my $validate_cmd = "java -jar $schxslt_jar validate -s $schematron_file -d $xml_file -o $report_file";
my $validate_result = system($validate_cmd);

# Check validation success
if ($validate_result == 0) {
    print "✅ Validation complete. Report saved to $report_file.\n";
} else {
    die "❌ Validation failed! Check for errors.\n";
}

# Convert XML report to HTML
print "🎨 Converting validation report to HTML...\n";
my $transform_cmd = "java -jar $saxon_jar -s:$report_file -xsl:$xslt_file -o:$html_report";
my $transform_result = system($transform_cmd);

# Check transformation success
if ($transform_result == 0) {
    print "✅ HTML report generated: $html_report\n";
} else {
    die "❌ Failed to generate HTML report!\n";
}

exit 0;
