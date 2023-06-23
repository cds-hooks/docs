<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This normalizes XML such that attribute order and whitespace are rendered consistently
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:template match="specification" priority="10">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:sort select="local-name(.)"/>
        <xsl:if test="local-name(.)=name(.)">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>&#xa;</xsl:text>
      <xsl:apply-templates select="version"/>
      <xsl:for-each select="artifactPageExtension">
        <xsl:sort select="@value"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
      <xsl:for-each select="artifact">
        <xsl:sort select="@name"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
      <xsl:for-each select="page">      
        <xsl:sort select="@name"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:copy>
	</xsl:template>
	<xsl:template match="/">
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="node()"/>
	</xsl:template>
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
	<xsl:template match="*" priority="5">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:sort select="local-name(.)"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
    <xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="text()[normalize-space(.)='']"/>
</xsl:stylesheet>
