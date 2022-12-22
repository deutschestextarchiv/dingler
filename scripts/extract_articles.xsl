<?xml version="1.0" encoding="UTF-8"?>
  
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="t"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:param name="outdir" required="yes"/>

  <xsl:template match="@*|node()">
    <xsl:param name="title-main"/>
    <xsl:param name="title-sub"/>
    <xsl:param name="page"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="title-main" select="$title-main"/>
        <xsl:with-param name="title-sub" select="$title-sub"/>
        <xsl:with-param name="page" select="$page"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- articles -->
  <xsl:template match="//t:text[@type='art_undef' or @type='art_patent' or @type='art_patents' or @type='art_literature']">
    <xsl:variable name="outfile">
      <xsl:value-of select="$outdir"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>.xml</xsl:text>
    </xsl:variable>
    <xsl:result-document href="{$outfile}">
      <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="/t:TEI/t:teiHeader">
          <xsl:with-param name="title-main" select="normalize-space(t:front/t:titlePart[@type='main']/text())"/>
          <xsl:with-param name="title-sub" select="normalize-space(t:front/t:titlePart[@type='sub']/text())"/>
          <xsl:with-param name="page">
            <xsl:call-template name="start-page"/>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:copy-of select="."/> 
      </TEI>
    </xsl:result-document>
  </xsl:template>

  <!-- miscellanea -->
  <xsl:template match="//t:div[@type='misc_undef' or @type='misc_patents']">
    <xsl:variable name="outfile">
      <xsl:value-of select="$outdir"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>.xml</xsl:text>
    </xsl:variable>
    <xsl:result-document href="{$outfile}">
      <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="/t:TEI/t:teiHeader">
          <xsl:with-param name="title-main" select="normalize-space(t:head/text())"/>
          <xsl:with-param name="page">
            <xsl:call-template name="start-page"/>
          </xsl:with-param>
        </xsl:apply-templates>
        <text>
          <body>
            <xsl:copy-of select="."/> 
          </body>
        </text>
      </TEI>
    </xsl:result-document>
  </xsl:template>

  <!-- change <title> -->
  <xsl:template match="t:titleStmt/t:title"/>
  <xsl:template match="t:titleStmt">
    <xsl:param name="title-main"/>
    <xsl:param name="title-sub"/>
    <xsl:param name="page"/>
    <titleStmt xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:for-each select="$title-main">
        <title type="main">
          <xsl:call-template name="normalize">
            <xsl:with-param name="s" select="current()"/>
          </xsl:call-template>
        </title>
      </xsl:for-each>
      <xsl:if test="string-length(normalize-space($title-sub))>0">
        <xsl:for-each select="$title-sub">
          <title type="sub">
            <xsl:call-template name="normalize">
              <xsl:with-param name="s" select="current()"/>
            </xsl:call-template>
          </title>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates/>
    </titleStmt>
  </xsl:template>

  <!-- change <bibl> -->
  <xsl:template match="t:sourceDesc/t:bibl"/>
  <xsl:template match="t:sourceDesc">
    <xsl:param name="title-main"/>
    <xsl:param name="title-sub"/>
    <xsl:param name="page"/>
    <sourceDesc xmlns="http://www.tei-c.org/ns/1.0">
      <bibl type="JA">
        <xsl:call-template name="normalize">
          <xsl:with-param name="s" select="$title-main"/>
        </xsl:call-template>
        <xsl:text> In: </xsl:text>
        <xsl:value-of select="//t:sourceDesc/t:bibl[@type='J']"/>
        <xsl:text> S. </xsl:text>
        <xsl:value-of select="$page"/>
        <xsl:text>.</xsl:text>
      </bibl>
      <xsl:apply-templates>
        <xsl:with-param name="title-main" select="$title-main"/>
        <xsl:with-param name="title-sub" select="$title-sub"/>
        <xsl:with-param name="page" select="$page"/>
      </xsl:apply-templates>
    </sourceDesc>
  </xsl:template>

  <!-- add <seriesStmt> -->
  <xsl:template match="t:fileDesc/t:sourceDesc/t:biblFull">
    <xsl:param name="title-main"/>
    <xsl:param name="title-sub"/>
    <xsl:param name="page"/>
    <biblFull xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates>
        <xsl:with-param name="title-main" select="$title-main"/>
        <xsl:with-param name="title-sub" select="$title-sub"/>
        <xsl:with-param name="page" select="$page"/>
      </xsl:apply-templates>
      <seriesStmt>
        <title level="j" type="main">
          <xsl:value-of select="//t:sourceDesc/t:bibl[@type='J']"/>
        </title>
        <biblScope unit="volume">
          <xsl:value-of select="t:publicationStmt/t:date[@type='publication']"/>
        </biblScope>
        <biblScope unit="issue">
          <xsl:value-of select="/t:TEI/t:text[@type='volume']/@n"/>
        </biblScope>
        <biblScope unit="pages">
          <xsl:text>S. </xsl:text>
          <xsl:value-of select="$page"/>
        </biblScope>
      </seriesStmt>
    </biblFull>
  </xsl:template> 

  <!-- start page -->
  <xsl:template name="start-page">
    <xsl:choose>
      <xsl:when test="t:front/t:pb[1]/@n">
        <xsl:value-of select="t:front/t:pb[1]/@n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="preceding::t:pb[1]/@n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- normalize characters within metadata -->
  <xsl:template name="normalize">
    <xsl:param name="s"/>
    <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace($s,'aͤ','ä'),'oͤ','ö'),'uͤ','ü'),'Aͤ','Ä'),'Oͤ','Ö'),'Uͤ','Ü'),'ſ','s')"/>
  </xsl:template>

</xsl:stylesheet>
