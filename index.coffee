config = require('./config')()
app = require('./server')(config)

app.get('initStatic')().then ->

  # start server
  app.listen config.port, ->
    console.log "listening on port #{config.port}"

.catch (error) ->
  console.log 'error building client files', error
