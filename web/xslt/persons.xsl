<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="t"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="wrapper.xsl"/>

  <xsl:output method="html"/>
<!--
  <xsl:param name="outdir" required="yes"/>
  <xsl:param name="volume-id" required="yes"/>
-->

  <xsl:key name="kWith1stLetter" match="surname" use="substring(.,1,1)"/>

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
              <div class="col-lg-8 col-md-12 tei mx-auto">
                <xsl:apply-templates select="t:text/t:front"/>
                <xsl:apply-templates select="t:text/t:body/t:listPerson"/>
              </div>
            </div>
          </div>
        </main>
        <xsl:call-template name="site-footer"/>
        <xsl:call-template name="html-footer"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="t:front/t:head">
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="t:listPerson">
    <xsl:apply-templates select="t:person/t:persName/t:surname[generate-id() = generate-id(key('kWith1stLetter',substring(.,1,1))[1])]">
      <xsl:sort select="substring(.,1,1)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="t:surname">
    <h2>
      <xsl:value-of select="substring(.,1,1)"/>
    </h2>
    <ul>
      <xsl:apply-templates mode="inGroup" select="key('kWith1stLetter',substring(.,1,1))">
      <xsl:sort order="ascending" />
      </xsl:apply-templates>
    </ul>
  </xsl:template>

  <xsl:template match="t:surname" mode="inGroup">
    <li>
      <xsl:apply-templates select="ancestor::t:person"/>
    </li>
  </xsl:template>

  <xsl:template match="t:surname" mode="text">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:person">
    <xsl:for-each select="t:persName">
      <xsl:for-each select="t:surname">
        <xsl:apply-templates select="current()" mode="text"/>
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="t:addName[node()] or t:roleName[node()] or t:forename[node()] or t:nameLink[node()]">
        <xsl:text>, </xsl:text>
        <xsl:for-each select="t:addName">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="t:roleName">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="t:forename">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="t:nameLink">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
    <xsl:text> [</xsl:text>
    <code>
      <xsl:value-of select="@xml:id"/>
    </code>
    <xsl:text>]</xsl:text>
    <xsl:if test="t:*[not(t:persName)]">
      <ul>
        <xsl:for-each select="t:*[not(self::t:persName)]">
          <li>
            <xsl:apply-templates select="current()"/>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:birth">
    <xsl:text>geboren: </xsl:text>
    <xsl:for-each select="t:*">
      <xsl:apply-templates select="current()"/>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:death">
    <xsl:text>gestorben: </xsl:text>
    <xsl:for-each select="t:*">
      <xsl:apply-templates select="current()"/>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:floruit">
    <xsl:text>tätig: </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:occupation">
    <xsl:text>Tätigkeit: </xsl:text>
    <xsl:for-each select="t:*">
      <xsl:apply-templates select="current()"/>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:placeName[t:*]">
    <xsl:text>in: </xsl:text>
    <xsl:apply-templates select="t:settlement"/>
    <xsl:if test="t:region">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="t:region"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:note[@type='pnd']">
    <a href="https://d-nb.info/gnd/{text()}">GND</a>
  </xsl:template>

  <xsl:template match="t:note[@type='viaf']">
    <a href="https://viaf.org/viaf/{text()}">VIAF</a>
  </xsl:template>

  <xsl:template match="t:note[@type='wiki']">
    <a href="{text()}">Wikipedia</a>
  </xsl:template>

  <xsl:template match="t:note[@type='nopnd']">
    <xsl:text>kein GND-Eintrag</xsl:text>
  </xsl:template>

  <xsl:template match="t:ref">
    <a href="{@target}" target="_blank">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="t:date">
    <xsl:value-of select="@when"/>
  </xsl:template>

</xsl:stylesheet>
