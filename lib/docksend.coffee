mac_open = require 'mac-open'
{CompositeDisposable} = require 'atom'

module.exports = Docksend =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'docksend:docksend': => @docksend()

  deactivate: ->
    @subscriptions.dispose()

  docksend: ->
    editor = atom.workspace.getActiveTextEditor()

    if editor != undefined
      if editor.isModified()
        editor.save()
    else  
      editor = atom.workspace.getActivePaneItem()

    mac_open editor.getPath(), { a: "Transmit", g: true }
