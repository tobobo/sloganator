(
  sloganatorScript: $ '#sloganator'
  sloganatorContainer: $ '<div class="sloganator-container"></div>'
  slogan: $ '<p class="slogan"></p>'
  sloganInput: $ '<input class="slogan-input">'


  hide: (els) ->
    els.forEach (el) -> $(el).css 'display', 'none'


  show: (els) ->
    els.forEach (el) -> $(el).css 'display', 'block'


  focus: (el) ->
    el.forEach -> @[0].focus()

  tryParse: (text) ->
    result = null
    try
      result = JSON.parse text
    catch e
      result = undefined

    return result


  insertElements: ->
    @hide @sloganInput

    @sloganatorContainer
    .append @slogan
    .append @sloganInput

    @sloganatorScript.after @sloganatorContainer

    @getSlogan (statusCode, sloganJSON) =>
      slogan = @tryParse sloganJSON
      @slogan.html slogan.slogan.slogan


  getSlogan: (cb) ->
    cb 200, JSON.stringify
      slogan:
        slogan: 'example slog'
        user: 'roo'
        created_at: new Date(Date.now() - 1000*60*60*24)

  postSlogan: (cb) ->
    cb 200, JSON.stringify
      slogan:
        slogan: 'example slog'
        user: 'roo'
        created_at: new Date(Date.now() - 1000*60*60*24)

  saveSlogan: (cb) ->
    slogan = @sloganInput.val()
    if slogan?.length < 5 then return
    @slogan.html slogan
    @showSlogan()
    @postSlogan (status, sloganJSON) ->
      console.log 'slogan posted', JSON.parse(sloganJSON)

  showInput: ->
    @hide @slogan
    @show @sloganInput
    @sloganInput.get(0).focus()

  showSlogan: ->
    @hide @sloganInput
    @show @slogan

  bindEvents: ->
    @slogan.on 'click', =>
      @showInput()

    @sloganInput.on 'click', =>
      @showSlogan()

    @sloganInput.on 'keypress', (e) =>
      unless e.keyCode == 13 then return
      @saveSlogan()


  init: ->
    @insertElements()
    @bindEvents()


).init()
