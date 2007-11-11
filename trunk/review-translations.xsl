<xsl:transform
	xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0"
>

	<!-- review translations in our messages.xml -->

	<xsl:variable name="srclang" select="'en'"/>
	<xsl:variable name="destlang" select="'de'"/>

	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
	<html>
		<head>
			<title>Review Translations in Messages.xml</title>

			<style>

				.param { color: red; font-weight: bold; font-family: courier new;}

				TH { text-align: left; }
	
			</style>
		</head>
		<body>
			<h2>Review Translations in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></h2>
			<table width="100%">
				<tr>
					<th>Message ID</th>
					<th>Message in <xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/></th>
					<th>Message in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></th>
				</tr>
				<xsl:apply-templates select="//msg:message" mode="verify"/>
			</table>
		</body>
	</html>
	</xsl:template>


	<xsl:template match="msg:message" mode="verify">
		<xsl:if test="lang($srclang)">
			<xsl:variable name="name" select="@name"/>
			<xsl:variable name="value" select="."/>
			<xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang)]"/>
			<tr valign="top">
				<td>
					<xsl:value-of select="@name"/>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="string-length($value) &lt; 2000">
							<xsl:apply-templates select="$value" mode="cp"/>
						</xsl:when>
						<xsl:otherwise>
							(<i>long message omitted</i>)
						</xsl:otherwise>
					</xsl:choose>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="$translation">
							<xsl:choose>
								<xsl:when test="string-length($translation) &lt; 2000">
									<xsl:apply-templates select="$translation" mode="cp"/>
								</xsl:when>
								<xsl:otherwise>
									(<i>long message omitted</i>)
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							(<i>no translation available</i>)
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>


	<xsl:template match="*" mode="cp">
		<xsl:copy>
			<xsl:apply-templates mode="cp"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="msg:param" mode="cp">
		<span class="param">{<xsl:value-of select="@name"/>}</span>
	</xsl:template>

</xsl:transform>
