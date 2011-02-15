<?xml version="1.0" encoding="utf-8"?>

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
        
        <xsl:variable name="groups">
            <xsl:apply-templates mode="groups" select="$tokens/*[1]"/>
        </xsl:variable>

        <xsl:variable name="properties">
            <xsl:apply-templates mode="properties" select="$groups"/>
        </xsl:variable>

        <stylesheet>
            <xsl:copy-of select="$properties"/>
        </stylesheet>
    </xsl:template>

    <!--
        Use analyze-string to split the string into lexical items.

        1. comment:     /\*(.*?)\*/
        2. string:      ('|&quot;)(.*?)\1
        3. number:      (-?\d+(\.\d+)?)
        4. word:        (\w+)
        5. symbol:      ([:;,.#@\{\}\[\]])
        6. space:       (\s+)
        
    -->
    <xsl:template name="tokenize">
        <xsl:param name="text"/>

        <xsl:variable name="patterns" 
            select="'/\*(.*?)\*/','(''|&quot;)(.*?)\2','(-?\d+(\.\d+)?)','([\w-]+)','([:;,.\{\}\[\]])','(\s+)'"/>

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
                            <xsl:value-of select="regex-group(3)"/>
                        </string>
                    </xsl:when>
                    <!-- number -->
                    <xsl:when test="regex-group(4)">
                        <number>
                            <xsl:value-of select="regex-group(4)"/>
                        </number>
                    </xsl:when>
                    <!-- word -->
                    <xsl:when test="regex-group(6)">
                        <word>
                            <xsl:value-of select="regex-group(6)"/>
                        </word>
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
                <xsl:if test="normalize-space()!=''">
                    <xsl:message select="concat('unknown token: ', .)"/>
                </xsl:if>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <!-- use sibling recursion to group things between braces -->

    <xsl:template mode="groups" match="node()" priority="-9">
        <xsl:copy-of select="."/>
        <xsl:apply-templates mode="groups" select="following-sibling::*[1]"/>
    </xsl:template>

    <xsl:template mode="groups" match="symbol[.='}']"/>

    <xsl:template mode="groups" match="symbol[.='{']">
        <group>
            <xsl:apply-templates mode="groups" select="following-sibling::*[1]"/>
        </group>
        <xsl:variable name="level" select="count(preceding-sibling::symbol[.='{']) - count(preceding-sibling::symbol[.='}']) + 1"/>
        <xsl:variable name="closer"
            select="following-sibling::symbol[.='}' and (count(preceding-sibling::symbol[.='{']) - count(preceding-sibling::symbol[.='}'])) = $level][1]"/>
        <xsl:apply-templates mode="groups" select="$closer/following-sibling::*[1]"/>
    </xsl:template>


    <!-- group properties -->

    <xsl:template mode="properties" match="group">
        <group>
            <xsl:for-each-group select="*" group-ending-with="symbol[.=';']">
                <property>
                    <xsl:apply-templates mode="properties" select="current-group()"/>
                </property>
            </xsl:for-each-group>
        </group>
    </xsl:template>




</xsl:stylesheet>