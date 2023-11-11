# Witness Puzzles

## Introduction

This program is a tool to help with playing the game [The Witness](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game)), an excellant game requiring exploration, discovery, and solving puzzles. The puzzles essentially consist of finding a valid path from a start point to an end point in a maze like structure.

While all the puzzles can be solved in the game, the solution to some of the more difficult ones is easier to find when working with a drawing of the puzzle. Many times I would take a screenshot of a puzzle and work on it in a graphics editting program. Bur with some of the puzzles even that was impractical and I found myself creating replicas of the puzzles and working on the replicas.  The **Witness Puzzles** program is meant to simplify that process.

Even though I had completed the game, I thought that creating **Witness Puzzles** would be a fun way to learn how to use [SwiftUI](https://developer.apple.com/xcode/swiftui/) to create a Mac GUI application.

## Bugs

1. The bottom of the tool bar buttons gets cut off.
1. The hover on the tool bar buttons looks bad. The label is not part of the button highlight.
1. Sometimes when changing the puzzle size, the window size does not properly adjust. This leaves an undesired white border around the image.

## TODO

### Flesh out this README document.

1. After the introduction a description of the puzzles, the puzzle types, and their elements.
1. Then a description of the interface to the program and how to use it.
1. Finally a description of the implementation and some acknowledgements.

### Functional

1. Add more tetris shapes.
1. Can the IconType enum be eliminated by type introspection?

### GUI

#### Sidebar

1. Top justify the controls for consistency.
1. Consider having it always visible with all options on display.

#### Miscellaneous

1. The sliders on the properties sheet are horrible.  They are difficult to see and hence use.  There must be a way to make them better.
1. Make the picker buttons for tetris all the same size. Probably will require a custom picker.
