<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="t"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:import href="wrapper.xsl"/>

  <xsl:output method="html"/>

  <xsl:key name="kWith1stLetter" match="title" use="substring(.,1,1)"/>

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
                <xsl:apply-templates select="t:text/t:body/t:listBibl"/>
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

  <xsl:template match="t:listBibl">
    <xsl:apply-templates select="t:bibl/t:title[@level][generate-id() = generate-id(key('kWith1stLetter',substring(.,1,1))[1])]">
      <xsl:sort select="substring(.,1,1)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="t:title[@level]">
    <h2>
      <xsl:value-of select="substring(.,1,1)"/>
    </h2>
    <ul>
      <xsl:apply-templates mode="inGroup" select="key('kWith1stLetter',substring(.,1,1))">
        <xsl:sort order="ascending"/>
      </xsl:apply-templates>
    </ul>
  </xsl:template>

  <xsl:template match="t:title[@level]" mode="inGroup">
    <li id="{ancestor::t:bibl/@xml:id}">
      <xsl:apply-templates select="ancestor::t:bibl"/>
    </li>
  </xsl:template>

  <xsl:template match="t:title[@level]" mode="text">
    <b><xsl:apply-templates/></b>
  </xsl:template>

  <xsl:template match="t:title[@prev]">
    <xsl:text>Vorgängerpublikation: </xsl:text>
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@prev, '#')"/>
    </xsl:variable>
    <a href="{@prev}">
      <xsl:value-of select="//t:bibl[@xml:id=$target]/t:title[@level]"/>
    </a>
  </xsl:template>

  <xsl:template match="t:title[@next]">
    <xsl:text>Nachfolgepublikation: </xsl:text>
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@next, '#')"/>
    </xsl:variable>
    <a href="{@next}">
      <xsl:value-of select="//t:bibl[@xml:id=$target]/t:title[@level]"/>
    </a>
  </xsl:template>

  <xsl:template match="t:relatedItem">
    <xsl:text>Verwandte Publikation: </xsl:text>
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@target, '#')"/>
    </xsl:variable>
    <a href="{@target}">
      <xsl:value-of select="//t:bibl[@xml:id=$target]/t:title[@level]"/>
    </a>
  </xsl:template>

  <xsl:template match="t:bibl">
    <xsl:apply-templates select="t:title[@level]" mode="text"/>
    <xsl:if test="t:*[not(t:persName)]">
      <ul>
        <xsl:for-each select="t:*[not(self::t:title[@level])]">
          <li>
            <xsl:apply-templates select="current()"/>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:author">
    <xsl:text>Autor</xsl:text>
    <xsl:if test="count(t:*) > 1">
      <xsl:text>en</xsl:text>
    </xsl:if>
    <xsl:text>: </xsl:text>
    <xsl:call-template name="person"/>
  </xsl:template>

  <xsl:template match="t:editor">
    <xsl:text>Herausgeber: </xsl:text>
    <xsl:call-template name="person"/>
  </xsl:template>

  <xsl:template match="t:publisher">
    <xsl:text>Verleger: </xsl:text>
    <xsl:call-template name="person"/>
  </xsl:template>

  <xsl:template name="person">
    <xsl:choose>
      <xsl:when test="t:*">
        <xsl:for-each select="t:*">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text>; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t:persName">
    <xsl:for-each select="t:surname">
      <xsl:apply-templates select="current()" mode="text"/>
      <xsl:if test="position() != last()">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="t:addName[node()] or t:roleName[node()] or t:forename[node()] or t:nameLink[node()]">
      <xsl:text>,</xsl:text>
      <xsl:if test="t:addName">
        <xsl:text> </xsl:text>
        <xsl:for-each select="t:addName">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="t:roleName">
        <xsl:text> </xsl:text>
        <xsl:for-each select="t:roleName">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="t:forename">
        <xsl:text> </xsl:text>
        <xsl:for-each select="t:forename">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="t:nameLink">
        <xsl:text> </xsl:text>
        <xsl:for-each select="t:nameLink">
          <xsl:apply-templates select="current()"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:date">
    <xsl:text>Erscheinungszeitraum: </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:pubPlace[t:*]">
    <xsl:text>Erscheinungsort: </xsl:text>
    <xsl:apply-templates select="t:settlement"/>
    <xsl:if test="t:country">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="t:country"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:ref[@target='#ZDB-ID']">
    <a href="https://zdb-katalog.de/list.xhtml?t={normalize-space(text())}&amp;key=zdb">Zeitschriftendatenbank</a>
  </xsl:template>

  <xsl:template match="t:ref[@target='e-journal']">
    <a href="{normalize-space(text())}">Online-Ausgabe</a>
  </xsl:template>

  <xsl:template match="t:ref[@target='#OCLC-ID']">
    <a href="https://worldcat.org/de/title/{normalize-space(text())}">WorldCat</a>
  </xsl:template>
</xsl:stylesheet>
