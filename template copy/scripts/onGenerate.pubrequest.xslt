<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Convert publication-request list of packages into XML so they can be used in the generation of default Jira file
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:template match="/json">
    <publication-request>
      <xsl:call-template name="processPackage">
        <xsl:with-param name="package" select="text()"/>
      </xsl:call-template>
    </publication-request>
	</xsl:template>
	<xsl:template name="processPackage">
    <xsl:param name="package"/>
    <xsl:variable name="version" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;version&quot;'), ':'), '&quot;'), '&quot;')"/>
    <xsl:variable name="path" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;path&quot;'), ':'), '&quot;'), '&quot;')"/>
    <xsl:variable name="status" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;status&quot;'), ':'), '&quot;'), '&quot;')"/>
    <xsl:variable name="ci-build" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;ci-build&quot;'), ':'), '&quot;'), '&quot;')"/>
    <package version="{$version}" path="{$path}" status="{$status}" ci-build="{$ci-build}"/>
	</xsl:template>
</xsl:stylesheet>
