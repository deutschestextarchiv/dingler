<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="html"/>

  <xsl:template match="t:editor">
    <xsl:for-each select="t:persName">
      <xsl:for-each select="current()/t:roleName">
        <xsl:apply-templates select="current()"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:for-each select="current()/t:forename">
        <xsl:apply-templates select="current()"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:for-each select="current()/t:surname">
        <xsl:apply-templates select="current()"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:if test="starts-with(current()/@ref, 'https://d-nb.info/gnd/')">
        <xsl:text> [</xsl:text>
        <a href="{current()/@ref}">GND</a>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:teiHeader">
    <div class="tei-header" data-volume="{$volume-id}" data-barcode="{$barcode}">
      <table>
        <tr>
          <td>Titel:</td>
          <td>
            <xsl:for-each select="t:fileDesc/t:titleStmt/t:title">
              <xsl:apply-templates select="current()"/>
              <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </td>
        </tr>
        <xsl:if test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:titleStmt/t:editor">
          <tr>
            <td>Herausgeber:</td>
            <td>
              <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:titleStmt/t:editor">
                <xsl:apply-templates select="current()"/>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>
        <tr>
          <td>Zugänge:</td>
          <td>
            <!-- skip if Atlas or Realindex -->
            <xsl:if test="not(contains(//t:fileDesc/t:titleStmt/t:title[@type='sub'], 'Atlas') or contains(//t:fileDesc/t:titleStmt/t:title[@type='sub'], 'Realindex'))">
              <a href="{$base}article-listings/{$volume-id}.html">Artikelübersicht</a> |
            </xsl:if>
            <a href="http://digital.slub-dresden.de/id{$barcode}">Digitale Sammlungen (SLUB)</a>
            |
            <a href="{$base}xml/volumes/{$volume-id}.xml">TEI-XML</a>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
