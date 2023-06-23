<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This is a cleanup script that does a few things:
  - - ensures that the 'root' page is the generated "toc.xml" page
  - - ensures that somewhere in the list of pages is the generated "artifacts.xml" page
  - - places a list of all artifacts (ordered by order of table of contents) as pages beneath artifacts.xml
  - - strips the igpublisher-spreadsheet extensions, if any
  - If dealing with a multi-version IG, it will be run against both IG versions.
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://hl7.org/fhir" exclude-result-prefixes="html f">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:variable name="noRootToc" select="/f:ImplementationGuide/f:definition/f:parameter[f:code/@value='noRootToc']/f:value/@value"/>
  <xsl:variable name="artifactsOnRoot" select="/f:ImplementationGuide/f:definition/f:parameter[f:code/@value='artifactsOnRoot']/f:value/@value"/>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="f:extension[@url='http://hl7.org/fhir/StructureDefinition/igpublisher-spreadsheet']"/>
  <xsl:template match="f:grouping">
    <xsl:if test="parent::f:definition/f:resource/f:groupingId[@value=current()/@id]">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="f:definition">
    <!-- If we've defined the groups, then we sort based on the groups, then alphabetically -->
    <xsl:choose>
      <xsl:when test="f:group[starts-with(@id, '-')]">
        <xsl:copy>
          <xsl:apply-templates select="@*|f:extension|f:modifierExtension|f:grouping|comment()[not(preceding-sibling::f:resource)]"/>
          <xsl:for-each select="f:grouping">
            <xsl:choose>
              <xsl:when test="starts-with(@id, '-')">
                <xsl:for-each select="parent::f:definition/f:resource[f:groupingId/@value=current()/@id]">
                  <xsl:sort select="f:name/@value"/>
                  <xsl:sort select="f:reference/f:reference/@value"/>
                  <xsl:apply-templates select="."/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="parent::f:definition/f:resource[f:groupingId/@value=current()/@id]">
                  <xsl:apply-templates select="."/>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="f:ImplementationGuide/f:definition/f:page">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$noRootToc='true' or (f:nameUrl/@value='toc.html' and f:generation/@value='html')">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:when>
        <xsl:otherwise>
          <nameUrl xmlns="http://hl7.org/fhir" value="toc.html"/>
          <title xmlns="http://hl7.org/fhir" value="Table of Contents"/>
          <generation xmlns="http://hl7.org/fhir" value="html"/>
          <page xmlns="http://hl7.org/fhir">
            <xsl:apply-templates select="@*|node()[not(self::f:page)]"/>
          </page>
          <xsl:apply-templates select="f:page"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$artifactsOnRoot='true'">
          <xsl:call-template name="artifactPages"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not(descendant-or-self::f:page[f:nameUrl/@value='artifacts.html'])">
            <page xmlns="http://hl7.org/fhir">
              <nameUrl value="artifacts.html"/>
              <title value="Artifacts Summary"/>
              <generation value="html"/>
              <xsl:call-template name="artifactPages"/>
            </page>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:copy>
  </xsl:template>
  <xsl:template match="f:page[f:nameUrl/@value='artifacts.html']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:if test="not($artifactsOnRoot='true')">
        <xsl:call-template name="artifactPages"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <xsl:template name="artifactPages">
    <xsl:for-each select="/f:ImplementationGuide/f:definition/f:grouping">
      <xsl:for-each select="parent::f:definition/f:resource[f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-page']][f:groupingId/@value=current()/@id]">
        <xsl:variable name="id" select="substring-after(f:reference/f:reference/@value, '/')"/>
        <page xmlns="http://hl7.org/fhir">
          <nameUrl value="{f:extension[@url='http://hl7.org/fhir/StructureDefinition/implementationguide-page']/f:valueUri/@value}"/>
          <title value="{f:name/@value}"/>
          <generation value="generated"/>
          <xsl:for-each select="f:extension[@url='http://hl7.org/fhir/tools/StructureDefinition/contained-resource-information']">
            <page xmlns="http://hl7.org/fhir">
              <xsl:variable name="url" select="concat(f:extension[@url='type']/f:valueCode/@value, '-', $id, '_', f:extension[@url='id']/f:valueId/@value, '.html')"/>
              <nameUrl value="{$url}"/>
              <xsl:for-each select="f:extension[@url='title']/f:valueString">
                <title value="{@value}"/>
              </xsl:for-each>
              <generation value="generated"/>
            </page>
          </xsl:for-each>
        </page>      
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>  