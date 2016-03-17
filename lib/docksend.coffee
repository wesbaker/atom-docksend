opener = require 'opener'
fs     = require 'fs'
{CompositeDisposable} = require 'atom'

module.exports = Docksend =
  subscriptions: null

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
