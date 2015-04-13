express = require 'express'
bodyParser = require 'body-parser'
RSVP = require 'rsvp'
app = express()
port = 8000


dbConfig = require('./knexfile')[process.env.NODE_ENV or 'development']

knex = require('knex') dbConfig


app.use bodyParser.urlencoded
  extended: true

app.use bodyParser.json()


getSlogans = ->

  knex.select 'slogan', 'user', 'created_at'
  .from 'slogans'
  .orderBy 'created_at', 'desc'


app.use (req, res, next) ->

  res.sendError = (status, error) ->
    res.status(status).json
      error: error

  next()


app.get '/', (req, res) ->

  getSlogans()
  .limit 1
  .then (response) ->
    res.json
      slogan: response[0]


app.post '/', (req, res) ->

  newSlogan = req.body.slogan
  unless newSlogan.user and newSlogan.slogan then res.sendError 422, 'bad input'
  newSlogan.created_at = knex.raw('current_timestamp')

  knex.insert(newSlogan).into('slogans')
  .then (result) ->
    unless result[0] then return RSVP.reject()
    getSlogans()
    .where('id', result[0])

  .then (slogans) ->
    unless slogans[0] then return RSVP.reject()
    res.json
      slogan: slogans[0]

  .catch (error) ->
    console.log 'error', error
    res.sendError 500, 'database error'


app.get '/past', (req, res) ->

  getSlogans()
  .limit 40
  .then (response) ->
    res.json
      slogans: response


app.listen port, ->
  console.log "listening on port #{port}"
