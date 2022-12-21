<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="wrapper.xsl"/>
  <xsl:import href="tei-text.xsl"/>
  <xsl:import href="article-header.xsl"/>

  <xsl:variable name="force-exclude-all-namespaces" select="true()"/>

  <xsl:output method="html"/>

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
      <body>
        <header>
          <xsl:call-template name="site-header"/>
          <div class="container">
            <div class="row">
              <div class="col-lg-8 col-md-8 mt-2 mx-auto bg-white">
                <nav aria-label="breadcrumb">
                  <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="#">Start</a></li>
                    <li class="breadcrumb-item">
                      <a href="../volumes/{substring-before(//t:pb[1]/@xml:id, '_')}.html">
                        <xsl:text>Band </xsl:text>
                        <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:seriesStmt/t:biblScope[@unit='volume']"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:biblFull/t:seriesStmt/t:biblScope[@unit='issue']"/>
                      </a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">
                      Artikel
                      <xsl:value-of select="//t:text//t:titlePart[@type='number'][1]"/>
                    </li>
                  </ol>
                </nav>
              </div>
            </div>
          </div>
        </header>
        <div class="container mt-3 mb-5">
          <div class="row">
            <div class="col-lg-2"></div>
            <div class="col-lg-7 col-md-8 tei mx-auto">
              <xsl:apply-templates/>
            </div>
            <div class="col-lg-3 bg-light">
              <xsl:if test="//t:ref[starts-with(@target, '#tab')]">
                <p style="font-size:14pt; font-weight:bold">Tafeln</p>
                <xsl:for-each select="//t:ref[starts-with(@target, '#tab')]">
                  <figure class="figure">
                    <img src="{$base}tabs/{substring-before(//t:pb[1]/@xml:id, '_')}/{//t:idno[@type='shelfmark']}/{substring-after(@target, '#')}.png" class="figure-img img-fluid rounded" alt="Tafel {text()}"/>
                    <figcaption class="figure-caption text-end">
                      <xsl:value-of select="current()"/>
                    </figcaption>
                  </figure>
                </xsl:for-each>
              </xsl:if>
            </div>
          </div>
        </div>

        <xsl:call-template name="site-footer"/>
        <xsl:call-template name="html-footer"/>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>