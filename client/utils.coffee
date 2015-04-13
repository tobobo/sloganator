module.exports =
  hide: (els) ->
    els.forEach (el) -> $(el).css 'display', 'none'


  show: (els) ->
    els.forEach (el) -> $(el).css 'display', 'block'


  focus: (els) ->
    els.forEach (el) -> el.focus()

  tryParse: (text) ->
    result = null
    try
      result = JSON.parse text
    catch e
      result = undefined

    return result
