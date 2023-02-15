<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="html"/>

  <xsl:template name="format-name">
    <xsl:param name="ref"/>
    <xsl:variable name="file">
      <xsl:text>../../sources/</xsl:text><xsl:value-of select="substring-after(substring-before($ref, '#'), '..')"/>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:value-of select="substring-after($ref, '#')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$id != 'pers' and string-length($id)>0">
        <xsl:apply-templates select="document($file)//t:person[@xml:id=$id]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t:person">
    <xsl:for-each select="t:persName">
      <xsl:for-each select="t:roleName">
        <xsl:apply-templates select="current()"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:for-each select="t:forename">
        <xsl:apply-templates select="current()"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:for-each select="t:surname">
        <xsl:apply-templates select="current()"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:if test="t:note[@type='pnd']">
      <xsl:text> [</xsl:text>
      <xsl:for-each select="t:note[@type='pnd']">
        <a href="https://d-nb.info/gnd/{text()}">GND</a>
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:teiHeader">
    <div class="tei-header" data-volume="{$volume-id}" data-barcode="{$barcode}">
      <table>
        <tr>
          <td>Titel:</td>
          <td>
            <xsl:for-each select="t:fileDesc/t:titleStmt/t:title[@type='main']">
              <xsl:apply-templates select="current()"/>
              <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </td>
        </tr>
        <xsl:if test="//t:persName[@role='author']">
          <tr>
            <td>Autor:</td>
            <td>
              <xsl:for-each select="//t:persName[@role='author']">
                <xsl:call-template name="format-name">
                  <xsl:with-param name="ref" select="@ref"/>
                </xsl:call-template>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>
        <tr>
          <td>Fundstelle:</td>
          <td>
            <xsl:text>Band </xsl:text>
            <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:seriesStmt/t:biblScope[@unit='issue']"/>
            <xsl:text>, Jahrgang </xsl:text>
            <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:seriesStmt/t:biblScope[@unit='volume']"/>
            <xsl:choose>
              <xsl:when test="/t:TEI/t:text[1]//t:titlePart[@type='number'][1]">
                <xsl:text>, Nr. </xsl:text>
                <xsl:value-of select="/t:TEI/t:text[1]//t:titlePart[@type='number'][1]"/>
              </xsl:when>
              <xsl:when test="/t:TEI/t:text/t:body/t:div/@type='misc_undef' or /t:TEI/t:text/t:body/t:div/@type='misc_patents'">
                <xsl:text>, Miszellen</xsl:text>
              </xsl:when>
            </xsl:choose>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:seriesStmt/t:biblScope[@unit='pages']"/>
          </td>
        </tr>
        <tr>
          <td>Download:</td>
          <td>
            <a href="{$base}xml/articles/{//t:text[1]/@xml:id}.xml">XML</a>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
