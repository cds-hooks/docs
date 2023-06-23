<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This process runs a QA check on the final IG, ensuring that elements required for publication are properly populated
  -
  - NOTE: UTG suppresses this because at the moment, all it does is checks related to the artifacts.html page, which UTG doesn't use.  If we change the template to extend this, we'll
  -       need to refactor to allow UTG to enable only the relevant validation.
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://hl7.org/fhir" xmlns="http://hl7.org/fhir" exclude-result-prefixes="f">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:include href="handleIssues.xslt"/>
  <xsl:template match="/f:ImplementationGuide">
    <xsl:apply-templates select="f:definition/f:resource"/>
  </xsl:template>
  <xsl:template match="@*|node()"/>
  <xsl:template match="f:definition/f:resource[f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-page']]">
    <xsl:if test="not(f:name)">
      <xsl:call-template name="raiseIssue">
        <xsl:with-param name="severity">error</xsl:with-param>
        <xsl:with-param name="code">required</xsl:with-param>
        <xsl:with-param name="details" select="concat('Unable to find ImplementationGuide.definition.resource.name for the resource ', f:reference/f:reference/@value, '.  Name is mandatory if it cannot be inferred from the resource to allow proper population of the artifact list.')"/>
        <xsl:with-param name="location" select="concat('ImplementationGuide.definition.resource[', count(preceding::f:resource), ']')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(f:description)">
      <xsl:call-template name="raiseIssue">
        <xsl:with-param name="severity">warning</xsl:with-param>
        <xsl:with-param name="code">invariant</xsl:with-param>
        <xsl:with-param name="details" select="concat('Unable to find ImplementationGuide.definition.resource.description for the resource ', f:reference/f:reference/@value, '.  Descriptions are strongly encouraged if they cannot be inferred from the resource to allow proper population of the artifact list.')"/>
        <xsl:with-param name="location" select="concat('ImplementationGuide.definition.resource[', count(preceding::f:resource), ']')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>  