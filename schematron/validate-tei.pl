#!/usr/bin/perl
use strict;
use warnings;

# Define file paths (update as needed)
my $schxslt         = "../tools/lib/schxslt-cli.jar";    # Schematron processor, see https://github.com/schxslt/schxslt
my $saxon           = "../tools/lib/saxon9he.jar";       # Saxon XSLT processor
my $schematron_file = "tei-validation.sch";              # Schematron rules
my $xslt_file       = "validation-report.xsl";           # XSLT for HTML output

my $report_file     = "validation-report.xml";  # XML output
my $html_report     = "validation-report.html"; # Final HTML report

my $xml_file        = shift or die "Usage: perl validate-tei.pl input.xml\n";


die "Error: SchXslt JAR not found!\n" unless -e $schxslt;
die "Error: Saxon JAR not found!\n" unless -e $saxon;
die "Error: Schematron file not found!\n" unless -e $schematron_file;
die "Error: XSLT file not found!\n" unless -e $xslt_file;
die "Error: XML file '$xml_file' not found!\n" unless -e $xml_file;


# Run Schematron validation
print "🔍 Validating $xml_file...\n";
my $validate_cmd = "java -jar $schxslt -s $schematron_file -d $xml_file -o $report_file";
my $validate_result = system($validate_cmd);

# Check validation success
if ($validate_result == 0) {
    print "✅ Validation complete. Report saved to $report_file.\n";
} else {
    die "❌ Validation failed! Check for errors.\n";
}

# Convert XML report to HTML
print "🎨 Converting validation report to HTML...\n";
my $transform_cmd = "java -jar $saxon -s:$report_file -xsl:$xslt_file -o:$html_report";
my $transform_result = system($transform_cmd);

# Check transformation success
if ($transform_result == 0) {
    print "✅ HTML report generated: $html_report\n";
} else {
    die "❌ Failed to generate HTML report!\n";
}

exit 0;
