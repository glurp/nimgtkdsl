# LGPL ; Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
import
  re, os, gtk2, gdk2, cairo, glib2

###################################### Engine
############ Stack layout
var
  gstack : seq[PBox] = @[]
  glastWidget : PWidget

proc last[T](st: seq[T]) : T =
  result=st[st.high]

proc push[T](st: seq[T], e: T) : T =
  st.add(e)
  result=e
# pop already defined ...

proc append(w: PWidget,pad: guint=0) : void =
  glastWidget=w
  gstack.last.pack_start(w,true,true,pad)

proc appendi(w: PWidget): void =
  glastWidget=w
  gstack.last.pack_start(w,false,false,0)

proc option() =
  echo("coucou")

############
template gtk_app(title: string,width,height: int,code: stmt): stmt {.immediate.} =
  nim_init()
  let  win = window_new(gtk2.WINDOW_TOPLEVEL)
  let content = vbox_new(true,10)
  win.set_title("Gtk: " & title)
  win.set_default_size(width,height)
  gstack.add(content)
  code
  win.add(content)
  win.show_all()
  discard signal_connect(win, "destroy", SIGNAL_FUNC(mainQuit), nil)
  main()

proc mainQuit(widget: PWidget, data: Pgpointer) {.cdecl.} =
  main_quit()

proc CPWIDGET(obj: pointer): PWidget =
  result = cast[PWidget](obj)

proc CPBOX(obj: pointer): PBox=
  result = cast[PBox](obj)

######################################## Layout

template stack(code: stmt): stmt {.immediate.} =
  let content = vbox_new(false,0)
  append(content)
  apply(content,code)

template flow(code: stmt): stmt {.immediate.} =
  let content = hbox_new(false,0)
  append(content)
  apply(content,code)

template frame(title: string,code: stmt): stmt {.immediate.} =
  let fr = frame_new(title)
  let outer_content = hbox_new(false,0) # frame is not a container, so impact it in box : box>frame>box
  let inner_content = hbox_new(false,0)
  outer_content.add(fr)
  fr.add(inner_content)
  append(outer_content,5)
  apply(inner_content,code)

template stacki(code: stmt): stmt {.immediate.} =
  let content = vbox_new(false,0)
  appendi(content)
  apply(content,code)

template flowi(code: stmt): stmt {.immediate.} =
  let content = hbox_new(false,30)
  appendi(content)
  apply(content,code)

template apply(w:PBox,code: stmt) : stmt {.immediate.} =
  gstack.add(w)
  code
  discard gstack.pop()


################################################## Canvas
var gcurrentCanvas : PWidget

template canvas(width,height: int,code: stmt) : stmt {.immediate.} =
  let cv=  drawing_area_new()
  cv.set_size_request(width, height)
  #cv.can_focus = true
  PWIDGET(cv).add_events(gint(EXPOSURE_MASK + BUTTON_PRESS_MASK + POINTER_MOTION_MASK + BUTTON_RELEASE_MASK + KEY_PRESS_MASK))
  gcurrentCanvas=PWIDGET(cv)
  code
  append( cv )

template handle_expose(pproc: proc) : stmt {.immediate.} =
  discard gcurrentCanvas.signal_connect( "expose-event", SIGNAL_FUNC(pproc), gcurrentCanvas.window)

template handle_button_press(pproc: proc) : stmt {.immediate.} =
  discard gcurrentCanvas.signal_connect( "button-press-event", SIGNAL_FUNC(pproc), gcurrentCanvas.window)

template handle_button_motion(pproc: proc) : stmt {.immediate.} =
  discard gcurrentCanvas.signal_connect( "motion-notify-event", SIGNAL_FUNC(pproc), gcurrentCanvas.window)

template handle_button_release(pproc: proc) : stmt {.immediate.} =
  discard gcurrentCanvas.signal_connect( "button-release-event", SIGNAL_FUNC(pproc), gcurrentCanvas.window)

template handle_Timer(ms: int,pproc: proc) : stmt {.immediate.} =
  discard g_timeout_add(ms, pproc, gcurrentCanvas.window)


################################################## Widgets
proc nulproc() =
  echo("e")

proc bbutton(label: string, f = nulproc ,sloti: bool) =
  var btn = button_new()
  if  (label.existsFile()) or  (label.find(re"^gtk-") > -1):
    var w= if existsFile(label):
        image_new_from_file(label)
      else:
        imageNewFromStock(label, ICON_SIZE_BUTTON)
    btn.set_image(w)
  else:
    btn= button_new(label)
  if f!=nulproc:
    discard btn.signal_connect("pressed", SIGNAL_FUNC(f), btn)
  if sloti:   appendi(btn) else:  append( btn )

proc button(label: string, f = nulproc) =
  bbutton(label,f,false)

proc buttoni(label: string, f = nulproc) =
  bbutton(label,f,true)

proc blabel(label: string,sloti: bool) =
  var btn =if  (label.existsFile()) or  (label.find(re"^gtk-") > -1):
      if existsFile(label):
        image_new_from_file(label)
      else:
        imageNewFromStock(label, ICON_SIZE_BUTTON)
    else:
    label_new(label)
  if sloti:   appendi(btn) else:  append( btn )

proc label(label: string)  =
  blabel(label,false)

proc labeli(label: string)  =
  blabel(label,true)

proc image(name: string)  =
  var w= if existsFile(name):
      image_new_from_file(name)
    else:
      imageNewFromStock(name, ICON_SIZE_BUTTON)
  append( w )

proc pass(n: int = 1) =
   label( "                              " )
