# Docksend

Upload files using Transmit's Docksend in [Atom](https://atom.io).

## Installation

    apm install docksend

## Usage

Press `ctrl-u` to upload the file you're currently editing. If the file has
modifications, it will be saved before uploading.

If you're using [Emmet](https://atom.io/packages/emmet), they have a keyboard
shortcut that will conflict with Docksend. In that case, you can either use the
context menu, the Packages menubar item, or change the keyboard shortcut in your
own keymapping. To change your own keymapping:

1. Go to Atom -> Open Your Keymap
2. Paste in the following code:

        'atom-text-editor:not([mini])':
            'ctrl-u': 'docksend:docksend'
