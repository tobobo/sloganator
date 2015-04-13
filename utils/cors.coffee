url = require 'url'

module.exports = (clients) -> (req, res, next) ->
  unless req.headers.referer then return next()

  headerMatches = false
  parsedReferer = url.parse req.headers.referer

  for client in clients
    if parsedReferer.host.match new RegExp("#{client}$", 'i')
      headerMatches = true
      break

  if headerMatches
    res.set
      'Access-Control-Allow-Methods': 'get put delete post options'
      'Access-Control-Allow-Origin': '*'
      'Access-Control-Allow-Headers': 'Content-Type'

  if req.method == 'OPTIONS'
    return res.sendStatus 200

  next()
