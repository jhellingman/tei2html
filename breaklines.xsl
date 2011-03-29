<?xml version="1.0" encoding="utf-8"?>

<!-- An experimental XSLT stylesheet to break a paragraph into lines. -->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


    <xsl:template match="/">
        <xsl:call-template name="breaklines">
            <xsl:with-param name="text" select="'Dit is een kleine test van de functie break-lines. Hiermee moeten we regels in stukjes kunnen breken, zodat de zinnen netjes in een smalle kolom passen.'"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="breaklines">
        <xsl:param name="text"/>

        <xsl:variable name="tokens">
            <xsl:call-template name="tokenize">
                <xsl:with-param name="text" select="$text"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="lines">
            <xsl:call-template name="lines">
                <xsl:with-param name="tokens" select="$tokens"/>
            </xsl:call-template>
        </xsl:variable>

        <paragraph>
            <xsl:copy-of select="$lines"/>
        </paragraph>
    </xsl:template>

    <!--
        Use analyze-string to split the string into lexical items.

        1. box:         ([^\s-]+-?)
        2. space:       (\s+)

    -->
    <xsl:template name="tokenize">
        <xsl:param name="text"/>

        <xsl:variable name="patterns" select="'([^-\s]+-?)','(\s+)'"/>

        <xsl:analyze-string select="$text" regex="{string-join($patterns, '|')}" flags="s">
            <xsl:matching-substring>
                <xsl:choose>
                    <!-- box -->
                    <xsl:when test="regex-group(1)">
                        <box>
                            <xsl:value-of select="regex-group(1)"/>
                        </box>
                    </xsl:when>
                    <!-- glue -->
                    <xsl:when test="regex-group(2)">
                        <glue>
                            <xsl:value-of select="regex-group(2)"/>
                        </glue>
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


    <xsl:template name="lines">
        <xsl:param name="tokens"/>

        <xsl:variable name="breaks">
            <xsl:call-template name="append-next">
                <xsl:with-param name="tokens" select="$tokens/*"/>
                <xsl:with-param name="max" select="44"/>
                <xsl:with-param name="length" select="0"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:for-each-group select="$breaks/*" group-starting-with="break">
          <line length="{string-length(string-join(current-group(), ''))}">
            <xsl:apply-templates select="current-group()"/>
          </line>
        </xsl:for-each-group>


    </xsl:template>

    <xsl:template name="append-next">
        <xsl:param name="tokens"/>
        <xsl:param name="max"/>
        <xsl:param name="length"/>

        <!-- <d length="{$length}"/> -->
        <xsl:if test="$tokens">
            <xsl:variable name="head" select="$tokens[1]"/>
            <xsl:variable name="next" select="$tokens[2]"/>
            <xsl:variable name="tail" select="$tokens[position() != 1]"/>
            <xsl:choose>

                <!-- head is glue and next item does not fit anymore -->
                <xsl:when test="$head/self::glue and $length + string-length($head) + string-length($next) &gt; $max ">
                    <break/>
                    <xsl:call-template name="append-next">
                        <xsl:with-param name="tokens" select="$tail"/>
                        <xsl:with-param name="max" select="$max"/>
                        <xsl:with-param name="length" select="0"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- head is not glue and next not fit anymore -->
                <xsl:when test="$length + string-length($head) + string-length($next) &gt; $max">
                    <xsl:copy-of select="$head"/>
                    <break/>
                    <xsl:call-template name="append-next">
                        <xsl:with-param name="tokens" select="if ($next/self::glue) then $tokens[position() &gt; 2] else $tail"/>
                        <xsl:with-param name="max" select="$max"/>
                        <xsl:with-param name="length" select="0"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- next does fit -->
                <xsl:otherwise>
                    <xsl:copy-of select="$head"/>
                    <xsl:call-template name="append-next">
                        <xsl:with-param name="tokens" select="$tail"/>
                        <xsl:with-param name="max" select="$max"/>
                        <xsl:with-param name="length" select="$length + string-length($head)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
