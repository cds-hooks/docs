<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Updates the IG to list all found spreadsheets, sets license and fills in all of the default parameters used by this template
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://hl7.org/fhir" exclude-result-prefixes="html f">
  <xsl:param name="spreadsheetList"/>
  <xsl:variable name="autoload">
    <xsl:call-template name="getParameter">
      <xsl:with-param name="name">autoload-resources</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="addResources">
    <xsl:if test="not(/f:ImplementationGuide/f:definition/f:resource or f:ImplementationGuide/f:extension[@url=$spreadsheetExt]) or not($autoload='false')">true</xsl:if>
  </xsl:variable>
  <xsl:variable name="spreadsheetExt" select="'http://hl7.org/fhir/StructureDefinition/igpublisher-spreadsheet'"/>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="f:ImplementationGuide">
    <xsl:if test="not(f:version/@value)">
      <xsl:message terminate="yes">ImplementationGuide.version must be specified</xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*|f:id|f:meta|f:implicitRules|f:language|f:text|f:contained|f:extension"/>
      <xsl:if test="$addResources='true'">
        <xsl:call-template name="addSpreadsheets">
          <xsl:with-param name="spreadsheets" select="$spreadsheetList"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates select="f:modifierExtension"/>
      <xsl:apply-templates select="f:url|f:version|f:name|f:title|f:status|f:experimental|f:date|f:publisher|f:contact|f:description|f:useContext|f:jurisdiction|f:copyright|f:packageId|f:license"/>
      <xsl:if test="not(f:license)">
        <license xmlns="http://hl7.org/fhir" value="CC0-1.0"/>
      </xsl:if>
      <xsl:apply-templates select="f:fhirVersion|f:dependsOn|f:global|f:definition|f:manifest"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template name="addSpreadsheets">
    <xsl:param name="spreadsheets"/>
    <xsl:if test="$spreadsheets!=''">
      <xsl:variable name="spreadsheet">
        <xsl:choose>
          <xsl:when test="contains($spreadsheets, ';')">
            <xsl:value-of select="substring-before($spreadsheets, ';')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$spreadsheets"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="trimmedSpreadsheet">
        <xsl:call-template name="trimSpreadsheet">
          <xsl:with-param name="spreadsheet" select="$spreadsheet"/>
        </xsl:call-template>
      </xsl:variable>
      <extension xmlns="http://hl7.org/fhir" url="{$spreadsheetExt}">
        <valueString value="{$trimmedSpreadsheet}"/>
      </extension>
      <xsl:if test="concat($spreadsheets, ';')">
        <xsl:call-template name="addSpreadsheets">
          <xsl:with-param name="spreadsheets" select="substring-after($spreadsheets, ';')"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template name="trimSpreadsheet">
    <xsl:param name="spreadsheet"/>
    <xsl:choose>
      <xsl:when test="contains($spreadsheet, '/')">
        <xsl:call-template name="trimSpreadsheet">
          <xsl:with-param name="spreadsheet" select="substring-after($spreadsheet, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($spreadsheet, '\')">
        <xsl:call-template name="trimSpreadsheet">
          <xsl:with-param name="spreadsheet" select="substring-after($spreadsheet, '\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$spreadsheet"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="f:definition">
    <xsl:copy>
      <xsl:apply-templates select="@*|f:id|f:extension"/>
      <xsl:apply-templates mode="convertParams" select="f:parameter[f:code[not(@value='apply' or @value='path-resource' or @value='path-pages' or @value='path-tx-cache' or @value='expansion-parameter' or @value='rule-broken-links' or @value='generate-xml' 
            or @value='generate-json' or @value='generate-turtle' or @value='html-template')]]"/>
      <xsl:call-template name="addParameters">
        <xsl:with-param name="extensionMode" select="'Y'"/>
      </xsl:call-template>
      <xsl:apply-templates select="f:modifierExtension|f:grouping|f:resource|f:page|f:parameter"/>
      <xsl:call-template name="addParameters"/>
      <xsl:apply-templates select="f:template"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="convertParams" match="f:parameter[f:code/@value='find-other-resources']" priority="10"/>
  <xsl:template match="f:parameter[f:code[not(@value='apply' or @value='path-resource' or @value='path-pages' or @value='path-tx-cache' or @value='expansion-parameter' or @value='rule-broken-links' or @value='generate-xml' or @value='generate-json' 
                or @value='generate-turtle' or @value='html-template')]]"/>
  <xsl:template match="f:extension[@url='http://hl7.org/fhir/tools/StructureDefinition/ig-parameter' and f:extension[@url='code']/f:valueString/@value='find-other-resources']"/>
  <xsl:template name="addParameters">
    <xsl:param name="extensionMode"/>
    <xsl:if test="$addResources='true'">
      <xsl:call-template name="setParameter">
        <xsl:with-param name="code" select="'autoload-resources'"/>
        <xsl:with-param name="value" select="'true'"/>
        <xsl:with-param name="supplement" select="'Y'"/>
        <xsl:with-param name="extensionMode" select="$extensionMode"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/capabilities'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/examples'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/extensions'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/models'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/operations'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/profiles'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/resources'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/vocabulary'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/maps'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/testing'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'input/history'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-resource'"/>
      <xsl:with-param name="value" select="'fsh-generated/resources'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-pages'"/>
      <xsl:with-param name="value" select="'template/config'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-pages'"/>
      <xsl:with-param name="value" select="'input/images'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-liquid'"/>
      <xsl:with-param name="value" select="'template/liquid'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-liquid'"/>
      <xsl:with-param name="value" select="'input/liquid'"/>
      <xsl:with-param name="supplement" select="'Y'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-qa'"/>
      <xsl:with-param name="value" select="'temp/qa'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-temp'"/>
      <xsl:with-param name="value" select="'temp/pages'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-output'"/>
      <xsl:with-param name="value" select="'output'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-tx-cache'"/>
      <xsl:with-param name="value" select="'input-cache/txcache'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-suppressed-warnings'"/>
      <xsl:with-param name="value" select="'input/ignoreWarnings.txt'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'path-history'"/>
      <xsl:with-param name="value" select="concat(substring-before(ancestor::f:ImplementationGuide/f:url/@value, 'ImplementationGuide'), 'history.html')"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'template-html'"/>
      <xsl:with-param name="value" select="'template-page.html'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'template-md'"/>
      <xsl:with-param name="value" select="'template-page-md.html'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-contact'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-context'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-copyright'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-jurisdiction'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-license'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-publisher'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'apply-version'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'active-tables'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'fmm-definition'"/>
      <xsl:with-param name="value" select="'http://hl7.org/fhir/versions.html#maturity'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'propagate-status'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'excludelogbinaryformat'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="'tabbed-snapshots'"/>
      <xsl:with-param name="value" select="'true'"/>
      <xsl:with-param name="extensionMode" select="$extensionMode"/>
    </xsl:call-template>
  </xsl:template>
	<xsl:template name="getParameter">
	  <xsl:param name="name"/>
	  <xsl:choose>
      <xsl:when test="f:definition/f:parameter[f:code/@value=$name]">
        <xsl:value-of select="f:definition/f:parameter[f:code/@value=$name]/f:value/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="f:definition/f:extension[@url='http://hl7.org/fhir/tools/StructureDefinition/ig-parameter'][f:extension[@url='code']/f:valueString/@value=$name]/f:extension[@url='value']/f:valueString/@value"/>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>
  <xsl:template mode="convertParams" match="f:parameter">
    <xsl:call-template name="setParameter">
      <xsl:with-param name="code" select="f:code/@value"/>
      <xsl:with-param name="value" select="f:value/@value"/>
      <xsl:with-param name="extensionMode" select="'Y'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="setParameter">
    <xsl:param name="system"/>
    <xsl:param name="code"/>
    <xsl:param name="value"/>
    <xsl:param name="supplement"/>
    <xsl:param name="extensionMode"/>
    
    <xsl:choose>
      <xsl:when test="f:parameter[f:code[@value=$code] and f:value[@value=$value or $supplement!='Y']]">
        <!-- Don't add - exists as parameter -->
      </xsl:when>
      <xsl:when test="f:extension[@url='http://hl7.org/fhir/tools/StructureDefinition/ig-parameter'][f:extension[@url='code']/f:valueString/@value=$code] and f:extension[@url='value']/f:valueString[@value=$value or $supplement!='Y']">
        <!-- Don't add - exists as extension -->
      </xsl:when>
      <xsl:when test="$code='apply' or $code='path-resource' or $code='path-pages' or $code='path-tx-cache' or $code='expansion-parameter' or $code='rule-broken-links' or $code='generate-xml' or $code='generate-json' or $code='generate-turtle' 
      or $code='html-template'">
        <xsl:if test="$extensionMode!='Y'">
          <parameter xmlns="http://hl7.org/fhir">
            <code value="{$code}"/>
            <value value="{$value}"/>
          </parameter>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
<!--        <xsl:if test="$extensionMode!='Y'">
          <parameter xmlns="http://hl7.org/fhir">
            <code value="{$code}"/>
            <value value="{$value}"/>
          </parameter>
        </xsl:if>-->
        <xsl:if test="$extensionMode='Y'">
          <extension xmlns="http://hl7.org/fhir" url="http://hl7.org/fhir/tools/StructureDefinition/ig-parameter">
            <extension url="code">
              <valueString value="{$code}"/>
            </extension>
            <extension url="value">
              <valueString value="{$value}"/>
            </extension>
          </extension>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>