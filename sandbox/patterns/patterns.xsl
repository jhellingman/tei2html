



map {
 "AA" : "X",
 "A" : "B"
}

lengths (2, 1);


1. sort by length
2. match each length (

4. Get longest possible chunk from string -> found chop and continue
5. Get next longest chunk



 transliterate(string, map, lengths)

 foreach length
    lookup prefix of length in map
    if match then ->
        execute action
        recursive call.
 end
 if length 1 and nothing found: default action, recursive call.



map {
    'A' : map { 'B': ('put', '123') }
    'E' : ('put', '456')
}


<xsl:template match=".[starts-with(., '==')]">
  <h2><xsl:value-of select="replace(., '==', '')"/></h2>
</xsl:template>

<xsl:template match=".[starts-with(., '::')]">
  <p class="indent"><xsl:value-of select="replace(., '::', '')"/></p>
</xsl:template>



<!-- convert pattern file to XSLT templates -->

<xsl:template name="main">
  <xsl:apply-templates select="unparsed-text-lines('input.txt')"/>
</xsl:template>

--> Convert to this:


<xsl:variable name="testPattern">
    <patternFile>
        <patterns name="xyz" noMatch="remove|copy|error">
            <pattern match="ABC">
                <put value="DEF"/>
                <switch name="xyz"/>
            </pattern>
        </patterns>
    </patterns>
</xsl:variable>


<xsl:template match="patternFile">



    <xslo:function name="f:transliterate" as="xs:string">
        <xslo:param name="string" as="xs:string"/>
        <xslo:apply-templates select="$string" mode="{./patterns[1]/@name}"/>
    </xslo:function>

    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="patterns">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="pattern">
    <xslo:template match=".[starts-with(., '{@match}')]" mode="{..\@name}" priority="{string-length(@match)}">
        <xsl:if test="put">
            <xslo:text><xsl:value-of select="{put/@value}"/></xslo:text>
        </xsl:if>
        <xslo:apply-templates select="substring(., string-length(.)" mode="{if (switch/@name) then @name else '#current'}"/>
    </xslo:template>
</xsl:template>





</xsl:template>





Then convert to XSLT rules

-- each pattern becomes a template as follows:
-- each set becomes a mode.
-- switch will change the mode; no switch will use #current.
-- length of start-with establishes priority (longest has highest priority)
-- when restrictive is true, a low-priority template that generates an error (or empty string)

-- Entry point is function (for string)

<xsl:function name="f:transliterate" as="xs:string">
    <xsl:param name="string" as="xs:string">

    <xsl:apply-templates select="$string" mode="initial"/>
</xsl:function>


For node set, somewhat more complicated, basically the same node-set, but with all text nodes transliterated.

<xsl:function name="f:transliterate">
    <xsl:param name="node">

    <xsl:apply-templates select="$node" mode="initial"/>
</xsl:function>




<xsl:template match=".[starts-with(., 'A')]" mode='initial' priority="1">
    <xsl:context as="xs:string" use="required"/>
    <!-- Action -->
    <xsl:value-of="replacement"/>
    <xsl:apply-templates select="substring(., 1)" mode='initial'/>
</xsl:template>










