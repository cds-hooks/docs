<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Spits out a data file containing information about each resource for use in rendering resource pages
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://hl7.org/fhir" xmlns="http://hl7.org/fhir" exclude-result-prefixes="f">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:variable name="baseUrl" select="substring-before(/f:ImplementationGuide/f:url/@value, 'ImplementationGuide')"/>
  <xsl:template match="/f:ImplementationGuide">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates select="f:definition/f:resource"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="@*|node()"/>
  <xsl:template match="f:definition/f:resource">
    <xsl:variable name="type" select="substring-before(f:reference/f:reference/@value, '/')"/>
    <xsl:variable name="id" select="f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-page']/f:valueUri/@value"/>
    <xsl:if test="position()!=1">,</xsl:if>
    <xsl:value-of select="concat('&quot;', $id, '&quot;:{&quot;type&quot;:&quot;', $type, '&quot;')"/>
    <xsl:if test="f:exampleBoolean/@value='true' or f:exampleCanonical">
      <xsl:text>,"example":true</xsl:text>
    </xsl:if>
    <xsl:for-each select="f:exampleCanonical">
      <xsl:variable name="refId" select="substring-after(@value, $baseUrl)"/>
      <xsl:for-each select="ancestor::f:ImplementationGuide/f:definition/f:resource[f:reference/f:reference/@value=$refId]">
        <xsl:variable name="page" select="f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-page']/f:valueUri/@value"/>
        <xsl:value-of select="concat(',&quot;exampleOf&quot;:{&quot;name&quot;:&quot;', f:name/@value, '&quot;,&quot;url&quot;:&quot;', $page, '&quot;}')"/>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
  </xsl:template>
</xsl:stylesheet>  