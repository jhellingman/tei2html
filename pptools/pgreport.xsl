<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="1.0"
    exclude-result-prefixes="xd">

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="UTF-8"/>

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to present pgreport.xml.</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:template match="/">
    <html>
        <head>
            <title>Overview of TEI files</title>

            <script type="text/javascript" src="@Tools/jquery-latest.js"/>
            <script type="text/javascript" src="@Tools/jquery.tablesorter.js"/>

            <style type="text/css">

                table { width: 100%; }
                th, td { text-align: left; vertical-align: top; }
                th { background-color: #edcc80; }
                tr:nth-child(odd) { background: #fffde3; }
                .tdRight { text-align: right; }
                .tdCenter { text-align: center; }
                tr:nth-child(odd) .warn { background-color: #fcf279; }
                tr:nth-child(even) .warn { background-color: #fcf5a7; }

            </style>

            <script>

                $(document).ready(function() 
                    { 
                        $("#pgbookstable").tablesorter(); 
                    } 
                ); 

            </script>

        </head>
        <body>
            <h2>Overview of TEI files</h2>

            <xsl:apply-templates/>
        </body>
    </html>
    </xsl:template>


    <xsl:template match="pgreport">
        <table id="pgbookstable" class="tablesorter">
            <thead>
                <tr>
                    <th>File</th>
                    <!-- <th>Ver.</th> -->
                    <th>Number</th>
                    <!-- <th>PGPH</th> -->
                    <th>Year</th>
                    <th>Author, Title</th>
                    <th>Description</th>
                    <th>Keywords</th>
                    <th>Posted</th>
                    <th>Pages</th>
                    <th>Words</th>
                    <th title="Language">Lang.</th>
                    <th>Img.</th>
                    <th title="Cover">Cover</th>
                    <th title="TitlePage">Title page</th>
                    <!--
                    <th>GUID</th>
                    <th>PGDP</th>
                    <th>Git</th>
                    -->
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
            <tfoot>
                <tr>
                    <td/>
                    <!-- <td/> -->
                    <td/>
                    <!-- <td/> -->
                    <td/>
                    <td/>
                    <td/>
                    <td/>
                    <td/>
                    <td class="tdRight">
                        <b><xsl:value-of select="sum(//pageCount)"/></b>
                    </td>
                    <td class="tdRight">
                        <b><xsl:value-of select="sum(//wordCount)"/></b>
                    </td>
                    <td/>
                    <td class="tdRight">
                        <b><xsl:value-of select="sum(//imageCount)"/></b>
                    </td>
                    <!--
                    <td/>
                    <td/>
                    <td/>
                    -->
                </tr>
            </tfoot>

        </table>
    </xsl:template>

    <!-- Comment out the following line to see ALL books -->
    <!--<xsl:template match="book[(pgsource and pgsource != '' and pgsource != '#####') or (contains(rights, 'subject to copyright'))]"/>-->


    <xsl:template match="book">
        <tr>
            <td>
                <xsl:value-of select="file/name"/>
                <br/>
                <a href="{file/path}Processed/{file/baseName}.html">HTML</a> |
                <xsl:choose>
                    <xsl:when test="file/encoding = 'UTF8'">
                        <a href="{file/path}Processed/{file/baseName}-utf8.txt">UTF8 Text</a> |
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{file/path}Processed/{file/baseName}.txt">Text</a> |
                    </xsl:otherwise>
                </xsl:choose>
                <a href="{file/path}{file/baseName}-words.html">Words</a> |
                <a href="{file/path}{file/baseName}-checks.html">Checks</a>
                <!-- <a href="{file/path}README.adoc">Readme</a> -->
                <br/>
                <xsl:if test="projectId and projectId != ''">
                    <a href="https://www.pgdp.net/c/project.php?id={projectId}">PGDP</a> |
                </xsl:if>
                <xsl:if test="epubid and epubid != ''">
                    <span title="{epubid}">Guid</span>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="pgsource and pgsource != '' and pgsource != '#####' ">
                        <br/>
                        <a href="https://github.com/GutenbergSource/{pgsource}">Git</a>
                    </xsl:when>
                    <xsl:when test="contains(rights, 'subject to copyright')"> ©</xsl:when>
                    <xsl:otherwise> Nogit</xsl:otherwise>
                </xsl:choose>
                <br/>
                <xsl:if test="errors &gt; 0"> ❌ <xsl:value-of select="errors"/></xsl:if>
                <xsl:if test="warnings &gt; 0"> ⚠️ <xsl:value-of select="warnings"/></xsl:if>
                <xsl:if test="trivials &gt; 0"> ℹ️ <xsl:value-of select="trivials"/></xsl:if>
            </td>
            <!-- 
            <td>
                <xsl:value-of select="file/version"/>
            </td>
            -->
            <td class="tdCenter">
                <xsl:choose>
                    <xsl:when test="pgnumber != '' and pgnumber != '#####'">
                        <a>
                            <xsl:attribute name="href">https://www.gutenberg.org/ebooks/<xsl:value-of select="pgnumber"/></xsl:attribute>
                            <img height="74" src="{file/path}Processed/images/qr{pgnumber}.png"/>
                        </a>
                        <xsl:value-of select="pgnumber"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">warn</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </td>

            <!--
            <td class="tdRight">
                <xsl:value-of select="pgphnumber"/>
            </td>
            -->
            <td>
                <xsl:value-of select="date"/>
            </td>
            <td>
                <b>
                    <xsl:for-each select="author">
                        <xsl:if test="preceding-sibling::author"><xsl:text>, </xsl:text></xsl:if>
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </b>
                <xsl:text>: </xsl:text>
                <i><xsl:value-of select="title"/></i>
                
                <xsl:if test="editor"><br/>Ed.
                <xsl:for-each select="editor">
                        <xsl:if test="preceding-sibling::editor"><xsl:text>, </xsl:text></xsl:if>
                        <xsl:value-of select="."/>
                </xsl:for-each>
                </xsl:if>
                
                <xsl:if test="contributor[not(. = 'Jeroen Hellingman')]"><br/><xsl:text>[</xsl:text>
                <xsl:for-each select="contributor[not(. = 'Jeroen Hellingman')]">
                        <xsl:if test="preceding-sibling::contributor[not(. = 'Jeroen Hellingman')]"><xsl:text>, </xsl:text></xsl:if>
                        <xsl:value-of select="."/>
                </xsl:for-each>]
                </xsl:if>
                
            </td>


            <td><xsl:value-of select="description"/></td>
            <td>
                <xsl:if test="not(keyword) or keyword = ''"><xsl:attribute name="class">warn</xsl:attribute></xsl:if>
                <xsl:for-each select="keyword">
                    <xsl:if test="preceding-sibling::keyword"><xsl:text>, </xsl:text></xsl:if>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </td>
            <td>
                <xsl:if test="string-length (postedDate) != 10">
                    <xsl:attribute name="class">warn</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="postedDate"/>
            </td>
            <td class="tdRight"><xsl:value-of select="pageCount"/></td>
            <td class="tdRight"><xsl:value-of select="wordCount"/></td>
            <td><xsl:value-of select="language"/></td>
            <td class="tdRight"><xsl:value-of select="imageCount"/></td>
            <td class="tdCenter">
                <xsl:if test="not(cover) or cover = ''"><xsl:attribute name="class">warn</xsl:attribute></xsl:if>
                <xsl:if test="cover and cover != ''">
                    <img height="180" style="max-width: 160px" src="{file/path}Processed/{cover}"/>
                </xsl:if>
            </td>
            <td class="tdCenter">
                <xsl:if test="not(titlePage) or titlePage = ''"><xsl:attribute name="class">warn</xsl:attribute></xsl:if>
                <xsl:if test="titlePage and titlePage != ''">
                    <img height="180" style="max-width: 160px" src="{file/path}Processed/{titlePage}"/>
                </xsl:if>
            </td>
            <!--
            <td>
                <xsl:if test="not(epubid) or epubid = ''"><xsl:attribute name="class">warn</xsl:attribute></xsl:if>
                <xsl:if test="epubid and epubid != ''"><span title="{epubid}">G</span></xsl:if>
            </td>
            <td>
                <xsl:if test="projectId and projectId != ''"><a href="http://www.pgdp.net/c/project.php?id={projectId}">P</a></xsl:if>
            </td>
            <td>
            </td>
            -->

        </tr>
    </xsl:template>

</xsl:stylesheet>
