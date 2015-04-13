express = require 'express'
bodyParser = require 'body-parser'
compression = require 'compression'
RSVP = require 'rsvp'
path = require 'path'
build = require './utils/build'
app = express()
port = 8000

# db connection

dbConfig = require('./knexfile')[process.env.NODE_ENV or 'development']
knex = require('knex') dbConfig


# middleware

app.use bodyParser.urlencoded
  extended: true

app.use bodyParser.json()

app.use compression()


# helper for getting slogans from db

fetchSlogans = ->

  knex.select 'id', 'slogan', 'user', 'created_at'
  .from 'slogans'
  .orderBy 'created_at', 'desc'


# helper for sending errors

app.use (req, res, next) ->

  res.sendError = (status, error) ->
    res.status(status).json
      error: error

  next()


# set up views

app.set 'view engine', 'jade'


# index (past slogans)

app.get '/', (req, res) ->

  before = req.query.before
  sloganQuery = fetchSlogans()

  if before then sloganQuery.where 'id', '<', before

  sloganQuery.limit 40
  .then (returnedSlogans) ->
    res.render 'index',
      title: 'Sloganator History'
      slogans: returnedSlogans


# current slogan

app.get '/current', (req, res) ->

  fetchSlogans()
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
    fetchSlogans()
    .where('id', result[0])

  .then (returnedSlogans) ->
    unless returnedSlogans[0] then return RSVP.reject()
    res.json
      slogan: returnedSlogans[0]

  .catch (error) ->
    console.log 'error', error
    res.sendError 500, 'database error'


# example

app.get '/example', (req, res) ->
  res.render 'example'


# static files

RSVP.resolve().then ->
  if process.env.NODE_ENV == 'production'
    RSVP.resolve './dist'
  else
    Brocfile = require './Brocfile.coffee'
    build Brocfile
.then (buildDirectory) ->
  # scripts and stuff
  app.use express.static(buildDirectory)

  # start server

  app.listen port, ->
    console.log "listening on port #{port}"

.catch (error) ->
  console.log 'error building client files', error
