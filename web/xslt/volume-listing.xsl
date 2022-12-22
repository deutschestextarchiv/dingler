<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="tei-text.xsl"/>
  <xsl:import href="wrapper.xsl"/>

  <xsl:output method="html"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:back | t:group | t:milestone | t:pb"/>

  <xsl:template match="/t:teiCorpus">
    <xsl:call-template name="doctype"/>
    <html lang="de">
      <head>
        <xsl:call-template name="html-header">
          <xsl:with-param name="title" select="'Übersicht Bände'"/>
        </xsl:call-template>
      </head>
      <body class="d-flex flex-column vh-100">
        <header>
          <xsl:call-template name="site-header"/>
        </header>
        <main class="flex-shrink-0">
          <div class="container mt-3 mb-5">
            <div class="row">
              <div class="col-lg-8 col-md-12 tei mx-auto">
                <h1>Übersicht Bände</h1>

                <ul>
                  <xsl:for-each select="//t:teiHeader">
                    <li>
                      <a href="{$base}volumes/{@xml:id}.html"><xsl:value-of select="current()//t:bibl[@type='J']"/></a>
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

</xsl:stylesheet>
