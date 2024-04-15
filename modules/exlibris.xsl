<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ex="http://www.gutenberg.ph/2024/schemas/exlibris"
                exclude-result-prefixes="f xd xs" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.pnp-software.com/XSLTdoc ../schemas/xsltdoc.xsd">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to create an ex-libris</xd:short>
        <xd:detail>This stylesheet creates an ex-libris page in a document, based on information provided in the
            file <code>exlibris.xml</code>.
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2021, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc type="string">Name of ex-libris file.</xd:doc>
    <xsl:param name="ex-libris-file"/>

    <xd:doc type="string">Custom configuration (if available read from file else empty).</xd:doc>
    <xsl:variable name="ex-libris" select="if ($ex-libris-file)
                                           then document(f:normalize-filename($ex-libris-file), /)
                                           else $empty-ex-libris"/>

    <xsl:variable name="empty-ex-libris">
        <ex:exlibris/>
    </xsl:variable>

    <xsl:variable name="default-ex-libris">
        <exlibris xmlns="http://www.gutenberg.ph/2024/schemas/exlibris">
            <owner>
                <name>Jeroen Hellingman</name>
                <contact type="email">jeroen@gutenberg.ph</contact>
                <address>
                    <houseNumber>24</houseNumber>
                    <street>Some Street</street>
                    <town>Some Town</town>
                    <postalCode>12345</postalCode>
                    <province>Some Province</province>
                    <country>Some Country</country>
                </address>
                <location olc="849VCWC8+R9">
                    <latitude>52.0000</latitude>
                    <longitude>4.00000</longitude>
                </location>
            </owner>
            <accession>
                <date>2021-10-24</date>
                <payment>
                    <price>
                        <currency>EUR</currency>
                        <amount>12.95</amount>
                    </price>
                    <method type="cc">
                        <cc>378282246310005</cc>
                    </method>
                </payment>
            </accession>
        </exlibris>
    </xsl:variable>


    <xsl:template match="divGen[@type='exlibris']">
        <div class="exlibris">
            <p>This book belongs to: <xsl:value-of select="$ex-libris/owner/name"/>.</p>
        </div>
    </xsl:template>

</xsl:stylesheet>