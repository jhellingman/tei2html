<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to handle configuration.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to handle configurations.</xd:short>
        <xd:detail>This stylesheet is used to handle configurable options in the tei2html stylesheets.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc type="string">Name of custom configuration file.</xd:doc>
    <xsl:param name="configurationFile"/>

    <xd:doc>
        <xd:short>The default configuration.</xd:short>
        <xd:detail>
            <p>The contents of this variable follow the structure for configuration files that
            can be used with documents.</p>
        </xd:detail>
    </xd:doc>

    <xsl:variable name="default-configuration">
        <tei2html.config>
            <defaultStylesheet>style/arctic.css</defaultStylesheet>     <!-- Stylesheet to include. -->
            <inlineStylesheet>true</inlineStylesheet>                   <!-- use an inline (embedded in HTML) stylesheet; ignored for ePub. -->
            <numberTocEntries>true</numberTocEntries>                   <!-- Provide numbers with TOC entries. -->
            <showParagraphNumbers>false</showParagraphNumbers>          <!-- Output paragraph numbers, using the value of the @n attribute. -->
            <includePGHeaders>false</includePGHeaders>                  <!-- Include Project Gutenberg headers and footers. -->
            <includeImages>true</includeImages>                         <!-- Include images in the generated output. -->
            <defaultTocEntries>false</defaultTocEntries>                <!-- Use generic heads in entries in the TOC, if no head is present -->
            <useDittoMarks>true</useDittoMarks>                         <!-- Use ditto marks where items are marked with the DITTO tag. -->
            <dittoMark>,,</dittoMark>                                   <!-- The symbol to use as a ditto mark. -->
            <generateFacsimile>false</generateFacsimile>                <!-- Output section with and links to facsimile images if required information is present. -->
            <facsimilePath>page-images</facsimilePath>                  <!-- Path where page images for a facsimile edition is present. -->
            <useRegularizedUnits>false</useRegularizedUnits>            <!-- Use the regularized units specified in the measure-tag. (false: both are shown, the original in the text, the regularized units in a 
                                                                             pop-up; true: regularized in text, original in pop-up) -->
            <outputExternalLinks>always</outputExternalLinks>           <!-- Generate external links, possible values: always | never | colophon -->
            <outputExternalLinksTable>false</outputExternalLinksTable>  <!-- Place external links in a separate table in the colophon. -->
            <useHangingPunctuation>false</useHangingPunctuation>        <!-- Use hanging punctuation (by generating the relevant CSS classes). -->

            <!-- Output format specific settings: these override the general settings defined above for a specific output format. Supported formats: "html" and "epub". -->
            <output format="html">
                <useMouseOverPopups>true</useMouseOverPopups>           <!-- Use mouse-over pop-ups on various items (links, etc) -->
            </output>
            <output format="epub">
                <useMouseOverPopups>false</useMouseOverPopups>
                <outputExternalLinks>always</outputExternalLinks>
                <outputExternalLinksTable>true</outputExternalLinksTable>
            </output>
        </tei2html.config>
    </xsl:variable>


    <xd:doc>
        <xd:short>Load the file-specific configuration from the place where the file resides.</xd:short>
    </xd:doc>

    <xsl:variable name="configuration" select="if ($configurationFile) then document($configurationFile, /) else $default-configuration"/>


    <xd:doc>
        <xd:short>Get a value from the configuration.</xd:short>
        <xd:detail>
            <p>Get a value from the configuration. First try to get it from a local file as specified in the variable <code>$configurationFile</code> (default: <code>tei2html.config</code>), and if that fails, obtain
            the value from the default configuration included in this stylesheet. If that too fails, a message is logged to the console.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:getSetting" as="xs:string">
        <xsl:param name="name" as="xs:string"/>

        <!-- Get the value from the current configuration -->
        <xsl:variable name="value" select="$configuration/tei2html.config/output[@format=$outputformat]/*[name()=$name]"/>
        <xsl:variable name="value" select="if ($value) then $value else $configuration/tei2html.config/*[name()=$name]"/>

        <!-- If not found: get the value from the default configuration -->
        <xsl:variable name="value" select="if ($value) then $value else $default-configuration/tei2html.config/output[@format=$outputformat]/*[name()=$name]"/>
        <xsl:variable name="value" select="if ($value) then $value else $default-configuration/tei2html.config/*[name()=$name]"/>

        <xsl:if test="not($value)">
            <xsl:message terminate="no">ERROR:   Cannot get configuration value: <xsl:value-of select="$name"/>.</xsl:message>
        </xsl:if>

        <xsl:sequence select="$value"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Get a boolean value from the configuration.</xd:short>
    </xd:doc>

    <xsl:function name="f:isSet" as="xs:boolean">
        <xsl:param name="name" as="xs:string"/>

        <xsl:variable name="value" select="f:getSetting($name)"/>
        <xsl:sequence select="if ($value = 'true') then true() else false()"/>
    </xsl:function>

</xsl:stylesheet>
