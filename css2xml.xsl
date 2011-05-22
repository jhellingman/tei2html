<?xml version="1.0" encoding="utf-8"?>

<!-- An experimental stylesheet to parse (a limited subset of) CSS, and to render it again in a more compact form -->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


    <xsl:template match="style">
        <xsl:call-template name="css2xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="css2xml">
        <xsl:param name="text"/>

        <xsl:variable name="tokens">
            <xsl:call-template name="tokenize">
                <xsl:with-param name="text" select="$text"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="tokens">
            <xsl:apply-templates mode="atkeyword" select="$tokens"/>
        </xsl:variable>

        <xsl:variable name="blocks">
            <xsl:apply-templates mode="blocks" select="$tokens/*[1]"/>
        </xsl:variable>

        <xsl:variable name="rules">
            <xsl:apply-templates mode="rules" select="$blocks"/>
        </xsl:variable>

        <xsl:variable name="properties">
            <xsl:apply-templates mode="properties" select="$rules"/>
        </xsl:variable>

        <xsl:variable name="keyvalue">
            <xsl:apply-templates mode="keyvalue" select="$properties"/>
        </xsl:variable>

        <xsl:variable name="selector">
            <xsl:apply-templates mode="selector" select="$keyvalue"/>
        </xsl:variable>

        <xsl:variable name="cleanup">
            <xsl:apply-templates mode="cleanup" select="$selector"/>
        </xsl:variable>

        <xsl:variable name="unparse">
            <xsl:apply-templates mode="unparse" select="$cleanup"/>
        </xsl:variable>

        <stylesheet>
            <xsl:copy-of select="$cleanup"/>

            <xsl:copy-of select="$unparse"/>
        </stylesheet>
    </xsl:template>

    <!--
        Use analyze-string to split the string into lexical items.

        1. comment:     /\*(.*?)\*/
        2. string:      ('|&quot;)(.*?)\1
        3. number:      (-?\d+(\.\d+)?)
        4. ident:       ([\w-]+)
        5. symbol:      ([:;,.#%@\{\}\[\]])
        6. space:       (\s+)

    -->
    <xsl:template name="tokenize">
        <xsl:param name="text"/>

        <xsl:variable name="patterns"
            select="'/\*(.*?)\*/','((''|&quot;).*?\3)','(-?\d+(\.\d+)?)','([\w-]+)','([:;,.#@\{\}\[\]])','(\s+)'"/>

        <xsl:analyze-string select="$text" regex="{string-join($patterns,'|')}" flags="s">
            <xsl:matching-substring>
                <xsl:choose>
                    <!-- comment -->
                    <xsl:when test="regex-group(1)">
                        <xsl:comment>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:comment>
                    </xsl:when>
                    <!-- string -->
                    <xsl:when test="regex-group(2)">
                        <string>
                            <xsl:value-of select="regex-group(2)"/>
                        </string>
                    </xsl:when>
                    <!-- number -->
                    <xsl:when test="regex-group(4)">
                        <number>
                            <xsl:value-of select="regex-group(4)"/>
                        </number>
                    </xsl:when>
                    <!-- ident -->
                    <xsl:when test="regex-group(6)">
                        <ident>
                            <xsl:value-of select="regex-group(6)"/>
                        </ident>
                    </xsl:when>
                    <!-- symbol -->
                    <xsl:when test="regex-group(7)">
                        <symbol>
                            <xsl:value-of select="regex-group(7)"/>
                        </symbol>
                    </xsl:when>
                    <!-- space -->
                    <xsl:when test="regex-group(8)">
                        <space>
                            <xsl:value-of select="regex-group(8)"/>
                        </space>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="'internal error'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:if test="normalize-space() != ''">
                    <xsl:message select="concat('unknown token: ', .)"/>
                </xsl:if>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <!-- atkeyword -->

    <xsl:template mode="atkeyword" match="@*|node()" priority="-9">
        <xsl:copy>
            <xsl:apply-templates mode="atkeyword" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="atkeyword" match="symbol[.='#'][following-sibling::*[1]/self::ident]">
        <hash>
            <xsl:text>#</xsl:text>
            <xsl:value-of select="following-sibling::*[1]"/>
        </hash>
    </xsl:template>

    <xsl:template mode="atkeyword" match="ident[preceding-sibling::*[1]/self::symbol[.='#']]"/>

    <xsl:template mode="atkeyword" match="symbol[.='@'][following-sibling::*[1]/self::ident]">
        <atkeyword>
            <xsl:text>@</xsl:text>
            <xsl:value-of select="following-sibling::*[1]"/>
        </atkeyword>
    </xsl:template>

    <xsl:template mode="atkeyword" match="ident[preceding-sibling::*[1]/self::symbol[.='@']]"/>


    <!-- use sibling recursion to group things between braces -->

    <xsl:template mode="blocks" match="node()" priority="-9">
        <xsl:copy-of select="."/>
        <xsl:apply-templates mode="blocks" select="following-sibling::*[1]"/>
    </xsl:template>

    <xsl:template mode="blocks" match="symbol[.='}']"/>

    <xsl:template mode="blocks" match="symbol[.='{']">
        <block>
            <xsl:apply-templates mode="blocks" select="following-sibling::*[1]"/>
        </block>
        <xsl:variable name="level" select="count(preceding-sibling::symbol[.='{']) - count(preceding-sibling::symbol[.='}']) + 1"/>
        <xsl:variable name="closer"
            select="following-sibling::symbol[.='}' and (count(preceding-sibling::symbol[.='{']) - count(preceding-sibling::symbol[.='}'])) = $level][1]"/>
        <xsl:apply-templates mode="blocks" select="$closer/following-sibling::*[1]"/>
    </xsl:template>


    <!-- group rules -->

    <xsl:template mode="rules" match="@*|node()" priority="-9">
        <xsl:copy>
            <xsl:apply-templates mode="rules" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="rules" match="/">
            <xsl:for-each-group select="*" group-ending-with="block">
                <rule>
                    <xsl:apply-templates mode="rules" select="current-group()"/>
                </rule>
            </xsl:for-each-group>
    </xsl:template>


    <!-- group properties -->

    <xsl:template mode="properties" match="@*|node()" priority="-9">
        <xsl:copy>
            <xsl:apply-templates mode="properties" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="properties" match="block">
        <block>
            <xsl:for-each-group select="*" group-ending-with="symbol[.=';']">
                <property>
                    <xsl:apply-templates mode="properties" select="current-group()"/>
                </property>
            </xsl:for-each-group>
        </block>
    </xsl:template>

    <!-- eliminate empty rules -->
    <xsl:template mode="properties" match="rule[normalize-space(.) = '']"/>


    <!-- key-value properties -->

    <xsl:template mode="keyvalue" match="@*|node()" priority="-9">
        <xsl:copy>
            <xsl:apply-templates mode="keyvalue" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="keyvalue" match="property">
        <xsl:apply-templates mode="keyvalue2" select="symbol[.=':']"/>
    </xsl:template>

    <xsl:template mode="keyvalue2" match="symbol[.=':']">
        <property>
            <key>
                <xsl:apply-templates mode="keyvalue" select="preceding-sibling::*"/>
            </key>
            <value>
                <xsl:apply-templates mode="keyvalue" select="following-sibling::*"/>
            </value>
        </property>
    </xsl:template>

    <xsl:template mode="keyvalue" match="symbol[.=';']"/>
    <xsl:template mode="keyvalue" match="space[position() = 1]"/>


    <!-- selector properties -->

    <xsl:template mode="selector" match="@*|node()" priority="-9">
        <xsl:copy>
            <xsl:apply-templates mode="selector" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="selector" match="*[following-sibling::block]"/>

    <xsl:template mode="selector" match="block">
        <selector>
            <xsl:copy-of select="preceding-sibling::*"/>
        </selector>
        <properties>
            <xsl:apply-templates mode="selector"/>
        </properties>
    </xsl:template>


    <!-- selector properties -->

    <xsl:template mode="cleanup" match="@*|node()" priority="-9">
        <xsl:copy>
            <xsl:apply-templates mode="cleanup" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="cleanup" match="selector | key | value">
        <xsl:copy>
            <xsl:value-of select="normalize-space(string-join(., ''))"/>
        </xsl:copy>
    </xsl:template>


    <!-- unparse -->

    <xsl:template mode="unparse" match="/">
        <style type="text/css">
            <xsl:apply-templates mode="unparse"/>
        </style>
    </xsl:template>

    <xsl:template mode="unparse" match="rule">
        <xsl:text>
</xsl:text>
            <xsl:apply-templates mode="unparse"/>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template mode="unparse" match="selector">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template mode="unparse" match="properties">
        <xsl:text>
{</xsl:text>
        <xsl:apply-templates mode="unparse"/>
        <xsl:text>
}</xsl:text>
    </xsl:template>

    <xsl:template mode="unparse" match="property">
        <xsl:text>
</xsl:text>
        <xsl:value-of select="key"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="value"/>
        <xsl:text>;</xsl:text>
    </xsl:template>

</xsl:stylesheet>