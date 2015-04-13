broccoli = require 'broccoli'
RSVP = require 'rsvp'
chalk = require 'chalk'
path = require 'path'
printSlowTrees = require 'broccoli-slow-trees'

module.exports = (tree) ->

  RSVP.resolve()
  .then ->
    builder = new broccoli.Builder(tree);
    builder.build()

  .then (hash) ->
    printSlowTrees hash.graph
    RSVP.resolve hash.directory

  .catch (error) ->
    console.log chalk.red('error building client files')
    if error?.stack?
      console.log error.stack
    else if error?
      console.log error
    RSVP.reject error
