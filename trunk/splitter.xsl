

    <xsl:template match="text" mode="splitter">
        <xsl:param name="action"/>
        <xsl:param name="search"/>

        <xsl:apply-templates select="front">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="search" select="$search"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="body">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="search" select="$search"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="back">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="search" select="$search"/>
        </xsl:apply-templates>

    </xsl:template>


    <xsl:template match="body[div0]" mode="splitter">
        <xsl:param name="action"/>
        <xsl:param name="search"/>

        <xsl:apply-templates select="div0" mode="splitter">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="search" select="$search"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="div0 | front | back | body[div1]" mode="splitter">
        <xsl:param name="action"/>
        <xsl:param name="search"/>

        <xsl:for-each-group select="node()" group-adjacent="not(self::div1)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-div1 elements -->
                    <xsl:call-template name="div0fragment">
                        <xsl:with-param name="action" select="$action"/>
                        <xsl:with-param name="search" select="$search"/>
                        <xsl:with-param name="nodes" select="current-group()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sequence of div1 elements -->
                    <xsl:apply-templates select="current-group()" mode="splitter">
                        <xsl:with-param name="action" select="$action"/>
                        <xsl:with-param name="search" select="$search"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template name="div0fragment">
        <xsl:param name="action"/>
        <xsl:param name="search"/>
        <xsl:param name="nodes"/>

        <xsl:choose>
            <xsl:when test="$action = 'search'">
                <xsl:apply-templates select="$nodes" mode="search">     <!-- probably mostly need call-template here -->
                    <xsl:with-param name="search" select="$search"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$action = 'navMap'">
                <xsl:apply-templates select="$nodes" mode="navMap"/>
            </xsl:when>
            <xsl:when test="$action = 'manifest'">
                <xsl:apply-templates select="$nodes" mode="manifest"/>
            </xsl:when>
            <xsl:when test="$action = 'spine'">
                <xsl:apply-templates select="$nodes" mode="spine"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$nodes" mode="splitter"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="div1" mode="splitter">
        <xsl:param name="action"/>
        <xsl:param name="search"/>

        <xsl:choose>
            <xsl:when test="$action = 'search'">                        <!-- probably mostly need call-template here -->
                <xsl:apply-templates mode="search">
                    <xsl:with-param name="search" select="$search"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$action = 'navMap'">
                <xsl:apply-templates mode="navMap"/>
            </xsl:when>
            <xsl:when test="$action = 'manifest'">
                <xsl:apply-templates mode="manifest"/>
            </xsl:when>
            <xsl:when test="$action = 'spine'">
                <xsl:apply-templates mode="spine"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="splitter"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
