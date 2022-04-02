<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog"
>
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

	<xsl:variable name="serverName" select="'http://xmlns.greystate.dk'" />

	<xsl:template match="/">
		<xsl:apply-templates select="namespaces" />
	</xsl:template>

	<xsl:template match="namespaces">
		<catalog>
			<xsl:apply-templates select="namespace" />
		</catalog>
	</xsl:template>

	<xsl:template match="namespace">
		<uri name="{@url}" uri=".{substring-after(schemaLocation, $serverName)}" />
	</xsl:template>

</xsl:stylesheet>
