loadEarlier = $('.load-earlier')
loadEarlier.removeAttr 'disabled'

$('.load-earlier').on 'click', ->
  lastID = $('li:last-child').attr('data-slogan-id')
  nanoajax.ajax "/?before=#{lastID}", (statusCode, responseText) =>

    firstMatch = responseText?.match(/<ul[^>]+>/)[0]
    firstPosition = responseText?.indexOf(firstMatch) + firstMatch?.length
    firstCut = responseText?.slice firstPosition
    secondMatch = firstCut?.match(/<\/ul>/)[0]
    matchPos = firstCut?.indexOf secondMatch
    secondCut = firstCut?.slice 0, matchPos

    if secondCut?.trim().length > 0
      $('ul.slogans').append secondCut
    else
      loadEarlier.attr 'disabled', 'true'
