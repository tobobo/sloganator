filterCoffeescript = require 'broccoli-coffee'
funnel = require 'broccoli-funnel'
mergeTrees = require 'broccoli-merge-trees'
concat = require 'broccoli-concat'
browserify = require 'broccoli-browserify'
uglifyJS = require 'broccoli-uglify-js'

nanoajax = funnel 'node_modules/nanoajax',
  srcDir: '/'
  files: ['nanoajax.min.js']
  destDir: '/'

domtastic = funnel 'node_modules/domtastic',
  srcDir: '/'
  files: ['domtastic.min.js']
  destDir: '/'

vendor = mergeTrees [nanoajax, domtastic]

client = funnel 'client',
  srcDir: '/'
  include: ['*.coffee']
  destDir: '/'

client = filterCoffeescript client

client = browserify client,
  entries: ['./index']
  outputFile: './client.js'

merged = mergeTrees [client, vendor]

merged = concat merged,
  inputFiles: ['nanoajax.min.js', 'domtastic.min.js', 'client.js']
  outputFile: '/sloganator.js'

if process.env.NODE_ENV == 'production'
  merged = uglifyJS merged

module.exports = merged
