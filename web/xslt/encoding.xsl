<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="t eg"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="wrapper.xsl"/>
  <xsl:import href="tei-text.xsl"/>
  <xsl:import href="xml-to-string.xsl"/>
  <xsl:variable name="force-exclude-all-namespaces" select="true()"/>

  <xsl:output method="html" indent="no"/>

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
        </header>
        <main class="flex-shrink-0">
          <div class="container mt-3 mb-5">
            <div class="row">
              <div class="col-lg-8 col-md-12 tei encoding mx-auto">
                <xsl:apply-templates select="t:text"/>
              </div>
            </div>
          </div>
        </main>
        <xsl:call-template name="site-footer"/>
        <xsl:call-template name="html-footer"/>
      </body>
    </html>
  </xsl:template>

  <!-- egXML elements -->
  <xsl:template match="eg:egXML">
    <xsl:variable name="code">
      <xsl:call-template name="xml-to-string">
        <xsl:with-param name="node-set" select="exslt:node-set(eg:*)"/>
      </xsl:call-template>
    </xsl:variable>
    <div class="egxml">
      <xsl:value-of select="$code"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
