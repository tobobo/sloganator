express = require 'express'
bodyParser = require 'body-parser'
compression = require 'compression'
limit = require 'express-rate-limit'
RSVP = require 'rsvp'
path = require 'path'
sanitizeHTML = require 'sanitize-html'
build = require '../utils/build'
cors = require '../utils/cors'

module.exports = (config) ->

  app = express()

  # db connection

  dbConfig = require('../knexfile')[process.env.NODE_ENV or 'development']
  knex = require('knex') dbConfig


  # middleware

  app.use bodyParser.urlencoded
    extended: true

  app.use bodyParser.json()

  app.use compression()

  app.use cors(['localhost', 'treefort54.com'])


  # helper to validate string length

  lengthOOB = (str, minLength, maxLength, minMessage, maxMessage) ->
    if !str or !str.length or str.length < minLength then minMessage
    else if str.length > maxLength then maxMessage


  # helpers for db

  app.set 'fetchSlogans', ->
    knex.select 'id', 'slogan', 'user', 'created_at'
    .from 'slogans'
    .orderBy 'created_at', 'desc'


  app.set 'insertSlogan', (newSlogan) ->
    newSlogan.created_at = knex.raw('current_timestamp')
    knex.insert(newSlogan).into('slogans').returning('id')


  # helper for sending errors

  app.use (req, res, next) ->

    res.sendError = (status, error) ->
      res.status(status).json
        error: error

    next()


  # set up views

  app.set 'view engine', 'jade'
  app.locals.pretty = true
  app.locals.config = config


  # client builder

  app.set 'initStatic', ->
    RSVP.resolve().then ->

      # build static files
      if process.env.NODE_ENV == 'production'
        RSVP.resolve './dist'
      else
        Brocfile = require '../Brocfile.coffee'
        build Brocfile

    .then (buildDirectory) ->

      # route static files
      app.use express.static buildDirectory
      RSVP.resolve buildDirectory



  # index (past slogans)

  app.get '/', (req, res) ->

    before = req.query.before
    sloganQuery = app.get('fetchSlogans')()

    if before then sloganQuery.where 'id', '<', before

    sloganQuery.limit 40
    .then (returnedSlogans) ->
      res.render 'history',
        title: 'Sloganator History'
        slogans: returnedSlogans


  # current slogan

  app.get '/current', (req, res) ->

    app.get('fetchSlogans')()
    .limit 1
    .then (returnedSlogans) ->
      res.json
        slogan: returnedSlogans[0]


  # create slogan

  app.post '/', limit(), (req, res) ->

    newSlogan = req.body.slogan

    if !newSlogan.user or !newSlogan.slogan
      res.sendError 422, 'need username and slogan'

    newSlogan.slogan = sanitizeHTML newSlogan.slogan,
      allowedTags: ['strong', 'em']
      allowedAttributes: {}

    newSlogan.user = sanitizeHTML newSlogan.user,
      allowedTags: []
      allowedAttributes: {}

    if sloganOOB = lengthOOB(
      newSlogan.slogan,
      config.minSloganLength,
      config.maxSloganLength,
      'ur slogan is t00 $h0rt!',
      'I\'m not reading that long bullshit'
    ) then return res.sendError 422, sloganOOB

    if userOOB = lengthOOB(
      newSlogan.user,
      config.minUserLength,
      config.maxUserLength,
      'why is your username so short',
      'that is not a real username'
    ) then return res.sendError 422, userOOB

    app.get('insertSlogan') newSlogan
    .then (result) ->
      unless result[0] then return RSVP.reject()
      app.get('fetchSlogans')()
      .where('id', result[0])

    .then (returnedSlogans) ->
      unless returnedSlogans[0] then return RSVP.reject()
      res.json
        slogan: returnedSlogans[0]

    .catch (error) ->
      console.log 'error', error, error?.stack
      res.sendError 500, 'database error'


  # example page to show it off

  app.get '/example', (req, res) ->
    res.render 'example'


  app
