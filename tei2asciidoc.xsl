<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY lf "&#10;">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei xs"
    version="3.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Strip extra whitespace but preserve meaningful spaces -->
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:p tei:l tei:head tei:hi tei:emph tei:title tei:name"/>
    
    <!-- Root template -->
    <xsl:template match="/">
        <xsl:apply-templates select="//tei:teiHeader"/>
        <xsl:text>&lf;'''&lf;&lf;</xsl:text>
        <xsl:apply-templates select="//tei:text"/>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- TEI HEADER - Metadata Section -->
    <!-- ============================================ -->
    
    <xsl:template match="tei:teiHeader">
        <xsl:text>= </xsl:text>
        <xsl:value-of select="normalize-space(tei:fileDesc/tei:titleStmt/tei:title[1])"/>
        <xsl:text>&lf;</xsl:text>
        
        <!-- Author(s) -->
        <xsl:if test="tei:fileDesc/tei:titleStmt/tei:author">
            <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:author">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:if test="position() != last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>&lf;</xsl:text>
        </xsl:if>
        
        <!-- Document attributes -->
        <xsl:text>:toc: left&lf;</xsl:text>
        <xsl:text>:toclevels: 3&lf;</xsl:text>
        <xsl:text>:numbered:&lf;</xsl:text>
        
        <!-- Publication info if available -->
        <xsl:if test="tei:fileDesc/tei:publicationStmt/tei:date">
            <xsl:text>:revdate: </xsl:text>
            <xsl:value-of select="normalize-space(tei:fileDesc/tei:publicationStmt/tei:date)"/>
            <xsl:text>&lf;</xsl:text>
        </xsl:if>
        
        <xsl:text>&lf;</xsl:text>
        
        <!-- Additional metadata in a section -->
        <xsl:if test="tei:fileDesc/tei:publicationStmt/* or tei:fileDesc/tei:sourceDesc/*">
            <xsl:text>[.metadata]&lf;</xsl:text>
            <xsl:text>****&lf;</xsl:text>
            <xsl:text>*Document Information*&lf;&lf;</xsl:text>
            
            <!-- Publisher -->
            <xsl:if test="tei:fileDesc/tei:publicationStmt/tei:publisher">
                <xsl:text>*Publisher:* </xsl:text>
                <xsl:value-of select="normalize-space(tei:fileDesc/tei:publicationStmt/tei:publisher)"/>
                <xsl:text>&lf;&lf;</xsl:text>
            </xsl:if>
            
            <!-- Publication place -->
            <xsl:if test="tei:fileDesc/tei:publicationStmt/tei:pubPlace">
                <xsl:text>*Publication Place:* </xsl:text>
                <xsl:value-of select="normalize-space(tei:fileDesc/tei:publicationStmt/tei:pubPlace)"/>
                <xsl:text>&lf;&lf;</xsl:text>
            </xsl:if>
            
            <!-- Source description -->
            <xsl:if test="tei:fileDesc/tei:sourceDesc/tei:p">
                <xsl:text>*Source:* </xsl:text>
                <xsl:value-of select="normalize-space(tei:fileDesc/tei:sourceDesc/tei:p)"/>
                <xsl:text>&lf;&lf;</xsl:text>
            </xsl:if>
            
            <xsl:text>****&lf;&lf;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- TEXT STRUCTURE -->
    <!-- ============================================ -->
    
    <xsl:template match="tei:text">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:body | tei:front | tei:back">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Divisions with headers -->
    <xsl:template match="tei:div">
        <xsl:variable name="level" select="count(ancestor::tei:div) + 2"/>
        <xsl:text>&lf;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Headers/Headings -->
    <xsl:template match="tei:head">
        <xsl:variable name="level" select="count(ancestor::tei:div) + 2"/>
        <xsl:value-of select="string-join((1 to $level) ! '=', '')"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;&lf;</xsl:text>
    </xsl:template>
    
    <!-- Paragraphs -->
    <xsl:template match="tei:p">
        <xsl:apply-templates/>
        <xsl:text>&lf;&lf;</xsl:text>
    </xsl:template>
    
    <!-- Line groups (poetry/verse) -->
    <xsl:template match="tei:lg">
        <xsl:text>[verse]&lf;</xsl:text>
        <xsl:text>____&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>____&lf;&lf;</xsl:text>
    </xsl:template>
    
    <!-- Lines -->
    <xsl:template match="tei:l">
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- INLINE ELEMENTS -->
    <!-- ============================================ -->
    
    <!-- Emphasis/highlighting -->
    <xsl:template match="tei:hi[@rend='italic'] | tei:emph">
        <xsl:text>_</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>_</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend=('bold', 'strong')]">
        <xsl:text>*</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>*</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend='underline']">
        <xsl:text>[underline]#</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>#</xsl:text>
    </xsl:template>

    <xsl:template match="tei:hi[@rend=('smallcaps', 'sc')]">
        <xsl:text>[.smallcaps]#</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>#</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend=('sup', 'superscript')]">
        <xsl:text>^</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>^</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend=('sub', 'subscript')]">
        <xsl:text>~</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>~</xsl:text>
    </xsl:template>
    
    <!-- Default hi template for unspecified renditions -->
    <xsl:template match="tei:hi[not(@rend)]">
        <xsl:text>_</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>_</xsl:text>
    </xsl:template>
    
    <!-- Titles -->
    <xsl:template match="tei:title">
        <xsl:text>_</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>_</xsl:text>
    </xsl:template>
    
    <!-- Names -->
    <xsl:template match="tei:name | tei:persName | tei:placeName">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Dates -->
    <xsl:template match="tei:date">
        <xsl:apply-templates/>
        <xsl:if test="@when">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="@when"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- Quoted text -->
    <xsl:template match="tei:q | tei:quote[@rend='inline']">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
    <!-- Block quotes -->
    <xsl:template match="tei:quote[not(@rend='inline')]">
        <xsl:text>____&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;____&lf;&lf;</xsl:text>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- NOTES AND REFERENCES -->
    <!-- ============================================ -->
    
    <!-- Footnotes -->
    <xsl:template match="tei:note[@place='foot' or @place='bottom' or not(@place)]">
        <xsl:text>footnote:[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <!-- Margin notes or other notes -->
    <xsl:template match="tei:note[@place='margin' or @place='end']">
        <xsl:text>&lf;&lf;[NOTE]&lf;</xsl:text>
        <xsl:text>====&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;====&lf;&lf;</xsl:text>
    </xsl:template>
    
    <!-- Cross-references -->
    <xsl:template match="tei:ref[@target]">
        <xsl:choose>
            <xsl:when test="starts-with(@target, '#')">
                <!-- Internal reference -->
                <xsl:text>&lt;&lt;</xsl:text>
                <xsl:value-of select="substring(@target, 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>&gt;&gt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- External reference -->
                <xsl:text>link:</xsl:text>
                <xsl:value-of select="@target"/>
                <xsl:text>[</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Anchors for cross-referencing -->
    <xsl:template match="tei:anchor[@xml:id]">
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>]]</xsl:text>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- LISTS -->
    <!-- ============================================ -->
    
    <xsl:template match="tei:list[@type='ordered']">
        <xsl:text>&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:list[not(@type) or @type=('unordered', 'simple')]">
        <xsl:text>&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:list[@type='ordered']/tei:item">
        <xsl:text>. </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:list[not(@type) or @type=('unordered', 'simple')]/tei:item">
        <xsl:text>* </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:list[@type='gloss']">
        <xsl:text>&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:list[@type='gloss']/tei:label">
        <xsl:apply-templates/>
        <xsl:text>::</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:list[@type='gloss']/tei:item">
        <xsl:text>&lf;  </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- FIGURES AND IMAGES -->
    <!-- ============================================ -->
    
    <xsl:template match="tei:figure">
        <xsl:text>&lf;</xsl:text>
        <xsl:apply-templates select="tei:graphic"/>
        <xsl:if test="tei:figDesc or tei:head">
            <xsl:text>.&lf;</xsl:text>
            <xsl:value-of select="normalize-space((tei:head, tei:figDesc)[1])"/>
            <xsl:text>&lf;</xsl:text>
        </xsl:if>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:graphic">
        <xsl:text>image::</xsl:text>
        <xsl:value-of select="@url"/>
        <xsl:text>[</xsl:text>
        <xsl:if test="../tei:figDesc">
            <xsl:value-of select="normalize-space(../tei:figDesc)"/>
        </xsl:if>
        <xsl:if test="@width">
            <xsl:text>,width=</xsl:text>
            <xsl:value-of select="@width"/>
        </xsl:if>
        <xsl:if test="@height">
            <xsl:text>,height=</xsl:text>
            <xsl:value-of select="@height"/>
        </xsl:if>
        <xsl:text>]</xsl:text>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- TABLES -->
    <!-- ============================================ -->
    
    <xsl:template match="tei:table">
        <xsl:text>&lf;</xsl:text>
        <xsl:if test="tei:head">
            <xsl:text>.</xsl:text>
            <xsl:value-of select="normalize-space(tei:head)"/>
            <xsl:text>&lf;</xsl:text>
        </xsl:if>
        <xsl:text>[cols="</xsl:text>
        <xsl:value-of select="string-join((1 to count(tei:row[1]/tei:cell)) ! '1', ',')"/>
        <xsl:text>"]&lf;</xsl:text>
        <xsl:text>|===&lf;</xsl:text>
        <xsl:apply-templates select="tei:row"/>
        <xsl:text>|===&lf;&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:row">
        <xsl:apply-templates select="tei:cell"/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:cell">
        <xsl:text>| </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- ============================================ -->
    <!-- SPECIAL ELEMENTS -->
    <!-- ============================================ -->
    
    <!-- Line breaks -->
    <xsl:template match="tei:lb">
        <xsl:text> +&lf;</xsl:text>
    </xsl:template>
    
    <!-- Page breaks - ignored -->
    <xsl:template match="tei:pb"/>
        
    <!-- Milestone (generic boundary marker) -->
    <xsl:template match="tei:milestone">
        <xsl:text>&lf;---&lf;&lf;</xsl:text>
    </xsl:template>
    
    <!-- Foreign language -->
    <xsl:template match="tei:foreign">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="@xml:lang"/>
        <xsl:text>]#</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>#</xsl:text>
    </xsl:template>
    
    <!-- Gaps in the text -->
    <xsl:template match="tei:gap">
        <xsl:text>[...]</xsl:text>
    </xsl:template>
    
    <!-- Unclear passages -->
    <xsl:template match="tei:unclear">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>?]</xsl:text>
    </xsl:template>
    
    <!-- Additions -->
    <xsl:template match="tei:add">
        <xsl:text>&#94;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&#94;</xsl:text>
    </xsl:template>
    
    <!-- Deletions -->
    <xsl:template match="tei:del">
        <xsl:text>[.line-through]#</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>#</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>