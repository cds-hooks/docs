<?xml version="1.0" encoding="UTF-8"?>
<!--
  - A helper-transform that supports reporting issues.
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://hl7.org/fhir" xmlns="http://hl7.org/fhir" exclude-result-prefixes="f">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:template name="raiseError">
    <xsl:param name="code"/>
    <xsl:param name="details"/>
    <xsl:param name="location"/>
    <xsl:call-template name="raiseIssue">
      <xsl:with-param name="severity">error</xsl:with-param>
      <xsl:with-param name="code" select="$code"/>
      <xsl:with-param name="details" select="$details"/>
      <xsl:with-param name="location" select="$location"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="raiseWarning">
    <xsl:param name="code"/>
    <xsl:param name="details"/>
    <xsl:param name="location"/>
    <xsl:call-template name="raiseIssue">
      <xsl:with-param name="severity">warning</xsl:with-param>
      <xsl:with-param name="code" select="$code"/>
      <xsl:with-param name="details" select="$details"/>
      <xsl:with-param name="location" select="$location"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="raiseIssue">
    <xsl:param name="severity"/>
    <xsl:param name="code"/>
    <xsl:param name="details"/>
    <xsl:param name="location"/>
    <xsl:text>&#xa;{"severity":"</xsl:text>
    <xsl:value-of select="$severity"/>
    <xsl:text>","code":"</xsl:text>
    <xsl:value-of select="$code"/>
    <xsl:text>","details":{"text":"</xsl:text>
    <xsl:value-of select="$details"/>
    <xsl:text>"},"location":["</xsl:text>
    <xsl:value-of select="$location"/>
    <xsl:text>"]}&#xa;,</xsl:text>
  </xsl:template>
</xsl:stylesheet>  