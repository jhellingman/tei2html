<xsl:transform
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0"
>

	<!-- find missing translations in our messages.xml -->

	<xsl:variable name="srclang" select="'en'"/>
	<xsl:variable name="destlang" select="'fr'"/>

	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
	<html>
		<head>
			<title>Missing Translations in Messages.xml</title>

			<style>
				.messageid { }

				.missing { }

				.param { color: red; font-weight: bold; font-family: courier new;}

				TH { text-align: left; }
	
			</style>
		</head>
		<body>
			<h2>Missing Translations in <xsl:value-of select="//message[@name=$destlang and lang('en')]"/></h2>
			<table width="100%">
				<tr><th>Message ID</th><th>Message in <xsl:value-of select="//message[@name=$srclang and lang('en')]"/></th></tr>
				<xsl:apply-templates select="//message" mode="verify"/>
			</table>
		</body>
	</html>
	</xsl:template>


	<xsl:template match="message" mode="verify">
		<xsl:if test="lang($srclang)">
			<xsl:variable name="name" select="@name"/>
			<xsl:variable name="value" select="."/>
			<xsl:if test="not(//message[@name=$name and lang($destlang)])">				
				<tr valign="top">
					<td class="messageid"><xsl:value-of select="@name"/></td>
					<xsl:if test="string-length($value) &lt; 2000">
						<td class="missing"><xsl:apply-templates select="$value" mode="cp"/></td>
					</xsl:if>
					<xsl:if test="string-length($value) &gt; 1999">
						<td>(<i>long message omitted</i>)</td>
					</xsl:if>
				</tr>
			</xsl:if>	
		</xsl:if>
	</xsl:template>


	<xsl:template match="*" mode="cp">
		<xsl:copy>
			<xsl:apply-templates mode="cp"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="param" mode="cp">
		<span class="param">{<xsl:value-of select="@name"/>}</span>
	</xsl:template>

</xsl:transform>
