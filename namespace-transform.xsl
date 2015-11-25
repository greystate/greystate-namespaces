<?xml version="1.0" encoding="iso-8859-1"?>
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
	exclude-result-prefixes="xsl xsd xhtml"
>
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" />

<!-- Parameters -->
	<xsl:param name="namespace" />
	<xsl:param name="currentYear" select="'2009'" />

<!-- Variables -->
	<xsl:variable name="serverName">http://xmlns.greystate.dk</xsl:variable>
	<xsl:variable name="schemaServer" select="concat($serverName, '/')" />

	<xsl:variable name="schemaElement" select="document(substring-after(/namespaces/namespace[@url = $namespace]/schemaLocation, $schemaServer))/xsd:schema" />

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

	<xsl:template match="namespaces">
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
						<xsl:apply-templates select="namespace" mode="toc-mode">
							<xsl:sort select="substring-before(substring-after(@url, concat($serverName, '/')), '/')" data-type="number" order="descending" />
						</xsl:apply-templates>
					</ul>
				</dd>
			</dl>
		</xsl:if>
		<xsl:apply-templates select="namespace[@url = $namespace]" />
		<div id="footer">
			<address>
				Copyright &#169;2002&#8212;<xsl:value-of select="$currentYear" /> by Chriztian Steinmeier.
			</address>
		</div>
	</xsl:template>

	<xsl:template match="namespace">
    	<h2>{<code><xsl:value-of select="@url" /></code>}</h2>
		<dl>
			<dt>Description</dt>
			<dd>
				<xsl:apply-templates select="$schemaElement/xsd:annotation" />
			</dd>

			<dt>XMLSchema</dt>
			<dd>
				<p>
					<xsl:apply-templates select="schemaLocation" />
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
	
	<xsl:template match="namespace" mode="toc-mode">
		<li><a href="{substring-after(@url, $serverName)}"><xsl:value-of select="@url" /></a></li>
	</xsl:template>

	<xsl:template match="schemaLocation">
    	<a href="{.}" target="_blank" title="Open schema in new browser"><xsl:value-of select="." /></a>
    </xsl:template>

<!-- XMLSchema templates -->
	<xsl:template match="xsd:schema">
    	<xsl:apply-templates select="xsd:element | xsd:include" />
    </xsl:template>

	<xsl:template match="xsd:include">
    	<xsl:apply-templates select="document(@schemaLocation)/xsd:schema" />
    </xsl:template>

	<xsl:template match="xsd:element//xsd:attribute">
    	<xsl:choose>
			<xsl:when test="@ref">
				<span class="attribute">
					<xsl:value-of select="@ref" />=&quot;<xsl:apply-templates select="//xsd:attribute[@name = current()/@ref]"/>&quot;
				</span>
			</xsl:when>
			<xsl:otherwise>
				<span class="attribute">
					<xsl:value-of select="@name" />=&quot;<xsl:apply-templates />&quot;
				</span>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>

	<xsl:template match="xsd:element[@name]">
    	<div class="elementwrapper">
			<code>&lt;<span class="element"><xsl:value-of select="@name" /></span> <xsl:apply-templates select=".//xsd:attribute" /> /&gt;</code>
			<xsl:apply-templates select="xsd:simpleType | xsd:complexType | xsd:key | xsd:keyref | xsd:unique" />
			<xsl:if test="@type"> <code><xsl:attribute name="class">typeref<xsl:if test="starts-with(@type, $xsdPrefix)"> xsdtype</xsl:if></xsl:attribute><xsl:apply-templates select="@type" /></code></xsl:if>
			<xsl:apply-templates select="xsd:annotation" />
		</div>
    </xsl:template>

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

	<xsl:template match="xsd:attribute/xsd:simpleType/xsd:restriction[@base='xsd:string'][xsd:enumeration]"><xsl:for-each select="xsd:enumeration"><span class="enumValue"><xsl:value-of select="@value" /></span><xsl:if test="not(position()=last())">|</xsl:if></xsl:for-each></xsl:template>
	<xsl:template match="xsd:attribute[@type]">
		<span class="attribute"><xsl:value-of select="@name" />=&quot;<span class="typeref"><xsl:apply-templates select="@type" /></span>&quot;</span>
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
		<xsl:choose>
			<xsl:when test="$xsdPrefix != '' and starts-with(., $xsdPrefix)"><xsl:value-of select="concat($xsdOutputPrefix, substring-after(., $xsdPrefix))" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- Callable templates -->
	<xsl:template name="cardinality">
    	<xsl:if test="@minOccurs or @maxOccurs">
			<xsl:choose>
	            <xsl:when test="@minOccurs = 0 and @maxOccurs = 'unbounded'"><b class="cardinality">*</b></xsl:when>
	            <xsl:when test="@minOccurs = 0 and @maxOccurs = 1"><b class="cardinality">?</b></xsl:when>
				<xsl:when test="@minOccurs = 1 and @maxOccurs = 1"></xsl:when>
				<xsl:when test="@minOccurs = 1 and @maxOccurs = 'unbounded'"><b class="cardinality">+</b></xsl:when>
				<xsl:otherwise><xsl:value-of select="concat('{', @minOccurs, '-', @maxOccurs, '}')" /></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>
