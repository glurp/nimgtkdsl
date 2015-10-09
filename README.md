## GTK_DSL

A DSL for building simple GUI nim application.
Based on gtk.

From now, only Button, Label, DrawingArea, V/HBox
## Principes
### stack

stack put widget in vertically order :
```nim
"title of window".gtk_app(200,230):  # 200,300 : minimum width/heigth of the window
  stack:
      label "A "
      label "B "
```
this create 2 labels , each one share the verticale space when the windo
is resizable (by mouse action)

### flow

Flow put widget horizontally :

```nim
"title of window".gtk_app(200,230):  # 200,300 : minimum width/heigth of the window
  flow:
      label "A "
      label "B "
```
### *i commands

Using *i commande, the widget use only necessary space for his display.
```nim
"title of window".gtk_app(200,230):  # 200,300 : minimum width/heigth of the window
  stack:
      labeli "A "
      label "B "
```
This create a label "A', an fill the bottom window with the label B.
resiing the window, A keep his space, B expand to all space disponible.

Other example: a text pannel with two button bottom :
```nim
"title of window".gtk_app(200,230):  # 200,300 : minimum width/heigth of the window
  stack:
      label "A "
      flowi:
        button("A")
        button("B")
```
A label take all space, a line of buttons  is keeping at button.





## TODO

* objectify (too much globals variables)
* add style
* support a bunch of widget
* tests unit
* not yet a nimble module...
