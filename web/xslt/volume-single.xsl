<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates select="t:TEI/t:teiHeader"/>
  </xsl:template>

  <xsl:template match="t:teiHeader">
    <teiHeader>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="/t:TEI/t:text/@xml:id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </teiHeader>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@xml:id"/>
</xsl:stylesheet>
