module.exports = (env) ->
  env = env or process.env.NODE_ENV or 'development'
  port = process.env.PORT or 8000
  url = process.env.SLOGANATOR_URL or "localhost:#{port}"
  minSloganLength = 5
  maxSloganLength = 255
  minUserLength = 5
  maxUserLength = 255

  env: env
  url: url
  port: port
  minSloganLength: minSloganLength
  maxSloganLength: maxSloganLength
  minUserLength: minUserLength
  maxUserLength: maxUserLength
  client:
    url: url
    minSloganLength: minSloganLength
    maxSloganLength: maxSloganLength
