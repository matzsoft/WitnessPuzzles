# Witness Puzzles

## Bugs

1. Finishes in cylinder puzzles are not correctly computing valid directions.
1. Cancel on the IconView doesn't create the icon, but it also doesn't reset the settings.

## TODO

### Flesh out this README document.

1. Start with an itroduction describing the game, the purpose of this app, and the rationale for developing it.
1. Next a description of the puzzles, the puzzle types, and their elements.
1. Then a description of the interface to the program and how to use it.
1. Finally a description of the implementation and some acknowledgements.

### Functional

1. Complete the implementation of the tetris icon type.
1. Make an icon for the app.
1. Can the IconType enum be eliminated by type introspection?

### GUI

1. The sliders on the properties sheet are horrible.  They are difficult to see and hence use.  There must be a way to make them better.
1. Need a better way to highlight the active tool in the tool bar.
1. Tried to make the properties sheet do a live update of the document window.  It sort of worked but there were problems:

- Counldn't get the cancel to work properly.
- Changing the dimensions causes the sheet to move out from under the mouse making using the controls difficult.

