<?xml version="1.0" encoding="UTF-8"?>
<!--
	File:		namespace-transform.xml
	Author:		Chriztian Steinmeier
	Created:	2002-04-24
	RCS-Id
		$Id: namespace-transform.xsl,v 1.7 2005-03-31 03:42:51+02 chriz Exp chriz $
	Description
		Transforms the main info for namespaces.

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
	exclude-result-prefixes="xsl xsd xhtml cat"
>
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" />

<!-- Parameters -->
	<xsl:param name="namespace" select="'http://xmlns.greystate.dk/2022/wordles'" />
	<xsl:param name="currentYear" select="'2024'" />

<!-- Variables -->
	<xsl:variable name="serverName">http://xmlns.greystate.dk</xsl:variable>
	<xsl:variable name="schemaServer" select="concat($serverName, '/')" />

	<xsl:variable name="schemaElement" select="document(substring-after(/cat:catalog/cat:uri[@name = $namespace]/@uri, './'))/xsd:schema" />

	<xsl:variable name="xsdOutputPrefix">xsd:</xsl:variable>
	<!-- Find the prefix used in source for the XML Schema Namespace -->
	<xsl:variable name="prefix"><xsl:for-each select="$schemaElement/namespace::*[. = 'http://www.w3.org/2001/XMLSchema']"><xsl:value-of select="local-name()"/></xsl:for-each></xsl:variable>
	<xsl:variable name="xsdPrefix">
		<xsl:choose>
			<xsl:when test="$prefix = ''"><xsl:text></xsl:text></xsl:when>
			<xsl:otherwise><xsl:value-of select="concat($prefix, ':')" /></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

<!-- Templates -->
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="cat:catalog">
		<xsl:if test="$namespace = $serverName">
			<h2>{<code><xsl:value-of select="$serverName" /></code>}</h2>
			<dl>
				<dt>Description</dt>
				<dd>
					This is the root of the Greystate XML Namespaces. They all follow the format of suffixing this URL with a four-digit year, followed by the
					name of the namespace.
				</dd>
				<dt>Available namespaces</dt>
				<dd>
					<ul>
						<xsl:apply-templates select="cat:uri" mode="toc-mode">
							<xsl:sort select="substring-before(substring-after(@name, concat($serverName, '/')), '/')" data-type="number" order="descending" />
						</xsl:apply-templates>
					</ul>
				</dd>
			</dl>
		</xsl:if>
		<xsl:apply-templates select="cat:uri[@name = $namespace]" />
		<div id="footer">
			<address>
				Copyright 2002-<xsl:value-of select="$currentYear" /> by Chriztian Steinmeier.
			</address>
		</div>
	</xsl:template>

	<xsl:template match="cat:uri">
		<h2>{<code><a href="{$serverName}"><xsl:value-of select="$serverName" /></a><xsl:value-of select="substring-after(@name, $serverName)" /></code>}</h2>
		<dl>
			<dt>Description</dt>
			<dd>
				<xsl:apply-templates select="$schemaElement/xsd:annotation" />
			</dd>

			<dt>XMLSchema</dt>
			<dd>
				<p>
					<xsl:apply-templates select="@uri" />
				</p>
				<xsl:if test="$schemaElement[xsd:include]">
					Includes:
					<ul>
						<xsl:for-each select="$schemaElement/xsd:include/@schemaLocation">
							<li><a href="{.}"><xsl:value-of select="." /></a></li>
						</xsl:for-each>
					</ul>
				</xsl:if>
			</dd>

			<dt>Elements defined</dt>
			<dd>
				<xsl:for-each select="$schemaElement">
					<xsl:apply-templates select="." />
				</xsl:for-each>
			</dd>
		</dl>
	</xsl:template>

	<xsl:template match="cat:uri" mode="toc-mode">
		<li><a href="{substring-after(@name, $serverName)}"><xsl:value-of select="@name" /></a></li>
	</xsl:template>

	<xsl:template match="cat:uri[not(@uri)]" mode="toc-mode">
		<li><xsl:value-of select="@name" /></li>
	</xsl:template>


	<xsl:template match="@uri">
		<a href="{substring-after(., '.')}" target="_blank" title="Open schema in new browser"><xsl:value-of select="concat($schemaServer, substring-after(., './'))" /></a>
	</xsl:template>

<!-- XMLSchema templates -->
	<!-- Schema root -->
	<xsl:template match="xsd:schema">
		<xsl:apply-templates select="xsd:element | xsd:include" />
	</xsl:template>

	<!-- Root-level simpleType -->
	<!-- <xsl:template match="xsd:schema/xsd:simpleType"> -->
		<!-- TODO: How do we show this? -->
	<!-- </xsl:template> -->

	<xsl:template match="xsd:include">
		<xsl:apply-templates select="document(@schemaLocation)/xsd:schema" />
	</xsl:template>

	<xsl:template match="xsd:element//xsd:attribute">
		<xsl:choose>
			<xsl:when test="@ref">
				<xsl:apply-templates select="//xsd:attribute[@name = current()/@ref]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
				<span class="attribute">
					<xsl:value-of select="@name" />=&quot;<xsl:apply-templates />&quot;
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xsd:element//xsd:attribute[starts-with(@ref, 'xml:')]">
		<xsl:text> </xsl:text>
		<span class="nsattribute">
			<xsl:value-of select="@ref" />=&quot;<span class="typeref">xsd:string</span>&quot;
		</span>
	</xsl:template>

	<xsl:template match="xsd:element[@name]">
		<div class="elementwrapper">
			<code>
				<xsl:text>&lt;</xsl:text>
				<span class="element"><xsl:value-of select="@name" /></span>
				<xsl:apply-templates select=".//xsd:attribute" />
				<xsl:text> /&gt;</xsl:text>
			</code>
			<xsl:apply-templates select="xsd:simpleType | xsd:complexType | xsd:key | xsd:keyref | xsd:unique" />
			<xsl:if test="@type">
				<xsl:text> </xsl:text>
				<code class="typeref">
					<xsl:if test="starts-with(@type, $xsdPrefix)"><xsl:attribute name="class">typeref xsdtype</xsl:attribute></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="@type" />
				</code>
			</xsl:if>
			<xsl:apply-templates select="xsd:complexType/xsd:simpleContent/xsd:extension" />
			<xsl:apply-templates select="xsd:annotation" />
		</div>
	</xsl:template>

	<xsl:template match="xsd:extension[@base][count(*[not(local-name() = 'attribute')]) = 0]">
		<xsl:text> </xsl:text>
		<code class="typeref">
			<xsl:if test="starts-with(@base, $xsdPrefix)"><xsl:attribute name="class">typeref xsdtype</xsl:attribute></xsl:if>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="@base" />
		</code>
	</xsl:template>

	<xsl:template match="xsd:extension[xsd:*[not(self::xsd:attribute)]]" />

	<xsl:template match="xsd:element[@ref]">
		<div class="elementwrapper">
			<code><span class="element"><xsl:value-of select="@ref" /></span></code>
		</div>
	</xsl:template>

	<xsl:template match="xsd:complexType">
		<xsl:apply-templates select="xsd:annotation | xsd:simpleContent | xsd:complexContent | xsd:group | xsd:all | xsd:choice | xsd:sequence" />
	</xsl:template>

	<xsl:template match="xsd:simpleType">
		<xsl:apply-templates select="xsd:restriction | xsd:list | xsd:union" />
	</xsl:template>

	<xsl:template match="xsd:simpleContent">

	</xsl:template>

	<xsl:template match="xsd:sequence">
		(<xsl:for-each select="*"><xsl:apply-templates select="." /><xsl:if test="not(position()=last())">, </xsl:if></xsl:for-each>)
	</xsl:template>

	<xsl:template match="xsd:choice">
		(<xsl:for-each select="*"><xsl:apply-templates select="." /><xsl:if test="not(position()=last())"> | </xsl:if></xsl:for-each>)
	</xsl:template>

	<xsl:template match="xsd:all">
		(<xsl:for-each select="*">(<xsl:apply-templates select="." />)<b class="cardinality">?</b> <xsl:if test="not(position()=last())">, </xsl:if></xsl:for-each>)
	</xsl:template>

	<xsl:template match="xsd:choice/xsd:element[@ref] | xsd:sequence/xsd:element[@ref] | xsd:all/xsd:element[@ref]">
		<xsl:value-of select="@ref" /><xsl:call-template name="cardinality" />
	</xsl:template>

	<xsl:template match="xsd:group[@ref]">
		<span class="groupwrapper">
			<xsl:apply-templates select="//xsd:group[@name = current()/@ref]" /><xsl:call-template name="cardinality" />
		</span>
	</xsl:template>

	<xsl:template match="xsd:group[@name]">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="xsd:restriction[xsd:enumeration]">
		<xsl:for-each select="xsd:enumeration">
			<span class="enumValue"><xsl:value-of select="@value" /></span>
			<xsl:if test="not(position()=last())">|</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="xsd:restriction[xsd:pattern]">
		<span class="typeref">/</span>
		<span class="enumValue"><xsl:value-of select="xsd:pattern/@value" /></span>
		<span class="typeref">/</span>
	</xsl:template>

	<xsl:template match="xsd:restriction[xsd:length]">
		<span class="typeref"><xsl:value-of select="@base" />{</span>
		<span class="enumValue"><xsl:value-of select="xsd:length/@value" /></span>
		<span class="typeref">}</span>
	</xsl:template>


	<xsl:template match="xsd:attribute[@type]">
		<xsl:text> </xsl:text>
		<span class="attribute">
			<xsl:value-of select="@name" />
			<xsl:text>=&quot;</xsl:text>
			<span class="typeref"><xsl:apply-templates select="(@type[not(../@fixed)] | @fixed)[1]" /></span>
			<xsl:text>&quot;</xsl:text>
		</span>
	</xsl:template>

	<xsl:template match="xsd:documentation">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="xhtml:p">
		<p class="documentation">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="xhtml:*">
		<xsl:element name="{local-name()}"><xsl:apply-templates /></xsl:element>
	</xsl:template>

	<xsl:template match="@type">
		<xsl:variable name="typeName" select="." />
		<xsl:choose>
			<xsl:when test="$xsdPrefix != '' and starts-with(., $xsdPrefix)"><xsl:value-of select="concat($xsdOutputPrefix, substring-after(., $xsdPrefix))" /></xsl:when>
			<xsl:when test="/xsd:schema/xsd:simpleType[@name = $typeName]">
				<xsl:apply-templates select="/xsd:schema/xsd:simpleType[@name = $typeName]" />
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- Callable templates -->
	<xsl:template name="cardinality">
		<xsl:if test="@minOccurs or @maxOccurs">
			<xsl:choose>
				<xsl:when test="@minOccurs = 0 and @maxOccurs = 'unbounded'"><b class="cardinality">*</b></xsl:when>
				<xsl:when test="@minOccurs = 0 and (@maxOccurs = 1 or not(@maxOccurs))"><b class="cardinality">?</b></xsl:when>
				<xsl:when test="@minOccurs = 1 and @maxOccurs = 1"></xsl:when>
				<xsl:when test="(@minOccurs = 1 or not(@minOccurs)) and @maxOccurs = 'unbounded'"><b class="cardinality">+</b></xsl:when>
				<xsl:otherwise><xsl:value-of select="concat('{', @minOccurs, '-', @maxOccurs, '}')" /></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
