<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:template name="tabs-right">
    <xsl:if test="//t:ref[contains(@target, '#tab')]">
      <p style="font-size:14pt; font-weight:bold">Tafeln</p>
      <xsl:for-each-group select="//t:ref[contains(@target, '#tab')]" group-by="@target">
        <xsl:variable name="tab-thumb">
          <xsl:value-of select="$base"/>
          <xsl:text>images/</xsl:text>
          <xsl:choose>
            <xsl:when test="starts-with(@target, '#tab')">
              <!-- tab within same volume -->
              <xsl:value-of select="$volume-id"/>
              <xsl:text>/thumbs/</xsl:text>
              <xsl:value-of select="substring-after(@target, '#')"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- tab within other volume
                ../pj013/32258217Z.xml#tab013567
                   |...| |.......|     |.......|
                   $volume-id           tab
                         $barecode
              -->
             <xsl:value-of select="substring-before(substring-after(@target, '../'), '/')"/>
             <xsl:text>/thumbs/</xsl:text>
             <xsl:value-of select="substring-after(@target, '#')"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>_800.jpg</xsl:text>
        </xsl:variable>
        <xsl:variable name="tab-full">
          <xsl:value-of select="$base"/>
          <xsl:text>images/</xsl:text>
          <xsl:choose>
            <xsl:when test="starts-with(@target, '#tab')">
              <xsl:value-of select="$volume-id"/>
              <xsl:text>/</xsl:text>
              <xsl:value-of select="$barcode"/>
              <xsl:text>/</xsl:text>
              <xsl:value-of select="substring-after(@target, '#')"/>
            </xsl:when>
            <xsl:otherwise>
             <xsl:value-of select="substring-before(substring-after(@target, '../'), '/')"/>
             <xsl:text>/</xsl:text>
             <xsl:value-of select="substring-after(substring-after(substring-before(@target, '.xml'), '/'), '/')"/>
             <xsl:text>/</xsl:text>
             <xsl:value-of select="substring-after(@target, '#')"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>.png</xsl:text>
        </xsl:variable>
        <a href="{$tab-full}" target="_blank">
          <figure class="figure">
            <img src="{$tab-thumb}" class="figure-img img-fluid rounded" alt="Tafel {text()}"/>
            <figcaption class="figure-caption text-end">
              <xsl:value-of select="current()"/>
            </figcaption>
          </figure>
        </a>
      </xsl:for-each-group>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
