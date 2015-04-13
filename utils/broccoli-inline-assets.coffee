Filter = require 'broccoli-filter'
cheerio = require 'cheerio'
fs = require 'fs'
path = require 'path'
glob = require 'glob'

class InlineAssets extends Filter

  extensions: ['html']
  targetExtension: 'html'

  constructor: (@inputTree, @options={}) ->

    super @inputTree, @options
    @files = @options.files


  write: (readTree, destDir) ->

    readTree(this.inputTree).then (srcDir) =>

      for file, assets of @files

        @listToGlobList srcDir, [file]
        .forEach (globbedPath) =>
          htmlPath = path.join srcDir, path.dirname(globbedPath)
          globbedAssets = @listToGlobList htmlPath, assets, srcDir
          delete @files.file
          @files[globbedPath] = globbedAssets

      super readTree, destDir


  canProcessFile: (relativePath) ->
    super(relativePath) and @files[relativePath]?


  processString: (string, filePath) ->
    replacer = @createReplacer string, filePath

    replacer.replace 'script[src]',
      ($script) -> $script.attr 'src',
      (source) -> """<script type="text/javascript">#{source}</script>"""

    replacer.replace 'link[rel=stylesheet]',
      ($style) -> $style.attr 'href',
      (source) -> """<style type="text/css">#{source}</style>"""

    replacer.html()


  listToGlobList: (rootDir, inputList, outputRoot) ->
    outputRoot = outputRoot or rootDir
    inputList.reduce (memo, pattern) ->
      glob.sync path.join(rootDir, pattern)
      .reduce (memo, file) ->
        memo.push path.relative(outputRoot, file)
        memo
      , memo
    , []


  readFromTree: (filePath) ->

    fs.readFileSync path.join(@inputTree.tmpDestDir, filePath)


  createReplacer: (string, filePath) ->

    $: cheerio.load string

    htmlDir: path.dirname filePath

    filePath: filePath

    filter: @

    replace: (selector, getSourceFile, newEl) ->
      @$(selector).each (key, element) =>
        $el = @$ element
        sourceFile = @filter.htmlPathToRelPath @htmlDir, getSourceFile($el)
        if sourceFile in @filter.files[@filePath]
          src = @filter.readFromTree sourceFile
          $el.before(@$(newEl("\n#{src}\n"))).remove()

    html: -> @$.html()


  htmlPathToRelPath: (dir, htmlPath) ->
    if htmlPath[0] == '/'
      htmlPath[1..]
    else
      if dir == '.'
        htmlPath
      else
        path.relative '.', path.resolve(dir, htmlPath)


module.exports = (inputTree, options)->
  new InlineAssets inputTree, options
