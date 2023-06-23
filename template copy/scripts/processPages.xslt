<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This process turns XHTML into simple HTML, ensures anchors defining names have end tags and creates section labels and links on all sections
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="svg xsi xs html">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/">
    <xsl:if test="not(html:* or svg:*)">
      <xsl:message terminate="yes">Only XHTML-namespaced content is permitted</xsl:message>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <xsl:template match="comment()[normalize-space(translate(., 'DRAFT','draft'))='draft']">
    <blockquote class="stu-note">
      <table>
        <tbody>
          <tr>
            <td>
              <img src="work-98936_640.png" alt="Work in Progress icon" height="30" width="30"/>
            </td>
            <td>The content in this section has not undergone work group review and may be significantly revised prior to the next ballot.</td>
          </tr>
        </tbody>
      </table>
    </blockquote>
  </xsl:template>
  <xsl:template match="@xsi:schemaLocation"/>
  <xsl:template priority="10" match="/html:div">
    <div>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="count(html:h3)>1">
        <div class="markdown-toc">
          <p>Contents:</p>
          <ul>
            <xsl:for-each select="html:h3">
              <li>
                <xsl:variable name="hierarchy">
                  <xsl:apply-templates mode="findHierarchy" select="."/>
                </xsl:variable>
                <xsl:variable name="link">
                  <xsl:choose>
                    <xsl:when test="preceding-sibling::*[1][self::html:a[@name]]">
                      <xsl:value-of select="preceding-sibling::*[1]/@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$hierarchy"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <a href="#{$link}">
                  <xsl:value-of select="."/>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </div>
  </xsl:template>
  <xsl:template priority="5" match="*">
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template priority="10" match="html:a[@name]">
    <a>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:text>&#x20;</xsl:text>
    </a>
  </xsl:template>
  <xsl:template priority="10" match="html:h1|html:h2">
    <xsl:message terminate="yes">"h1" and "h2" elements are not permitted</xsl:message>
  </xsl:template>
  <xsl:template priority="10" match="html:h3|html:h4|html:h5">
    <xsl:variable name="hierarchy">
      <xsl:apply-templates mode="findHierarchy" select="."/>
    </xsl:variable>
    <xsl:variable name="link">
      <xsl:choose>
        <xsl:when test="preceding-sibling::*[1][self::html:a[@name]]">
          <xsl:value-of select="preceding-sibling::*[1]/@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:value-of select="concat('No permalink anchor for heading ', local-name(.), ' - ', .)"/>
          </xsl:message>
          <xsl:value-of select="$hierarchy"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not(preceding-sibling::*[1][self::html:a[@name]])">
      <a name="{$hierarchy}">&#x20;</a>
    </xsl:if>
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template mode="findHierarchy" match="html:h2|html:h3|html:h4|html:h5">
    <xsl:param name="hierarchyString" select="''"/>
    <xsl:param name="prevLevelCount" select="0"/>
    <xsl:param name="prevLevel" select="floor(number(substring(local-name(.), 2)))"/>
    <xsl:variable name="level" select="floor(number(substring(local-name(.), 2)))"/>
    <xsl:variable name="levelCount">
      <xsl:choose>
        <xsl:when test="$prevLevel = $level">
          <xsl:value-of select="$prevLevelCount + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$prevLevelCount"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="newHierarchyString">
      <xsl:choose>
        <xsl:when test="$hierarchyString!=''">
          <xsl:value-of select="concat($levelCount, '.', $hierarchyString)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$levelCount"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(preceding::*[self::html:h1 or self::html:h2 or self::html:h3 or self::html:h4 or self::html:h5])!=0">
        <xsl:choose>
          <xsl:when test="$level&lt;$prevLevel">
            <xsl:apply-templates mode="findHierarchy" select="preceding::*[self::html:h1 or self::html:h2 or self::html:h3 or self::html:h4 or self::html:h5][1]">
              <xsl:with-param name="hierarchyString" select="$newHierarchyString"/>
              <xsl:with-param name="prevLevelCount" select="1"/>
              <xsl:with-param name="prevLevel" select="$level"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="findHierarchy" select="preceding::*[self::html:h1 or self::html:h2 or self::html:h3 or self::html:h4 or self::html:h5][1]">
              <xsl:with-param name="hierarchyString" select="$hierarchyString"/>
              <xsl:with-param name="prevLevelCount" select="$levelCount"/>
              <xsl:with-param name="prevLevel" select="$prevLevel"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$newHierarchyString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
</xsl:stylesheet>
