utils = require './utils'

sloganator =

  baseURL: ''

  sloganScript: $ '#sloganator'
  sloganContainer: $ '<div class="sloganator-container"></div>'
  slogan: $ '<span class="slogan"></p>'
  historyLink: $ '<a href="/" target="_blank"> slogan history</a>'
  sloganInput: $ '<input class="slogan-input">'


  init: ->
    @insertElements()
    @bindEvents()


  fetchSlogan: (cb) ->
    nanoajax.ajax @baseURL + '/current', cb


  getInputValue: ->
    @sloganInput.val()


  postSlogan: (cb) ->
    nanoajax.ajax
      url: @baseURL + '/'
      method: 'POST'
      body: "slogan[slogan]=#{@getInputValue()}&slogan[user]=roo"
    , cb


  insertElements: ->
    utils.hide @sloganInput
    utils.hide @historyLink

    @sloganContainer
    .append @slogan
    .append @sloganInput
    .append @historyLink

    @sloganScript.after @sloganContainer

    @fetchSlogan (statusCode, responseJSON) =>
      response = utils.tryParse responseJSON
      @updateSlogan response.slogan


  saveSlogan: (cb) ->
    slogan = @getInputValue()
    if !slogan or slogan.length < 5 then return
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

    @sloganContainer.on 'mouseover', =>
      utils.show @historyLink

    @sloganContainer.on 'mouseout', =>
      utils.hide @historyLink


sloganator.init()
