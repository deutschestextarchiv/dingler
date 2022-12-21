$( function() {
  // link to page images
  $('.tei-pb[data-facs]').append( function(i, str) {
    let facs = $(this).data('facs')
    let n    = $(this).data('n')
    return `<figure class="tei-side-figure figure">
              <img src="../facsimile/${facs}.png" class="figure-img img-fluid rounded"/>
              <figcaption class="figure-caption">Faksimile S. ${n}</figcaption>
            </figure>`
  })

  // footnotes: TODO
  // $('.tei-note[data-place="bottom"]')

  // links to articles
  $('.tei-ref[data-target]').wrap( function() {
    let target = $(this).data('target').replace(/^#/, '')
    return $('<a/>').attr('href', `/dingler/articles/${target}.html`)
  })

  // table styling
  $('.tei-header table').addClass('table table-condensed table-striped')

  // link to XML source
  let file = window.location.href.match(/\/([^/]+)\.html/)
  if ( file )
    $('#xml-source').attr( 'href', `../data/${file[1]}.xml` )

})
