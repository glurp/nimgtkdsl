import
  re, os
 
include gtk_dsl

################################################################
#            M A I N
################################################################

"Test gui".gtk_app(200,230):
  stack:
    flowi:
      button "clear",proc () =
        echo("eee")
        echo(".")
    flow:
      button  "gtk-open",proc () = (echo "button image!!") 
      image  "gtk-close" 
      image  "gtk-help" 
    labeli  "RRRRR " 
    flowi:
      labeli "A "
      labeli "B "
      flowi:
          button "e",proc () =  (echo("eee") ; echo("aaa"))
          button "r"
      label "C---- "
    buttoni "\nExit\n",proc () =  (main_quit())
  