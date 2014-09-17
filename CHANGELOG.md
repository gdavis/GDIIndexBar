# GDIIndexBar CHANGELOG

## 0.3.5
* Trigger a redraw of the view when reloading the index bar.

## 0.3.4

* Only notify the delegate of index changes when the index actually changes between touch events. (thanks to Guillaume Algis <guillaume.algis@gmail.com>)

## 0.3.3

* Changes the index bar to only redraw when the size has changed. Improves performance when scrolling. (thanks to Donald Pinckney <donald_pinckney@icloud.com>)
* Redraw the index bar with orientation changes. (thanks to Guillaume Algis <guillaume.algis@gmail.com>)
* Fixes Travis build errors

## 0.3.2

* Adds keyboard listeners and updates the layout when the keyboard shows/hides.

## 0.3.1

* Fixes a crash that would occur when clicking on the truncated text string

## 0.3.0

* Adds functionality to truncate the index rows and display '•' characters where rows have been truncated in order to fit the height of the table view. 
* Adds truncatedRowText property.

## 0.2.0

* Adds appearance selectors for properties
* Adds tests for properties and appearance properties

## 0.1.0

Initial release.
