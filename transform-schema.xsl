<?xml version="1.0" encoding="UTF-8"?>
<!--
  Note: This is not being used - can't remember where I got it from
        but I tried it and wasn't happy with the output so started my own
        transform (i.e., `namespace-transform.xsl`).
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:frm="http://www.w3.org/TR/xforms"
	exclude-result-prefixes="xsl xsd">
<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" />

	<xsl:param name="targetNUN" select="'element::hyperlinks'"/>
	
<xsl:template match="xsd:schema">
  <xsl:variable name="NUNModified" select="concat($targetNUN,'/')"/>
  <xsl:variable name="NUNToken" 
       select="substring-after(substring-before($NUNModified,'/'),'element::')"/>
  <xsl:apply-templates select="xsd:element[@name=$NUNToken]">
    <xsl:with-param name="NUNRemain" select="substring-after($NUNModified,'/')"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:element[@name]">
  <xsl:param name="NUNRemain"/>
  <xsl:choose>
    <xsl:when test="string-length($NUNRemain)=0">
      <xsl:apply-templates select="." mode="targetElementForm"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="xsd:complexType/*">
        <xsl:with-param name="NUNRemainder" 
                        select="substring-after($NUNRemain,'/')"/>
        <xsl:with-param name="NUNToken" 
             select="substring-after(substring-before($NUNRemain,'/')
                     ,'element::')"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>	

<xsl:template match="xsd:sequence|xsd:choice|xsd:all">
  <xsl:param name="NUNRemain"/>
  <xsl:param name="NUNToken"/>
  <xsl:apply-templates 
       select="xsd:sequence|xsd:choice|xsd:all|xsd:element[@name=$NUNToken]">
    <xsl:with-param name="NUNRemain" select="$NUNRemain"/>
    <xsl:with-param name="NUNToken" select="$NUNToken"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*"/>

<xsl:template match="xsd:element[@name]" mode="targetElementForm">
  <b>New <xsl:value-of select="xsd:annotation/xsd:appinfo/frm:label"/></b><br/>
  <xsl:copy-of select="xsd:annotation/xsd:documentation/node()"/>

  <form>
    <input type="hidden" name="%%elementNUN" 
     value="{/xsd:schema/@targetNamespace}#{$targetNUN}"/>
    <table>
      <xsl:apply-templates select="*|/xsd:schema/xsd:complexType[@name=current()/@type]"
                           mode="findChildNodes"/>
      <tr><td colspan="2">
        <input type="submit" value="Save Changes"/>
      </td></tr>
    </table>
  </form>
</xsl:template>

<xsl:template match="*" mode="targetElement"/>

<xsl:template match="xsd:complexType|xsd:complexContent|
                     xsd:sequence|xsd:all|xsd:group[@name]"
              mode="findChildNodes">
  <xsl:apply-templates select="*" mode="findChildNodes"/>
</xsl:template>

<xsl:template match="xsd:group[@ref]" mode="findChildNodes">
  <xsl:apply-templates select="/xsd:schema/xsd:group[@name=current()/@ref]" 
                       mode="findChildNodes"/>
</xsl:template>

<xsl:template match="xsd:element[@ref]" mode="findChildNodes">
  <xsl:apply-templates select="/xsd:schema/xsd:element[@name=current()/@ref]" 
                       mode="findChildNodes"/>
</xsl:template>

<xsl:template match="xsd:extension" mode="findChildNodes">
  <xsl:apply-templates select="/xsd:schema/xsd:complexType[@name=current()/@base]" 
                       mode="findChildNodes"/>
  <xsl:apply-templates select="*" mode="findChildNodes"/>
</xsl:template>

<xsl:template match="xsd:element[@name]" mode="findChildNodes">
  <xsl:if test="not(xsd:complexType|
                /xsd:schema/xsd:complexType[@name=current()/@type]|
                xsd:annotation/xsd:appinfo/frm:readonly)">

    <tr>
      <td>
        <xsl:choose>
          <xsl:when test="xsd:annotation/xsd:appinfo/frm:label">	
            <xsl:value-of select="xsd:annotation/xsd:appinfo/frm:label"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@name"/>
          </xsl:otherwise>	
        </xsl:choose>

      </td>
      <td>
        <xsl:apply-templates select="." mode="childNodeInput">
          <xsl:with-param name="nodeName" select="@name"/>
        </xsl:apply-templates>

      </td>
    </tr>

  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="findChildNodes"/>

<xsl:template match="xsd:element[@type]" mode="childNodeInput" priority="0">
  <xsl:param name="nodeName"/>
  <xsl:param name="nodeValue" select="@default"/>
  <xsl:apply-templates 
       select="/xsd:schema/xsd:simpleType[@name=current()/@type]/xsd:restriction"
       mode="childNodeInput">
    <xsl:with-param name="nodeName" select="$nodeName"/>
    <xsl:with-param name="nodeValue" select="$nodeValue"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:element[xsd:simpleType]" mode="childNodeInput">
  <xsl:param name="nodeName"/>
  <xsl:param name="nodeValue" select="@default"/>
   <xsl:apply-templates select="xsd:simpleType/xsd:restriction" mode="childNodeInput">
    <xsl:with-param name="nodeName" select="$nodeName"/>
    <xsl:with-param name="nodeValue" select="$nodeValue"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:element[@type='xsd:string']|xsd:restriction[@base='xsd:string']"
              mode="childNodeInput">
  <xsl:param name="nodeName"/>
  <xsl:param name="nodeValue" select="@default"/>
    <xsl:choose>
      <xsl:when test="xsd:maxLength">
        <input type="text" name="{$nodeName}" value="{$nodeValue}">
          <xsl:apply-templates select="*" mode="childNodeInput"/>
        </input>					
      </xsl:when>
      <xsl:otherwise>
        <textArea name="{$nodeName}">
          <xsl:apply-templates select="*" mode="childNodeInput"/>
          <xsl:value-of select="$nodeValue"/>
        </textArea>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>	

<xsl:template match="xsd:element[@type='xsd:boolean']|xsd:restriction[@base='xsd:boolean']"
              mode="childNodeInput">
  <xsl:param name="nodeName"/>
  <xsl:param name="nodeValue" select="@default"/>
  <input type="radio" name="{$nodeName}" value="true">
    <xsl:if test="$nodeValue='true'">
      <xsl:attribute name="checked">checked</xsl:attribute>
    </xsl:if>
    Yes
  </input>
  <input type="radio" name="{$nodeName}" value="false">
    <xsl:if test="$nodeValue='false'">
      <xsl:attribute name="checked">checked</xsl:attribute>
    </xsl:if>
    No
  </input>
</xsl:template>

<xsl:template match="xsd:maxLength" mode="childNodeInput">
  <xsl:attribute name="maxLength">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="xsd:pattern" mode="childNodeInput">
  <xsl:attribute name="validationRegExp">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>


<xsl:template match="xsd:restriction[xsd:enumeration]" mode="childNodeInput" 
              priority="1">
  <xsl:param name="nodeName"/>
  <xsl:param name="nodeValue"/>
  <select name="{$nodeName}">
    <xsl:apply-templates select="*" mode="childNodeInput">
      <xsl:with-param name="nodeValue" select="$nodeValue"/>
    </xsl:apply-templates>
  </select>
</xsl:template>

<xsl:template match="xsd:enumeration" mode="childNodeInput">
  <xsl:param name="nodeValue"/>
  <option value="{@value}">
    <xsl:if test="@value=$nodeValue">
      <xsl:attribute name="selected">
        selected
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="xsd:annotation/xsd:documentation">
        <xsl:value-of select="xsd:annotation/xsd:documentation"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@value"/>
      </xsl:otherwise>
    </xsl:choose>
  </option>
</xsl:template>

<xsl:template match="*" mode="childNodeInput"/>


</xsl:stylesheet>
