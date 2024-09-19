$( function() {
  var volume  = $('.tei-header').data('volume')
  var barcode = $('.tei-header').data('barcode')

  // link to page images
  // no image is provided for binding and interleaf pages
  /*
  $('.tei-pb[data-facs]').not('[data-n^="binding"]').not('[data-n^="interleaf"]').append( function(i, str) {
    let facs = $(this).data('facs')
    let n    = $(this).data('n')
    let marginLeft = -( $(this).position().left - $('.tei').position().left + 220)
    return `<figure class="tei-side-figure figure" style="margin-left:${marginLeft}px">
              <a href="../facsimile/${facs}.png" target="_blank" title="im Vollbild anzeigen" data-bs-toggle="tooltip">
                <img src="../facsimile/${facs}.png" class="figure-img img-fluid rounded"/>
              </a>
              <figcaption class="figure-caption">
                Faksimile ${Number.isInteger(n) != 0 ? 'S. ' + n : n}
              </figcaption>
            </figure>`
  })*/

  // choice/sic|corr
  $('.tei-choice').html( function() {
    let el = $(this)
    let ret = $('<span/>').css('cursor', 'pointer')
                          .html( $('.tei-corr', el).html() )
    ret.popover({
      content: $('<div class="tei-text"/>').css('font-size', '1rem').html( $('.tei-sic').html() ),
      title: "Druckfehler",
      trigger: "hover",
      sanitize: false,
      html: true,
      animation: true,
      placement: 'bottom',
    })
    return ret
  })

  // figures
  $('.tei-figure').html( function() {
    let el = $(this)
    let figDesc   = $('.tei-figDesc', el).html()
    let otherDesc = $(':not(.tei-figDesc, .tei-graphic)', el).prop('outerHTML')
    let imgUrl    = $('.tei-graphic', el).data('url')

    let ret = `
<figure class="figure text-center">
  <img src="${ imgUrl.search(/^https?:/) > -1 ? imgUrl : '../images/' + volume + '/' + imgUrl + '.png'}" class="figure-img img-fluid rounded">
`
    if ( figDesc ) {
      ret += `
    <figcaption class="figure-caption">
      [${figDesc}]
    </figcaption>`
    }

    if ( otherDesc )
      ret += otherDesc

    ret += '</figure>'
    return ret
  })

  // footnotes
  $('.tei-note[data-place="bottom"]').before( function() {
    let el = $(this)
    el.hide()
    $('.tei-pb', el).remove()
    let ret = $('<a/>').attr('tabindex', 0)
                       .addClass('tei-note-sign')
                       .css('cursor', 'pointer')
                       .html( el.data('n') )
    ret.popover({
      content: $('<div class="tei-text tei-note-popover"/>').css('font-size', '1rem').html( el.html() ),
      title: "Fußnote <sup>" + el.data('n') + '</sup>',
      trigger: "focus",
      sanitize: false,
      html: true,
      animation: true,
      placement: 'bottom',
    })
    return ret
  })

  // persName
  /*
  $('.tei-persName').not('[data-ref$="#pers"]').wrap( function() {
    let target = $(this).data('ref').replace(/^#/, '')
    return $('<a/>').attr('href', `../persons/${target}.html`)
  })
  */

  // links
  $('.tei-ref[data-target]').each( function() {
    let el = $(this)
    let target = el.data('target')

    // … to URLs
    if ( target.search(/^https?:\/\//) > -1 ) {
      el.wrap( function() {
        let target = $(this).data('target').replace(/^#/, '')
        return $('<a/>').attr({
          href:   target,
          target: '_blank'
        })
      })
    }
    // … to tabs
    else if ( target.search(/^#t(?:ab|x)/) > -1 ) {
      el.wrap( function() {
        let target = $(this).data('target').replace(/^#/, '')
        return $('<a/>').attr({
          href:   `../images/${volume}/${barcode}/${target}.png`,
          target: '_blank'
        })
      })
    }
    // … to tabs within other volumes
    else if ( target.search(/^\.\.\/(pj[^/]+)\/(\w+)\.xml#(t(?:ab|x)\w+)/) > -1 ) {
      let parts = target.match(/^\.\.\/(pj[^/]+)\/(\w+)\.xml#(t(?:ab|x)\w+)/)
      el.wrap( function() {
        return $('<a/>').attr({
          href:   `../images/${parts[1]}/${parts[2]}/${parts[3]}.png`,
          target: '_blank'
        })
      })
    }
    // … to figures
    else if ( target.search(/^image_markup\//) > -1 ) {
      el.wrap( function() {
        let target = $(this).data('target').replace(/^.*?#(.*)/, '$1')
        return $('<a/>').attr({
          href:   `../images/${volume}/figures/${target}.jpg`,
          target: '_blank'
        })
      })
    }
    // … to figures within other volumes
    else if ( target.search(/^\.\.\/(pj[^/]+)\/image_markup\/(?:t(?:ab|x)\w+)\.xml#(fig\w+)/) > -1 ) {
      let parts = target.match(/^\.\.\/(pj[^/]+)\/image_markup\/(?:t(?:ab|x)\w+)\.xml#(fig\w+)/)
      el.wrap( function() {
        return $('<a/>').attr({
          href:   `../images/${parts[1]}/figures/${parts[2]}.jpg`,
          target: '_blank'
        })
      })
    }
    // … to pages within volumes
    else if ( target.search(/^\.\..*?#pj.*?_.*?$/) > -1 ) {
      // do nothing here, these references must be adjusted
    }
    // … to anchors within document
    else if ( target.search(/^#/) > -1 ) {
      el.wrap( function() {
        let anchor = $('<a/>').attr({
          href: target
        })
        anchor.on( 'click', function() {
          $([document.documentElement, document.body]).animate({
            scrollTop: $('[data-xml-id="' + target.replace(/^#/,'') + '"]').offset().top
          }, 100)
          return false
        })
        return anchor
      })
    }
    // … to articles
    else {
      el.wrap( function() {
        let target = $(this).data('target').replace(/^#/, '')
        return $('<a/>').attr('href', `../articles/${target}.html`)
      })
    }
  })

  // table styling
  $('.tei-header table').addClass('table table-condensed table-striped')
  $('.tei-table').wrap('<div class="table-responsive"></div>')

  // formulas
  $('.tei-formula').each( function() {
    let el = $(this)
    el.html( '$$' + el.html() + '$$' )
  }).promise().done( function() {
    if ( typeof MathJax != "undefined" && typeof MathJax.typeset === "function" )
      MathJax.typeset()
  })

  // link to XML source
  let file = window.location.href.match(/\/([^/]+)\.html/)
  if ( file )
    $('#xml-source').attr( 'href', `../articles/${file[1]}.xml` )

  // XML pretty printer
  $('.egxml').text( function() {
    return prettyXML($(this).text())
  })

  // search
  $('#search-error').hide()

  let searchParams = new URLSearchParams(window.location.search)
  let q = searchParams.get('q')
  if ( q && q.replace(/^\s+|\s+$/,'').length > 0 ) {
    $('#search-in-progress').show()

    $('#q').val(q)
    $('#q-wrapper').val(q)
    let qf = q

    // date range
    let ds = searchParams.get('ds')
    let de = searchParams.get('de')
    if ( ds )
      $('#ds').val(ds)
    if ( de )
      $('#de').val(de)

    ds = $('#ds').val()
    de = $('#de').val()
    if ( ds && de )
      qf += ` #asc_date[${ds},${de}]`

    // context
    let cntxt = searchParams.get('cntxt')
    if ( cntxt )
      $('#cntxt').val(cntxt)

    cntxt = $('#cntxt').val()
    if ( cntxt )
      qf += ` #cntxt ${cntxt}`

    // within
    let within = searchParams.get('within')
    if ( within )
      $('#within').val(within)

    within = $('#within').val()
    if ( within == 'sep' )
      qf += ` #${within}`
    else if ( within == 'file' )
      qf += ' #within file'

    // console.log('DDC query:', qf)

    // paging
    let limit = parseInt(searchParams.get('limit')) || $('#limit').val() || 20
    let page  = parseInt(searchParams.get('p'))     || 1
    let start = (page - 1) * limit + 1

    function page_state (p, s) {
      let ret = ''
      if ( !s || s < 1 || s > p.last_page() )
        ret += ' disabled'
      if ( s == p.current_page)
        ret += ' active'
      return ret
    }

    function result_url (page) {
      let url = new URL(window.location.href)
      url.searchParams.set('p', page)
      return url.toString()
    }

    let dstar = 'https://ddc.dwds.de/dstar/dingler/dstar.perl'
    $.ajax({
      url: dstar,
      data: { q: qf, fmt: 'json', limit: limit, start: start },
    }).done( function(data) {
      let head = '<div class="result-head mb-2 text-center">'
      if ( data.nhits_ )
        head += `${parseInt(data.start) + 1}–${data.end_} von ${data.nhits_} Treffern`
      else
        head += 'keine Treffer gefunden'
      head += '</div>'

      const p = new Pager()
      p.total_entries    = data.nhits_
      p.entries_per_page = limit
      p.current_page     = parseInt((start / limit) + 1)

      let pager = `
<nav>
  <ul class="pagination pagination-sm justify-content-center">
    <li class="page-item ${page_state(p, p.first_page())}">
      <a class="page-link" href="${result_url(p.first_page())}">&#x21e4;</a>
    </li>
    <li class="page-item ${page_state(p, p.current_page - 10)}">
      <a class="page-link" href="${result_url(p.current_page - 10)}">-10</a>
    </li>
    <li class="page-item ${page_state(p, p.current_page - 5)}">
      <a class="page-link" href="${result_url(p.current_page - 5)}">-5</a>
    </li>
    <li class="page-item ${page_state(p, p.previous_page())}">
      <a class="page-link" href="${result_url(p.previous_page())}">&larr;</a>
    </li>`

    let page_leftmost = (p.current_page || 0) - 2
    if ( (page_leftmost || 0) < 1 )
      page_leftmost = 1

    if ( p.last_page() - (page_leftmost || 0) < 5 )
      page_leftmost = p.last_page() - 4

    let page_rightmost = p.current_page + 2
    if ( (page_rightmost || 0) < 5 )
      page_rightmost = 5

    if ( (page_rightmost || 0) > p.last_page() )
      page_rightmost = p.last_page()

    for ( let i = page_leftmost; i <= page_rightmost; i++ ) {
      if ( (i || 0) < 1 )
        continue
      if ( i > p.last_page() )
        continue

      pager += `
      <li class="page-item ${page_state(p, i)}">
        <a class="page-link" href="${result_url(i)}">${i}</a>
      </li>`
    }

    pager += `
    <li class="page-item ${page_state(p, p.next_page())}">
      <a class="page-link" href="${result_url(p.next_page())}">&rarr;</a>
    </li>
    <li class="page-item ${page_state(p, p.current_page + 5)}">
      <a class="page-link" href="${result_url(p.current_page + 5)}">+5</a>
    </li>
    <li class="page-item ${page_state(p, p.current_page + 10)}">
      <a class="page-link" href="${result_url(p.current_page + 10)}">+10</a>
    </li>
    <li class="page-item ${page_state(p, p.last_page())}">
      <a class="page-link" href="${result_url(p.last_page())}">&#x21e5;</a>
    </li>
  </ul>
</nav>`

      let hits = []
      data.hits_.forEach( (h,i) => {
        let ctx_before = ctxString(h.ctx_[0])
        let ctx_after  = ctxString(h.ctx_[2])
        let fragment = h.ctx_[1].map( (k,i) => (i!=0 && k.ws==1 ? ' ' : '') + _h(k.w) ).slice(0, 3).join('')
        let div = `
<div class="hit mb-3">
  <div class="hit-bibl">
    <span class="hit-no">${parseInt(data.start) + i + 1}.</span>
    <a href="articles/${_u(_h(h.meta_.basename.replace(/\.orig$/,'')))}.html#:~:text=${_u(_h(fragment))}">${_h(h.meta_.bibl)}</a>
  </div>
`

        if ( within != 'file' ) {
          div += `
  <div class="hit-text">
    ${ ctx_before }
    ${ h.ctx_[1].map( (k,i) => (i!=0 && k.ws==1 ? ' ' : '') + (k.hl_==1 ? '<b>' : '') + _h(k.w) + (k.hl_==1 ? '</b>' : '') ).join('') }
    ${ ctx_after }
  </div>
          `
        }

        div += `
</div>`
        hits.push( div)
      })
      $('#search-in-progress').hide()
      $('#results').html( head + (data.nhits_ ? pager : '') + hits.join('') + (data.nhits_ ? pager : '') )
    }).fail( function(a, b, c) {
      $('#search-in-progress').hide()
      let msg = a.responseText.match(/<pre>(.*?)<\/pre>/s)
      $('#search-error').html( msg[1] ).show()
    })
  }

  function ctxString (words) {
    let str = ctxWrapTokens(words)
    str = ctxUntokenize(str)
    str = ctxUnwrapTokens(str)
    return str
  }

  function ctxWrapTokens (words) {
    let str = words.map( w => " \x02" + w + "\x03" ).join('')
    str = str.replace(/^ /, '')
    return str
  }

  function ctxUntokenize (str) {
    // token markers left + right
    const wl = '\\x02'
    const wr = '\\x03'

    // quotations marks left
    const ql = '[\\(\\[\\{\\x2018\\x201c\\x2039\\x201a\\x201e]'

    // quotations marks right
    const qr  = '[\\)\\]\\}\\x2019\\x201d\\x203a]'
    // no-quotation marks right
    const nqr = '[^\\)\\]\\}\\x2019\\x201d\\x203a]'

    // generic quotations marks
    const qq  = '["`\'\\xab\\xbb]'
    // generic no-quotations marks
    const nqq = '[^"`\'\\xab\\xbb]'

    // punctuation (right side)
    const pr = '[,.!?:;%]|[\\x2019\\x201d\\x203a][snm]'

    str = str.replace( new RegExp(`(\\s${wl}${qq}+${wr})\\s(${nqq}*)\\s(${wl}${qq}+${wr}\\s)`, "sg"), '$1$2$3' )
    str = str.replace( new RegExp(`(\\s${wl}${ql}${wr})\\s`, "sg"), '$1' )
    str = str.replace( new RegExp(`\\s(${wl}${qr}${wr}\\s)`, "sg"), '$1' )
    str = str.replace( new RegExp(`\\s(${wl}${pr}${wr}\\s)`, "sg"), '$1' )
    return str
  }

  function ctxUnwrapTokens (str) {
    return str.replace( /[\x02\x03]/g, '' )
  }

  // escape HTML
  function _h (str) {
    return document.createElement('div').appendChild(document.createTextNode(str)).parentNode.innerHTML
  }

  // escape URI
  function _u (str) {
    return encodeURIComponent(str)
  }
})

class Pager {
  total_entries
  entries_per_page
  current_page

  first_page() { return 1 }

  last_page() {
    let pages = this.total_entries / this.entries_per_page
    let last_page
    if ( pages == parseInt(pages) )
      last_page = pages
    else
      last_page = 1 + parseInt(pages)
    if ( last_page < 1 )
      last_page = 1
    return last_page
  }

  previous_page() {
    if ( this.current_page > 1 )
      return this.current_page - 1
    else
      return
  }

  next_page() {
    if ( this.current_page < this.last_page() ) {
      return this.current_page + 1
    }
    else
      return
  }
}

function prettyXML (str) {
  var xmlDoc = new DOMParser().parseFromString('<ROOT>'+str+'</ROOT>', 'application/xml');
  var xsltDoc = new DOMParser().parseFromString([
      '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">',
      '  <xsl:strip-space elements="*"/>',
      '  <xsl:template match="para[content-style][not(text())]">',
      '    <xsl:value-of select="normalize-space(.)"/>',
      '  </xsl:template>',
      '  <xsl:template match="node()|@*">',
      '    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>',
      '  </xsl:template>',
      '  <xsl:output indent="yes"/>',
      '</xsl:stylesheet>',
  ].join('\n'), 'application/xml');

  var xsltProcessor = new XSLTProcessor();
  xsltProcessor.importStylesheet(xsltDoc);
  var resultDoc = xsltProcessor.transformToDocument(xmlDoc);
  var resultXml = new XMLSerializer().serializeToString(resultDoc);
  return resultXml.replace(/<\/?ROOT>/g, '').replace(/^  /mg, '').replace(/^\s+/, '').replace(/ͤ/g, '&#x364;')
};
