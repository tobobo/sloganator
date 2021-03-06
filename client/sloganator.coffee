sloganator =
  config: require './config'
  utils: require './utils'

  document: $(document)
  script: $ '#sloganator'
  container: $ '<div class="sloganator-container"></div>'
  slogan: $ '<span class="sloganator-slogan"></span>'
  cancel: $ '<button class="sloganator-cancel">cancel</button>'
  history: $ '<a class="sloganator-history" href="/" target="_blank"> slogan history</a>'
  input: $ '<input class="sloganator-input">'


  init: ->
    @insertElements()
    @bindEvents()


  insertElements: ->
    @utils.hide @input
    @utils.hide @cancel
    @utils.hide @history

    @container
    .append @slogan
    .append @input
    .append @cancel
    .append @history

    @script.after @container

    @fetchSlogan (statusCode, responseJSON) =>
      response = @utils.tryParse responseJSON
      @updateSlogan response.slogan


  bindEvents: ->
    @slogan.on 'click', =>
      @showInput()

    @input.on 'keydown', (e) =>
      if e.keyCode == 27 then return @cancelInput()
      unless e.keyCode == 13 then return
      @saveSlogan()

    @input.on 'focus', =>
      @input[0].select()

    @container.on 'mouseover', =>
      @utils.show @history

    @container.on 'mouseout', =>
      @utils.hide @history

    @cancel.on 'click', =>
      @cancelInput()


  fetchSlogan: (cb) ->
    nanoajax.ajax 'http://' + @config.url + '/current', cb


  postSlogan: (sloganData, cb) ->
    nanoajax.ajax
      url: 'http://' + @config.url + '/'
      method: 'POST'
      body: "slogan[slogan]=#{sloganData.slogan}&slogan[user]=#{sloganData.user}"
    , (statusCode, responseJson) ->
      if statusCode != 200
        response = @utils.tryParse responseJson
        alert(response?.error or 'unknown error')
      cb statusCode, responseJson


  getInputValue: ->
    @input.val()


  getSloganData: ->
    slogan: @getInputValue()
    user: $('span.welcome strong a:first-child').html()


  saveSlogan: (cb) ->
    sloganData = @getSloganData()
    if !sloganData.user
      return alert 'no user, no slogan'
    if !sloganData.slogan or sloganData.slogan.length < @config.minSloganLength
      return alert 'ur slogan is 2 short'
    if sloganData.slogan.length > @config.maxSloganLength
      return alsert 'i am not reading that long bullshit'
    @slogan.html sloganData.slogan
    @showSlogan()
    @postSlogan sloganData, (status, responseJSON) =>
      response = @utils.tryParse responseJSON
      @updateSlogan response.slogan
      if cb? then cb response.slogan


  updateSlogan: (slogan) ->
    @slogan
    .html slogan.slogan
    .attr 'title', "slogan by #{slogan.user} at #{slogan.created_at}"
    @input.val slogan.slogan


  showInput: ->
    @utils.hide @slogan
    @utils.show @cancel
    @utils.show @input
    @utils.focus @input


  showSlogan: ->
    @utils.hide @input
    @utils.hide @cancel
    @utils.show @slogan


  cancelInput: ->
    @input.val @slogan.html()
    @showSlogan()


sloganator.init()
