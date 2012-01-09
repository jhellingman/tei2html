
my $saxon = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

$filename = $ARGV[0];
my $page = $ARGV[1];

if ($page eq '')
{
    system ("$saxon \"$filename\" extract-page.xsl");
}
else
{
    system ("$saxon \"$filename\" extract-page.xsl n=\"$page\"");
}
