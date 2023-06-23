<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Convert packagelist list of packages into XML so they can be used in the generation of default Jira file
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:template match="/json">
    <package-list>
      <xsl:variable name="safeJson">
        <xsl:call-template name="safeJson">
          <xsl:with-param name="json" select="."/>
        </xsl:call-template>
      </xsl:variable>
      
      <xsl:variable name="list" select="substring-before(substring-after(substring-after($safeJson, '&quot;list&quot;'), '['), ']')"/>
      <xsl:call-template name="processPackage">
        <xsl:with-param name="list" select="$list"/>
      </xsl:call-template>
    </package-list>
	</xsl:template>
	<xsl:template name="processPackage">
    <xsl:param name="list"/>
    <xsl:variable name="package" select="substring-before(substring-after($list, '{'), '}')"/>
    <xsl:if test="$package!=''">
      <xsl:variable name="version" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;version&quot;'), ':'), '&quot;'), '&quot;')"/>
      <xsl:variable name="path" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;path&quot;'), ':'), '&quot;'), '&quot;')"/>
      <xsl:variable name="status" select="substring-before(substring-after(substring-after(substring-after($package, '&quot;status&quot;'), ':'), '&quot;'), '&quot;')"/>
      <package version="{$version}" path="{$path}" status="{$status}"/>
      <xsl:call-template name="processPackage">
        <xsl:with-param name="list" select="substring-after($list, '}')"/>
      </xsl:call-template>
    </xsl:if>
	</xsl:template>
	<!--
    - Looks at all text inside double-quotes and converts '[', ']', '{' and '}' into their XML escaped versions so that parsing the JSON arrays and attributes isn't messed up
    -->
	<xsl:template name="safeJson">
    <xsl:param name="json"/>
    <xsl:choose>
      <xsl:when test="contains($json, '&quot;')">
        <xsl:variable name="remainder" select="substring-after($json, '&quot;')"/>
        <xsl:variable name="quotedText">
          <xsl:call-template name="findQuotedText">
            <xsl:with-param name="text" select="$remainder"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat(substring-before($json, '&quot;'), '&quot;')"/>
        <xsl:call-template name="escapeJson">
          <xsl:with-param name="text" select="$quotedText"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
        <xsl:variable name="next" select="substring(substring-after($remainder, $quotedText),2)"/>
        <xsl:call-template name="safeJson">
          <xsl:with-param name="json" select="$next"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$json"/>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>
	<xsl:template name="findQuotedText">
    <xsl:param name="text"/>
    <xsl:if test="not(contains($text, '&quot;'))">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Unable to find closing quote in text: ', $text)"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="before" select="substring-before($text, '&quot;')"/>
    <xsl:value-of select="$before"/>
    <xsl:if test="substring($before, string-length($before))='\'">
      <xsl:text>"</xsl:text>
      <!-- 
         - The quote we found was escaped, so we need to keep looking for a non-escaped quote
         - NOTE: This won't handle something stupid like \\", but if you're trying that hard to break the parser, you deserve for stuff to blow up...
        -->
      <xsl:call-template name="findQuotedText">
        <xsl:with-param name="text" select="substring-after($text, '&quot;')"/>
      </xsl:call-template>
    </xsl:if>
	</xsl:template>
	<xsl:template name="escapeJson">
    <xsl:param name="text"/>
    <xsl:variable name="pass1">
      <xsl:call-template name="replace">
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="find">{</xsl:with-param>
        <xsl:with-param name="replace">&amp;x7B;</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pass2">
      <xsl:call-template name="replace">
        <xsl:with-param name="text" select="$pass1"/>
        <xsl:with-param name="find">}</xsl:with-param>
        <xsl:with-param name="replace">&amp;x7D;</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pass3">
      <xsl:call-template name="replace">
        <xsl:with-param name="text" select="$pass2"/>
        <xsl:with-param name="find">[</xsl:with-param>
        <xsl:with-param name="replace">&amp;x5B;</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pass4">
      <xsl:call-template name="replace">
        <xsl:with-param name="text" select="$pass3"/>
        <xsl:with-param name="find">]</xsl:with-param>
        <xsl:with-param name="replace">&amp;x5D;</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$pass4"/>
	</xsl:template>
	<xsl:template name="replace">
    <xsl:param name="text"/>
    <xsl:param name="find"/>
    <xsl:param name="replace"/>
    <xsl:choose>
      <xsl:when test="contains($text, $find)">
        <xsl:value-of select="concat(substring-before($text, $find), $replace)"/>
        <xsl:call-template name="replace">
          <xsl:with-param name="text" select="substring-after($text, $find)"/>
          <xsl:with-param name="find" select="$find"/>
          <xsl:with-param name="replace" select="$replace"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>
</xsl:stylesheet>
