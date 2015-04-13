filterCoffeescript = require 'broccoli-coffee'
funnel = require 'broccoli-funnel'
mergeTrees = require 'broccoli-merge-trees'
concat = require 'broccoli-concat'
browserify = require 'broccoli-browserify'
uglifyJS = require 'broccoli-uglify-js'


# get dependencies

nanoajax = funnel 'node_modules/nanoajax',
  srcDir: '/'
  files: ['nanoajax.min.js']
  destDir: '/'

domtastic = funnel 'node_modules/domtastic',
  srcDir: '/'
  files: ['domtastic.min.js']
  destDir: '/'

vendorScripts = mergeTrees [nanoajax, domtastic]


# get client scripts

clientScripts = funnel 'client',
  srcDir: '/'
  include: ['*.coffee']
  destDir: '/'

clientScripts = filterCoffeescript clientScripts


sloganator = browserify clientScripts,
  entries: ['./index']
  outputFile: './client.js'

sloganator = mergeTrees [sloganator, vendorScripts]

sloganator = concat sloganator,
inputFiles: ['nanoajax.min.js', 'domtastic.min.js', 'client.js']
outputFile: '/sloganator.js'


history = browserify clientScripts,
  entries: ['./history']
  outputFile: './history.js'


merged = mergeTrees [sloganator, history]


if process.env.NODE_ENV == 'production'
  merged = uglifyJS merged,
    mangle: true


module.exports = merged
