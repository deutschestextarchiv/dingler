<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="wrapper.xsl"/>
  <xsl:import href="tei-text.xsl"/>
  <xsl:import href="volume-header.xsl"/>

  <xsl:variable name="force-exclude-all-namespaces" select="true()"/>
  <xsl:variable name="volume-id" select="/t:TEI/t:text[@type='volume'][1]/@xml:id"/>
  <xsl:variable name="barcode" select="substring-before(/t:TEI/t:text[1]//t:pb[1]/@facs, '/')"/>

  <xsl:output method="html" encoding="utf-8"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/t:TEI">
    <xsl:call-template name="doctype"/>
    <html lang="de">
      <head>
        <xsl:call-template name="html-header">
          <xsl:with-param name="title" select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='main'][1]"/>
        </xsl:call-template>
      </head>
      <body class="d-flex flex-column vh-100">
        <header>
          <xsl:call-template name="site-header"/>
          <div class="container">
            <div class="row">
              <div class="col-lg-8 col-md-8 mt-2 mx-auto bg-white">
                <nav aria-label="breadcrumb">
                  <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="{$base}">Start</a></li>
                    <li class="breadcrumb-item">
                      <a href="{$base}volumes/{$volume-id}.html">
                        <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='sub']"/>
                      </a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">
                      Extrahierte Artikelübersicht
                    </li>
                  </ol>
                </nav>
              </div>
            </div>
          </div>
        </header>
        <main class="flex-shrink-0">
          <div class="container mt-3 mb-5">
            <div class="row">
              <div class="col-lg-8 col-md-12 tei tei-text mx-auto">
                <h1>
                  <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='sub']"/>
                  – Artikelübersicht
                </h1>
                <ul>
                  <xsl:for-each select="//t:text[@type='art_undef' or @type='art_patent' or @type='art_patents' or @type='art_literature' or @type='art_miscellanea']">
                    <li>
                      <xsl:text>S. </xsl:text>
                      <xsl:choose>
                        <xsl:when test="count(descendant::t:pb[not(ancestor::t:note[@place='bottom'])][1]/preceding-sibling::t:*) > 0 or not(descendant::t:pb[not(ancestor::t:note[@place='bottom'])])">
                          <xsl:value-of select="preceding::t:pb[not(ancestor::t:note[@place='bottom'])][1]/@n"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="descendant::t:pb[not(ancestor::t:note[@place='bottom'])][1]/@n"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text>: </xsl:text>
                      <a href="../articles/{@xml:id}.html">
                        <xsl:for-each select="current()//t:titlePart[@type!='column']">
                          <xsl:apply-templates select="current()"/>
                          <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                          </xsl:if>
                        </xsl:for-each>
                      </a>
                    </li>
                  </xsl:for-each>
                </ul>
              </div>
            </div>
          </div>
        </main>

        <xsl:call-template name="site-footer"/>
        <xsl:call-template name="html-footer"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="t:titlePart">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- elements where only their text content is to be displayed -->
  <xsl:template match="t:bibl | t:hi | t:persName | t:placeName | t:ref | t:title">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="t:lb">
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="t:choice">
    <xsl:choose>
      <xsl:when test="t:corr">
        <xsl:apply-templates select="t:corr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- elements to be ignored -->
  <xsl:template match="t:cb | t:note"/>
</xsl:stylesheet>
