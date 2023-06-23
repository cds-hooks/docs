<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="f:ImplementationGuide">
    <xsl:text>R5=Y&#xa;</xsl:text>
    <xsl:if test="f:fhirVersion/@value[starts-with(., '4.')]">R4=Y&#xa;</xsl:if>
    <xsl:if test="f:fhirVersion/@value[starts-with(., '3.')]">R3=Y&#xa;</xsl:if>
    <xsl:if test="f:fhirVersion/@value[starts-with(., '1.4')]">R2B=Y&#xa;</xsl:if>
    <xsl:if test="f:fhirVersion/@value[starts-with(., '1.0')]">R2=Y&#xa;</xsl:if>
    <xsl:value-of select="concat('igVersion=', f:version/@value, '&#xa;')"/>
    <xsl:if test="f:definition/f:parameter[f:code/@value='globals-in-artifacts']/f:value/@value='true'">globals=Y</xsl:if>
	</xsl:template>
</xsl:stylesheet>
