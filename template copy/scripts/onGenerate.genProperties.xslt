<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Extract the organization, family, realm and id from the IG's id.  Expectation is that the id will be in the form:
  -   hl7.[family].[realm].id or hl7.[family].id (presumed universal)
  - Holler if realm isn't valid or family isn't valid
  - finally, spit out the 'artifact' code based on the IG (FAMILY-us-[id] or FAMILY-[id]) as a property named jiraSpecFile
  - which will be used to name the Jira Spec file proposed as a default
  -->
<xsl:stylesheet version="1.0" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="f:ImplementationGuide">
    <xsl:variable name="id" select="f:id/@value"/>
    <xsl:variable name="org" select="substring-before($id, '.')"/>
    <xsl:variable name="family" select="substring-before(substring-after($id, '.'), '.')"/>
    <xsl:variable name="realm">
      <xsl:choose>
        <xsl:when test="$id='hl7.fhir.cda' or $id='hl7.fhir.v2'">
          <xsl:text>uv</xsl:text>
        </xsl:when>
        <xsl:when test="contains(substring-after($id, concat($family, '.')), '.')">
          <xsl:value-of select="substring-before(substring-after($id, concat($family, '.')), '.')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="code">
      <xsl:choose>
        <xsl:when test="$id='hl7.fhir.cda' or $id='hl7.fhir.v2'">
          <xsl:value-of select="substring-after($id, 'hl7.fhir.')"/>
        </xsl:when>
        <xsl:when test="f:definition/f:parameter[f:code/@value='jira-code']">
          <xsl:value-of select="f:definition/f:parameter[f:code/@value='jira-code']/f:value/@value"/>
        </xsl:when>
        <xsl:when test="$realm!=''">
          <xsl:value-of select="substring-after($id, concat($realm, '.'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($id, concat($family, '.'))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not($org='hl7')">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('When using the HL7 template, the IG id must start with &quot;hl7.&quot; - found ', $id)"/>
      </xsl:message>
    </xsl:if>
    <xsl:if test="not($family='cda' or $family='fhir' or $family='v2' or $family='xprod' or $family='other')">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Unrecognized family in id: ', $id, '.  ImplementationGuide.id must be in the form &quot;', 'hl7.[family].[realm].id', '&quot; where family is cda, fhir, v2, xprod, or other')"/>
      </xsl:message>
    </xsl:if>
    <xsl:if test="not($realm='us' or $realm='uv')">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Unrecognized realm in id: ', $id, '.  ImplementationGuide.id must be in the form &quot;', 'hl7.[family].[realm].id', '&quot; where realm is uv or us.')"/>
      </xsl:message>
    </xsl:if>
    <xsl:text>jiraSpecFile:</xsl:text>
    <xsl:value-of select="translate($family, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
    <xsl:choose>
      <xsl:when test="$realm='us'">-us-</xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$code"/>
    <xsl:value-of select="concat('&#x0a;packagelisturl:', substring-before(f:url/@value, 'ImplementationGuide'), 'package-list.json')"/>
  </xsl:template>
</xsl:stylesheet>
