# Witness Puzzles

## Bugs

1. The bottom of the tool bar buttons gets cut off.
1. The hover on the tool bar buttons looks bad. The label is not part of the button highlight.
1. Sometimes when changing the puzzle size, the window size does not properly adjust. This leaves an undesired white border around the image.
1. The properties window does not close when the document window is closed.
1. The sliders on the properties window do not update their labels.
1. A line width of 1 causes drawPuzzle and drawFinishes to misbehave.

## TODO

### Flesh out this README document.

1. Start with an introduction describing the game, the purpose of this app, and the rationale for developing it.
1. Next a description of the puzzles, the puzzle types, and their elements.
1. Then a description of the interface to the program and how to use it.
1. Finally a description of the implementation and some acknowledgements.

### Functional

1. Add more tetris shapes.
1. Make an icon for the app.
1. Can the IconType enum be eliminated by type introspection?

### GUI

#### User feedback on editing

1. Make the trigger point for finishes be the actual finish instead of the "origin".
1. If done properly this would remove the need to choose the direction.

#### Sidebar

1. Top justify the controls for consistency.
1. Consider having it always visible with all options on display.

#### Miscellaneous

1. The sliders on the properties window are horrible.  They are difficult to see and hence use.  There must be a way to make them better.
1. Make the picker buttons for tetris all the same size. Probably will require a custom picker.
1. The properties window needs its size adjusted.
1. Modify the title of the properties window to show which window it pertains to.
