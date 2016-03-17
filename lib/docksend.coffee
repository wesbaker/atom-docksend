opener = require 'opener'
fs     = require 'fs'
{CompositeDisposable} = require 'atom'

module.exports = Docksend =
  subscriptions: null
  config:
    less:
      type: 'object'
      title: 'Less'
      order: 1
      properties:
        enableUpload:
          title: 'Upload related Less files'
          type: 'boolean'
          default: false
        extensions:
          title: 'Extensions of related Less files'
          type: 'string'
          default: '.css, .min.css'
    sass:
      type: 'object'
      title: 'Sass'
      order: 2
      properties:
        enableUpload:
          title: 'Upload related Sass files'
          type: 'boolean'
          default: false
        extensions:
          title: 'Extensions of related Sass files'
          type: 'string'
          default: '.css, .min.css'
    minifiedJavascript:
      type: 'object'
      title: 'Minified Javascript'
      order: 3
      properties:
        enableUpload:
          title: 'Upload related Javascript files'
          type: 'boolean'
          default: false
        extensions:
          title: 'Extensions of related Javascript files'
          type: 'string'
          default: '.min.js'

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add(
      atom.commands.add(
        'atom-workspace',
        'docksend:docksend': => @docksend()
      )
      atom.commands.add(
        'atom-workspace',
        'docksend:docksendDirectory': => @docksendDirectory()
      )
    )

  deactivate: ->
    @subscriptions.dispose()

  docksend: ->
    editor = @getEditor()

    if atom.config.get('Docksend.less.enableUpload')
      @uploadRelatedFiles(
        editor.getPath(),
        '.less',
        atom.config.get('Docksend.less.extensions')
      )
    if atom.config.get('Docksend.sass.enableUpload')
      @uploadRelatedFiles(
        editor.getPath(),
        '.scss',
        atom.config.get('Docksend.sass.extensions')
      )
    if atom.config.get('Docksend.minifiedJavascript.enableUpload')
      @uploadRelatedFiles(
        editor.getPath(),
        '.js',
        atom.config.get('Docksend.minifiedJavascript.extensions')
      )

    opener ['-a', 'Transmit', '-g', editor.getPath()]

  docksendDirectory: ->
    editor = @getEditor()

    # Clean up the title to escape anything for the regular expression
    title = editor.getTitle().replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
    re    = new RegExp(title + "$", "g")
    dir   = editor.getPath().replace(re, '')

    opener ['-a', 'Transmit', '-g', dir]

  uploadRelatedFiles: (file, extension, relatedExtensions) ->
    relatedExtensions = relatedExtensions.split(',').map((s) -> s.trim())
    extension = extension.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
    for relatedExtension in relatedExtensions
      re = new RegExp(extension + '$', 'g')
      file = file.replace(re, relatedExtension)
      fs.access(
        file,
        fs.F_OK,
        (err) ->
          opener ['-a', 'Transmit', '-g', file] unless err
      )

  # Get the current pane item or editor for use in sending files
  #
  # @return [Object] Either a Pane object or a TextEditor object
  getEditor: ->
    editor = atom.workspace.getActiveTextEditor()

    if editor != undefined
      if editor.isModified()
        editor.save()
    else
      editor = atom.workspace.getActivePaneItem()

    return editor
