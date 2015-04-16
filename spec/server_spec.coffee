request = require 'supertest'
proxyquire = require('proxyquire').noCallThru()
RSVP = require 'rsvp'

returnedSlogan =
  slogan: 'hey my slogan'
  user: 'yousername'
  created_at: new Date()

returnedSlogans = [
  returnedSlogan
]

config = require '../config'

appFn = proxyquire '../server',
  'knex': ->
    where: -> @
    then: -> @
  'express-rate-limit': -> (req, res, next) ->
    next()

app = appFn config

app.set 'fetchSlogans', ->
  where: -> @
  then: (fn) ->
    fn returnedSlogans

app.set 'insertSlogan', ->
  then: (fn) ->
    fn [1]

describe 'server', ->
  it 'accepts properly formatted input', (done) ->
    sentSlogan = 
      slogan: 'hey you there'
      user: 'username'
      created_at: new Date()
    request(app).post('/').send
      slogan: sentSlogan
    .expect(200)
    .end done

  it 'rejects a short slogan', (done) ->
    returnedSlogan.slogan = '.'
    request(app).post('/').send
      slogan: returnedSlogan
    .expect(422)
    .end done

  it 'rejects a long slogan', (done) ->
    for i in [0..300]
      returnedSlogan.slogan += '.'
    request(app).post('/').send
      slogan: returnedSlogan
    .expect(422)
    .end done

  it 'rejects a short username', (done) ->
    returnedSlogan.slogan = 'hey you there'
    returnedSlogan.user = ''
    request(app).post('/').send
      slogan: returnedSlogan
    .expect(422)
    .end done

  it 'rejects a long username', (done) ->
    for i in [0..300]
      returnedSlogan.user += '.'
    request(app).post('/').send
      slogan: returnedSlogan
    .expect(422)
    .end ->
      done()

  it 'filters out most tags', (done) ->
    returnedSlogan.user = 'roo'
    returnedSlogan.slogan = '<script>alert(\'hax --;\');</script>'
    request(app).post('/').send
      slogan: returnedSlogan
    .expect (res) ->
      return
    .end done
