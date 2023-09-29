# Witness Puzzles

## Bugs

1. The bottom of the tool bar buttons gets cut off.
1. The hover on the tool bar buttons looks bad. May have to create custom images instead of system ones.
1. Sometimes when changing the puzzle size, the window size does not properly adjust. This leaves an undesired white border around the image.

## TODO

### Flesh out this README document.

1. Start with an introduction describing the game, the purpose of this app, and the rationale for developing it.
1. Next a description of the puzzles, the puzzle types, and their elements.
1. Then a description of the interface to the program and how to use it.
1. Finally a description of the implementation and some acknowledgements.

### Functional

1. Make the default puzzle on File -> New more attractive.
1. Add more tetris shapes.
1. Make an icon for the app.
1. Can the IconType enum be eliminated by type introspection?

### GUI

#### User feedback on editing

1. Maybe on hover show what would be added or deleted.
1. This could remove the need for the direction sheet on finishes.

#### Move away from sheets

1. Possibly an expanded toolbar to hold the options.
1. More likely a sidebar would look better.
1. This way you set the options and just click in the puzzle to add with no need for a popup.
1. A seperate window for properties would then allow a live update of the puzzle.

#### Miscellaneous

1. The sliders on the properties sheet are horrible.  They are difficult to see and hence use.  There must be a way to make them better.
1. Move the solid/hollow choice to the top since it is always visible.
1. Make the picker buttons for tetris all the same size. Probably will require a custom picker.