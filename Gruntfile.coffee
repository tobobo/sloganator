module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-exec'

  grunt.initConfig
    exec:
      buildIfProduction:
        cmd: ->
          if process.env.NODE_ENV == 'production' and process.env.LOUDER_BUILD != 'false'
            grunt.log.write "\nBuilding app to ./dist...\n\n"
            "rm -rf dist; node_modules/.bin/broccoli build dist; echo \"\nbuilt app to ./dist !\""
          else
            grunt.log.write "No production, no build."
            ""
