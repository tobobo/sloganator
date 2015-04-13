filterCoffeescript = require 'broccoli-coffee'
funnel = require 'broccoli-funnel'
replace = require 'broccoli-string-replace'
mergeTrees = require 'broccoli-merge-trees'
concat = require 'broccoli-concat'
browserify = require 'broccoli-browserify'
inline = require './utils/broccoli-inline-assets'
uglifyJS = require 'broccoli-uglify-js'


# get dependencies

nanoajax = funnel 'node_modules/nanoajax', include: ['nanoajax.min.js']

domtastic = funnel 'node_modules/domtastic', include: ['domtastic.min.js']

vendorScripts = mergeTrees [nanoajax, domtastic]


# get client scripts

clientConfig = JSON.stringify require('./config')().client

clientScripts = funnel 'client', include: ['*.coffee']

clientScripts = replace clientScripts,
  files: ['config.coffee']
  pattern:
    match: '{{{SLOGANATOR_CONFIG}}}'
    replacement: clientConfig

clientScripts = filterCoffeescript clientScripts


sloganator = browserify clientScripts,
  entries: ['./sloganator']
  outputFile: './client.js'

sloganator = mergeTrees [sloganator, vendorScripts]

sloganator = concat sloganator,
inputFiles: ['nanoajax.min.js', 'domtastic.min.js', 'client.js']
outputFile: '/sloganator.js'


history = browserify clientScripts,
  entries: ['./history']
  outputFile: './history.js'


example = browserify clientScripts,
  entries: ['./example']
  outputFile: './example.js'


merged = mergeTrees [sloganator, history, example]


if process.env.NODE_ENV == 'production'
  merged = uglifyJS merged,
    mangle: true


module.exports = merged
