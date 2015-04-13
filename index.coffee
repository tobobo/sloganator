express = require 'express'
bodyParser = require 'body-parser'
RSVP = require 'rsvp'
app = express()
port = 8000

# db connection

dbConfig = require('./knexfile')[process.env.NODE_ENV or 'development']
knex = require('knex') dbConfig


# middleware

app.use bodyParser.urlencoded
  extended: true

app.use bodyParser.json()


# helper for getting slogans from db

getSlogans = ->

  knex.select 'slogan', 'user', 'created_at'
  .from 'slogans'
  .orderBy 'created_at', 'desc'


# helper for sending errors

app.use (req, res, next) ->

  res.sendError = (status, error) ->
    res.status(status).json
      error: error

  next()


# index (past slogans)

app.get '/', (req, res) ->

  before = req.query.before
  sloganQuery = getSlogans()

  if before then sloganQuery.where 'id', '<', before

  sloganQuery.limit 40
  .then (returnedSlogans) ->
    res.json
      slogans: returnedSlogans


# current slogan

app.get '/current', (req, res) ->

  getSlogans()
  .limit 1
  .then (returnedSlogans) ->
    res.json
      slogan: returnedSlogans[0]

# create slogan

app.post '/', (req, res) ->

  newSlogan = req.body.slogan

  unless newSlogan.user and newSlogan.slogan
    res.sendError 422, 'bad input'

  newSlogan.created_at = knex.raw('current_timestamp')

  knex.insert(newSlogan).into('slogans')
  .then (result) ->
    unless result[0] then return RSVP.reject()
    getSlogans()
    .where('id', result[0])

  .then (returnedSlogans) ->
    unless returnedSlogans[0] then return RSVP.reject()
    res.json
      slogan: returnedSlogans[0]

  .catch (error) ->
    console.log 'error', error
    res.sendError 500, 'database error'


# start server

app.listen port, ->
  console.log "listening on port #{port}"
