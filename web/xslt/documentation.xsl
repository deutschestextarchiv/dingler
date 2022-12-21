<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="wrapper.xsl"/>

  <xsl:variable name="force-exclude-all-namespaces" select="true()"/>

  <xsl:output method="html"/>

  <xsl:template match="/main">
    <xsl:call-template name="doctype"/>
    <html lang="de">
      <head>
        <xsl:call-template name="html-header">
          <xsl:with-param name="title" select="/main/h1[1]"/>
        </xsl:call-template>
      </head>
      <body class="d-flex flex-column min-vh-100">
        <header>
          <xsl:call-template name="site-header"/>
        </header>
        <div class="container mt-3 mb-5">
          <div class="row">
            <div class="col-lg-8 col-md-12 tei mx-auto">
              <xsl:copy-of select="."/>
            </div>
          </div>
        </div>

        <xsl:call-template name="site-footer"/>
        <xsl:call-template name="html-footer"/>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
