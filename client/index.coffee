utils = require './utils'

sloganator =

  sloganatorScript: $ '#sloganator'
  sloganatorContainer: $ '<div class="sloganator-container"></div>'
  slogan: $ '<p class="slogan"></p>'
  sloganInput: $ '<input class="slogan-input">'


  init: ->
    @insertElements()
    @bindEvents()


  getSlogan: (cb) ->
    cb 200, JSON.stringify
      slogan:
        slogan: 'example slog'
        user: 'roo'
        created_at: new Date(Date.now() - 1000*60*60*24)


  postSlogan: (cb) ->
    cb 200, JSON.stringify
      slogan:
        slogan: @sloganInput.val()
        user: 'roo'
        created_at: new Date(Date.now() - 1000*60*60*24)


  insertElements: ->
    utils.hide @sloganInput

    @sloganatorContainer
    .append @slogan
    .append @sloganInput

    @sloganatorScript.after @sloganatorContainer

    @getSlogan (statusCode, responseJSON) =>
      response = utils.tryParse responseJSON
      @updateSlogan response.slogan


  saveSlogan: (cb) ->
    slogan = @sloganInput.val()
    if slogan?.length < 5 then return
    @slogan.html slogan
    @showSlogan()
    @postSlogan (status, responseJSON) =>
      response = utils.tryParse responseJSON
      @updateSlogan response.slogan
      console.log 'slogan posted', response?.slogan
      if cb? then cb response.slogan


  updateSlogan: (slogan) ->
    @slogan
    .html slogan.slogan
    .attr 'title', "slogan by #{slogan.user} at #{slogan.created_at}"
    @sloganInput.val slogan.slogan


  showInput: ->
    utils.hide @slogan
    utils.show @sloganInput
    utils.focus @sloganInput


  showSlogan: ->
    utils.hide @sloganInput
    utils.show @slogan


  bindEvents: ->
    @slogan.on 'click', =>
      @showInput()

    @sloganInput.on 'click', =>
      @showSlogan()

    @sloganInput.on 'keypress', (e) =>
      unless e.keyCode == 13 then return
      @saveSlogan()

    @sloganInput.on 'focus', =>
      @sloganInput[0].select()


sloganator.init()
