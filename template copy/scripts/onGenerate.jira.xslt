<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Generate a default Jira-Spec-Artifacts XML file for this IG that can be used by Jira to provide the appropriate drop-downs for this IG
  -->
<xsl:stylesheet version="1.0" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="f exsl">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="committeePageBase" select="'hl7.org/Special/committees/'"/>
	<xsl:template match="/">
    <xsl:apply-templates select="/root/f:ImplementationGuide"/>
	</xsl:template>
	<xsl:template match="/root/f:ImplementationGuide">
    <xsl:variable name="url" select="substring-before(f:url/@value, '/ImplementationGuide')"/>
    <xsl:variable name="id" select="substring-after(substring-after(f:id/@value, 'hl7.fhir.'), '.')"/>
    <xsl:variable name="ciUrl" select="/root/package-list/package[@status='ci-build']/@path"/>
    <xsl:if test="$ciUrl='' and root/package-list">
      <xsl:message terminate="yes">Unable to find 'ci-build' release listed in package-list</xsl:message>
    </xsl:if>
    <xsl:variable name="wgUrl" select="f:contact/f:telecom[f:system/@value='url'][1]/f:value/@value"/>
    <xsl:if test="not(contains($wgUrl, $committeePageBase))">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('First &quot;url&quot; contact telecom must start with &quot;http://', $committeePageBase, '&quot;')"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="wgTail" select="substring-after($wgUrl, $committeePageBase)"/>
    <xsl:variable name="wgWebCode">
      <xsl:choose>
        <xsl:when test="contains($wgTail, '/index.cfm')">
          <xsl:value-of select="normalize-space(substring-before($wgTail, '/index.cfm'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($wgTail)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="wg" select="/root/workgroups/workgroup[@webcode=$wgWebCode]/@key"/>
    <xsl:if test="$wg=''">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Unable to find Jira work group defined that corresponds with HL7 website http://', $committeePageBase, $wgWebCode, '.  If that URL resolves, please contact the HL7 webmaster.')"/>
      </xsl:message>
    </xsl:if>
    <xsl:for-each select="/root/package-list/package[@status='release']">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Package-list status &quot;release&quot; for release ', @version, 
          ' is not allowed for IGs using the HL7 template.  Use a more specific status (draft, informative, trial-use, normative, trial-use+normative, etc.)')"/>
      </xsl:message>
    </xsl:for-each>
    <xsl:for-each select="/root/package-list/package[not(@status='ci-build' or @status='preview' or @status='draft' or @status='ballot' or @status='informative' or @status='trial-use' or @status='update' or @status='normative' or status='trial-use+normative')]">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Unrecognized package-list status: ', @status, ' for release ', @version)"/>
      </xsl:message>
    </xsl:for-each>
    <xsl:variable name="version">
      <xsl:choose>
        <xsl:when test="/root/package-list/package[@status='trial-use' or @status='update' or @status='informative' or @status='normative' or @status='trial-use+normative']">
          <xsl:value-of select="/root/package-list/package[@status='trial-use' or @status='update' or @status='informative' or @status='normative' or @status='trial-use+normative'][1]/@version"/>
        </xsl:when>
        <xsl:when test="/root/package-list/package[@status='ballot']">
          <xsl:value-of select="/root/package-list/package[@status='ballot'][1]/@version"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/root/package-list/package[1]/@version"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="/root/f:ImplementationGuide/f:definition/f:resource">
      <xsl:variable name="normalized-name">
        <xsl:choose>
          <xsl:when test="contains(f:name/@value, '(')">
            <xsl:value-of select="normalize-space(substring-before(f:name/@value, '('))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(f:name/@value)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="preceding-sibling::f:resource[f:name/@value=$normalized-name or normalize-space(substring-before(f:name/@value, '('))=$normalized-name]">
        <xsl:message>
          <xsl:value-of select="concat('**WARNING** Jira file generation will not be correct because multiple artifacts have the same name (ignoring content in &quot;()&quot;): ', $normalized-name)"/>
        </xsl:message>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="not(/root/package-list/package[@version=$version])">
      <xsl:message>
        <xsl:value-of select="concat('Version specified in the IG (', $version, ') does not correspond to any of the versions listed in the package-list.json')"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="ballotUrl" select="/root/package-list/package[@status='preview' or @status='ballot'][1]/@path"/>
    <specification url="{$url}" ciUrl="{$ciUrl}" defaultWorkgroup="{$wg}" defaultVersion="{$version}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../schemas/specification.xsd">
      <xsl:copy-of select="/root/specification/@gitUrl"/>
      <xsl:if test="$ballotUrl!=''">
        <xsl:attribute name="ballotUrl">
          <xsl:value-of select="$ballotUrl"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="/root/package-list/package">
        <version code="{@version}" url="{@path}">
          <xsl:if test="((@status='preview' or @status='ballot') and preceding-sibling::package[@status='preview' or @status='ballot']) or /root/specification/version[@code=current()/@version]/@deprecated">
            <xsl:attribute name="deprecated">true</xsl:attribute>
          </xsl:if>
        </version>
      </xsl:for-each>
      <xsl:for-each select="/root/specification/version[@deprecated='true']">
        <xsl:if test="not(/root/package-list/package[@version=current()/@code])">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <artifactPageExtension value="-definitions"/>
      <artifactPageExtension value="-examples"/>
      <artifactPageExtension value="-mappings"/>
      <xsl:variable name="artifacts">
        <xsl:for-each select="/root/f:ImplementationGuide/f:definition/f:resource">
          <xsl:variable name="baseId" select="substring-after(f:reference/f:reference/@value, '/')"/>
          <xsl:variable name="artifactId" select="concat(substring-before(f:reference/f:reference/@value, '/'), '-', $baseId)"/>
          <xsl:variable name="name" select="normalize-space(f:name/@value)"/>
          <xsl:variable name="ref" select="normalize-space(f:reference/f:reference/@value)"/>
          <artifact name="{$name}" key="{$artifactId}" id="{$ref}">
            <xsl:variable name="candidates" select="/root/specification/artifact[@id=$ref or @id=$baseId or @name=$name or normalize-space(substring-before(@name, '('))=$name]"/>
            <xsl:choose>
              <xsl:when test="count(exsl:node-set($candidates))=1">
                <xsl:copy-of select="exsl:node-set($candidates)/@*[not(local-name(.)='id' or local-name(.)='name')]"/>
              </xsl:when>
              <xsl:when test="exsl:node-set($candidates)[@key=$artifactId]">
                <xsl:copy-of select="exsl:node-set($candidates)[@key=$artifactId]/@*[not(local-name(.)='id' or local-name(.)='name')]"/>
              </xsl:when>
              <xsl:when test="count(exsl:node-set($candidates))!=0">
                <xsl:message terminate="yes">
                  <xsl:value-of select="concat('Found multiple candidates for artifact ', $artifactId, ' in previous jira-spec-info')"/>
                  <xsl:copy-of select="exsl:node-set($candidates)"/>
                </xsl:message>
              </xsl:when>
            </xsl:choose>
          </artifact>
        </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="exsl:node-set($artifacts)"/>
      <xsl:for-each select="/root/specification/artifact">
        <xsl:variable name="key" select="@key"/>
        <xsl:variable name="keyName" select="@name"/>
        <xsl:variable name="found">
          <xsl:if test="exsl:node-set($artifacts)/*[@key=$key]">yes</xsl:if>
        </xsl:variable>
        <xsl:if test="$found=''">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="deprecated">true</xsl:attribute>
          </xsl:copy>
        </xsl:if>
      </xsl:for-each>
      <page name="(NA)" key="NA"/>
      <page name="(many)" key="many"/>
      <xsl:for-each select="/root/f:ImplementationGuide/f:definition//f:page[f:generation/@value[.='html' or .='markdown']]">
        <xsl:variable name="pageId" select="substring-before(f:nameUrl/@value, '.html')"/>
        <xsl:variable name="name" select="f:title/@value"/>
        <page name="{$name}" key="{$pageId}">
          <xsl:for-each select="/root/specification/page[@id=$pageId or @name=$name or normalize-space(substring-before(@name, '('))=$name]">
            <xsl:copy-of select="@*"/>
          </xsl:for-each>
        </page>
      </xsl:for-each>
      <xsl:for-each select="/root/specification/page[not(@key='NA' or @key='many')]">
        <xsl:variable name="key" select="@key"/>
        <xsl:variable name="keyName" select="@name"/>
        <xsl:variable name="found">
          <xsl:for-each select="/root/f:ImplementationGuide/f:definition//f:page[f:generation/@value[.='html' or .='markdown']]">
            <xsl:variable name="pageId" select="substring-before(f:nameUrl/@value, '.html')"/>
            <xsl:variable name="name" select="f:title/@value"/>
            <xsl:if test="$key=$pageId or $keyName=$name or normalize-space(substring-before($keyName, '('))=$name">yes</xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$found=''">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="deprecated">true</xsl:attribute>
          </xsl:copy>
        </xsl:if>
      </xsl:for-each>
    </specification>
	</xsl:template>
</xsl:stylesheet>
