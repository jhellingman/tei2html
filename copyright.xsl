<!DOCTYPE xsl:stylesheet [

    <!ENTITY ndash      "&#x2013;">

]>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd">


    <xd:doc type="stylesheet">
        <xd:short>Functions to determine copyright status</xd:short>
        <xd:detail>This stylesheet contains a number of functions to determine copyright status of a TEI file, based on data in the header.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:function name="f:inCopyright" as="xs:boolean">
        <xsl:param name="jurisdiction" as="xs:string"/>
        <xsl:param name="teiHeader" as="element(teiHeader)"/>

        <xsl:variable name="termInYears" select="f:copyrightTermInYears($jurisdiction)"/>

        <xsl:value-of select="f:lastContributorDeath($teiHeader) > year-from-date(current-date()) - ($termInYears + 1)"/>
    </xsl:function>


    <xsl:function name="f:copyrightTermInYears" as="xs:integer">
        <xsl:param name="jurisdiction" as="xs:string"/>

        <xsl:value-of select="if ($jurisdiction = 'Bern') then 50
                              else if ($jurisdiction = ('VE', 'IN')) then 60
                              else if ($jurisdiction = ('EEA', 'EU', 'US', 'AU', 'BR', 'BF', 'CL', 'CR', 'GE', 'IL', 'XK', 'MK', 'RU', 'LK', 'CH', 'TR')) then 70
                              else if ($jurisdiction = 'HN') then 75
                              else if ($jurisdiction = 'CO') then 80
                              else if ($jurisdiction = 'JM') then 95
                              else if ($jurisdiction = 'MX') then 100
                              else 100"/>
    </xsl:function>


    <xsl:function name="f:lastContributorDeath">
        <xsl:param name="teiHeader" as="element(teiHeader)"/>

        <xsl:variable name="contributors">
            <contributors>
                <xsl:for-each select="$teiHeader/fileDesc/titleStmt/author">
                    <xsl:copy-of select="f:parseNameWithDates(.)"/>
                </xsl:for-each>
                <xsl:for-each select="$teiHeader/fileDesc/titleStmt/editor">
                    <xsl:copy-of select="f:parseNameWithDates(.)"/>
                </xsl:for-each>
                <xsl:for-each select="$teiHeader/fileDesc/titleStmt/respStmt/name">
                    <xsl:copy-of select="f:parseNameWithDates(.)"/>
                </xsl:for-each>
            </contributors>
        </xsl:variable>

        <!-- <xsl:message>LAST DEATH <xsl:value-of select="if ($contributors//death[matches(., '[0-9]+')]) then max($contributors//death[matches(., '[0-9]+')]) else 0"/></xsl:message> -->

        <xsl:value-of select="if ($contributors//death[matches(., '[0-9]+')]) then max($contributors//death[matches(., '[0-9]+')]) else 0"/>
    </xsl:function>


    <xsl:function name="f:parseNameWithDates">
        <xsl:param name="name" as="xs:string"/>

        <!-- <xsl:message>ANALYZING: <xsl:value-of select="$name"/></xsl:message> -->
        <xsl:choose>
            <xsl:when test="matches($name, '^(.+)[,]? [(]?([0-9]+)[&ndash;-]([0-9]+)[)]?\]?$')">
                <xsl:analyze-string select="$name" regex="^(.+)[,]? [(]?([0-9]+)[&ndash;-]([0-9]+)[)]?\]?$">
                    <xsl:matching-substring>
                        <contributor>
                            <!--
                            <xsl:message>FOUND NAME: <xsl:value-of select="regex-group(1)"/></xsl:message>
                            <xsl:message>FOUND BIRTH: <xsl:value-of select="regex-group(2)"/></xsl:message>
                            <xsl:message>FOUND DEATH: <xsl:value-of select="regex-group(3)"/></xsl:message>
                            -->
                            <name><xsl:value-of select="regex-group(1)"/></name>
                            <birth><xsl:value-of select="regex-group(2)"/></birth>
                            <death><xsl:value-of select="regex-group(3)"/></death>
                        </contributor>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($name, '^(.+)[,]? [(]?[&ndash;-]([0-9]+)[)]?\]?$')">
                <xsl:analyze-string select="$name" regex="^(.+)[,]? [(]?[&ndash;-]([0-9]+)[)]?\]?$">
                    <xsl:matching-substring>
                        <contributor>
                            <name><xsl:value-of select="regex-group(1)"/></name>
                            <death><xsl:value-of select="regex-group(2)"/></death>
                        </contributor>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($name, '^(.+)[,]? [(]?([0-9]+)[&ndash;-][)]?\]?$')">
                <xsl:analyze-string select="$name" regex="^(.+)[,]? [(]?([0-9]+)[&ndash;-][)]?\]?$">
                    <xsl:matching-substring>
                        <contributor>
                            <name><xsl:value-of select="regex-group(1)"/></name>
                            <birth><xsl:value-of select="regex-group(2)"/></birth>
                        </contributor>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <contributor>
                    <name><xsl:value-of select="$name"/></name>
                </contributor>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
