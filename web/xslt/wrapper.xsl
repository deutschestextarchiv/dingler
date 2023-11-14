<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="t"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="html"/>

  <xsl:param name="base" select="'http://localhost/dingler/'"/>

  <!-- <!DOCTYPE html> declaration -->
  <xsl:template name="doctype">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
</xsl:text>
  </xsl:template>

  <!-- /html/head content -->
  <xsl:template name="html-header">
    <xsl:param name="title"/>

    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title><xsl:value-of select="$title"/> – Polytechnisches Journal</title>

    <link href="{$base}assets/bootstrap/bootstrap.min.css" rel="stylesheet"/>

    <script>
      MathJax = {
        tex: {
          inlineMath: [['$$', '$$'], ['\\(', '\\)']]
        },
        svg: {
          fontCache: 'global'
        }
      }
    </script>
    <script type="text/javascript" async="async" src="{$base}assets/js/MathJax/es5/tex-chtml.js" id="MathJax-script"></script>

    <link href="{$base}assets/css/styles.css" rel="stylesheet"/>
  </xsl:template>

  <!-- /html/body/header content -->
  <xsl:template name="site-header">
    <nav class="navbar navbar-expand-lg bg-white">
      <div class="container-fluid">
        <a class="navbar-brand" href="{$base}index.html">
          <img src="{$base}assets/images/logo.svg" height="80" alt="Logo Digitalisierung des Polytechnischen Journals"/>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
          <ul class="navbar-nav ms-auto me-5 mb-2 mb-lg-0">
            <li class="nav-item">
              <a class="nav-link" aria-current="page" href="{$base}index.html">Start</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$base}volumes/index.html">Bandübersicht</a>
            </li>
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                Dokumentation
              </a>
              <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="{$base}das-polytechnische-journal.html">Das Polytechnische Journal</a></li>
                <li><hr class="dropdown-divider"/></li>
                <li class="dropdown-header">Projektdokumentation</li>
                <li><a class="dropdown-item" href="{$base}digitalisierung.html">Digitalisierung</a></li>
                <li><a class="dropdown-item" href="{$base}dingler-online.html">Dingler Online</a></li>
                <li><a class="dropdown-item" href="{$base}modell.html">Textauszeichnung am Modell</a></li>
                <li><a class="dropdown-item" href="{$base}encoding.html">TEI-Encoding und Editionsprinzipien</a></li>
                <li><a class="dropdown-item" href="{$base}team.html">Projektteam</a></li>
                <li><hr class="dropdown-divider"/></li>
                <li><a class="dropdown-item" href="{$base}publikationen.html">Publikationen</a></li>
                <li><a class="dropdown-item" href="{$base}nachnutzung.html">Nachnutzung</a></li>
                <li><hr class="dropdown-divider"/></li>
                <li><a class="dropdown-item" href="{$base}webseite.html">Hinweise zu dieser Webseite</a></li>
              </ul>
            </li>
          </ul>
          <form class="d-flex mb-1" role="search" method="get" action="{$base}search.html">
            <input name="q" id="q-wrapper" class="form-control me-2" type="search" placeholder="Suche" aria-label="Search"/>
            <button class="btn btn-outline-success" type="submit">Suche</button>
          </form>
        </div>
      </div>
    </nav>
  </xsl:template>

  <xsl:template name="site-footer">
    <footer class="footer mt-auto py-3 bg-light">
      <div class="container">
        <p class="text-muted">
          Die Textdigitalisate des Polytechnischen Journals stehen unter der
          Lizenz <a href="https://creativecommons.org/licenses/by-sa/4.0/deed.de">Creative Commons BY-SA 4.0</a>.

          Der Rechtestatus, beziehungsweise die Lizenz der Bilddigitalisate ist in den Metadaten
          der jeweiligen Objekte in den <a href="https://digital.slub-dresden.de/kollektionen/30">Digitalen
          Sammlungen der SLUB Dresden</a> angegeben. Weitere Informationen finden Sie in unseren
          <a href="{$base}nutzungsbedingungen.html">Nutzungsbedingungen</a>.
        </p>
        <p class="text-center">
          <a href="{$base}datenschutz.html">Datenschutz</a>
          |
          <a href="{$base}impressum.html">Impressum</a>
        </p>
      </div>
    </footer>
  </xsl:template>

  <xsl:template name="html-footer">
    <script src="{$base}assets/bootstrap/bootstrap.min.js"></script>
    <script src="{$base}assets/js/jquery-3.7.1.min.js"></script>
    <script src="{$base}assets/js/scripts.js"></script>

    <!-- Matomo -->
    <script>
      var _paq = window._paq = window._paq || [];
      /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);
      (function() {
        var u="https://stats.dwds.de/";
        _paq.push(['setTrackerUrl', u+'matomo.php']);
        _paq.push(['setSiteId', '3']);
        _paq.push(['enableLinkTracking']);
        _paq.push(['trackPageView']);
        _paq.push(['trackVisibleContentImpressions']);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
      })();
    </script>
    <noscript><p><img src="https://stats.dwds.de/matomo.php?idsite=3&amp;rec=1" style="border:0" alt="" /></p></noscript>
    <!-- // Matomo -->
  </xsl:template>

</xsl:stylesheet>
