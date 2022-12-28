$( function() {
  var volume = $('.tei-header').data('volume')

  // link to page images
  $('.tei-pb[data-facs]').append( function(i, str) {
    let facs = $(this).data('facs')
    let n    = $(this).data('n')
    return `<figure class="tei-side-figure figure">
              <img src="../facsimile/${facs}.png" class="figure-img img-fluid rounded"/>
              <figcaption class="figure-caption">Faksimile S. ${n}</figcaption>
            </figure>`
  })

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
    let otherDesc = $(':not(.tei-figDesc, .tei-graphic)', el).html()

    return `
<figure class="figure text-center">
  <img src="../images/${volume}/${ $('.tei-graphic', el).data('url')}.png" class="figure-img img-fluid rounded">
  <figcaption class="figure-caption">
    ${figDesc}
  </figcaption>
  ${otherDesc ? otherDesc : '' }
</figure>`
  })

  // footnotes: TODO
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
  $('.tei-persName').wrap( function() {
    let target = $(this).data('ref').replace(/^#/, '')
    return $('<a/>').attr('href', `/dingler/persons/${target}.html`)
  })

  // links to articles
  $('.tei-ref[data-target]').wrap( function() {
    let target = $(this).data('target').replace(/^#/, '')
    return $('<a/>').attr('href', `/dingler/articles/${target}.html`)
  })

  // table styling
  $('.tei-header table').addClass('table table-condensed table-striped')

  // formulas
  $('.tei-formula').each( function() {
    let el = $(this)
    el.html( '$' + el.html() + '$' )
    let id = "id-" + Math.random().toString(16).slice(2)
    el.attr('id', id )
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, id])
  })

  // link to XML source
  let file = window.location.href.match(/\/([^/]+)\.html/)
  if ( file )
    $('#xml-source').attr( 'href', `/dingler/articles/${file[1]}.xml` )

  // search
  $('#search-error').hide()

  let searchParams = new URLSearchParams(window.location.search)
  let q = searchParams.get('q')
  if ( q && q.replace(/^\s+|\s+$/,'').length > 0 ) {
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

    let dstar = 'https://kaskade.dwds.de/dstar/dingler/dstar.perl'
    $.ajax({
      url: dstar,
      data: { q: qf, fmt: 'json', limit: limit, start: start },
    }).done( function(data) {
      let head = `<div class="result-head mb-2 text-center">${data.nhits_} Treffer gefunden</div>`

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
        let fragment = h.ctx_[1].map( (k,i) => (i!=0 && k.ws==1 ? ' ' : '') + _h(k.w) ).slice(0, 3).join('')
        let div = `
<div class="hit mb-3">
  <div class="hit-bibl">
    <span class="hit-no">${parseInt(data.start) + i + 1}.</span>
    <a href="articles/${_u(_h(h.meta_.basename.replace(/\.orig$/,'')))}.html#:~:text=${_u(_h(fragment))}">${_h(h.meta_.bibl)}</a>
  </div>
  <div class="hit-text">
    ${ h.ctx_[1].map( (k,i) => (i!=0 && k.ws==1 ? ' ' : '') + (k.hl_==1 ? '<b>' : '') + _h(k.w) + (k.hl_==1 ? '</b>' : '') ).join('') }
  </div>
</div>`
        hits.push( div)
      })
      $('#results').html( head + pager + hits.join('') )
    }).fail( function(a, b, c) {
      let msg = a.responseText.match(/<pre>(.*?)<\/pre>/s)
      $('#search-error').html( msg[1] ).show()
    })
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
