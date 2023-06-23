<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Merge the package information from the publication-request and the package-list (allowing for the possibility that one or the other might not exist
  -->
<xsl:stylesheet version="1.0" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="f">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="root">
    <xsl:copy>
      <xsl:apply-templates select="*[not(self::publication-request or self::package-list)]"/>
      <package-list>
        <xsl:choose>
          <xsl:when test="not(package-list) and not(publication-request)">
            <package version="current" path="" status="ci-build"/>
          </xsl:when>
          <xsl:when test="not(package-list)">
            <xsl:for-each select="publication-request">
              <package version="current" path="{package/@ci-build}" status="ci-build"/>
              <xsl:for-each select="package">
                <xsl:copy>
                  <xsl:copy-of select="@*[not(local-name(.)='ci-build')]"/>
                </xsl:copy>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="pub-version" select="publication-request/package/@version"/>
            <xsl:for-each select="package-list">
              <xsl:apply-templates select="package[@version='current']"/>
              <xsl:if test="$pub-version!='' and not(package[@version=$pub-version])">
                <xsl:apply-templates select="parent::*/publication-request/package"/>
              </xsl:if>
              <xsl:apply-templates select="package[not(@version='current')]"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </package-list>
    </xsl:copy>
	</xsl:template>
	<xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template match="package-list">
    <xsl:copy>
    </xsl:copy>
	</xsl:template>
</xsl:stylesheet>
