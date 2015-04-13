loadEarlier = $('.load-earlier')
loadEarlier.removeAttr 'disabled'

$('.load-earlier').on 'click', ->
  lastID = $('li:last-child').attr('data-slogan-id')
  nanoajax.ajax "/?before=#{lastID}", (statusCode, responseText) ->
    newItems = $(responseText).filter('ul').html()
    if newItems.length > 0
      $('ul.slogans').append newItems
    else
      loadEarlier.attr 'disabled', 'true'
