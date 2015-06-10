
import
  math

include gtk_dsl

################################################################
#   Abstract Gol
################################################################
const
  aM = 400
  aN = 400

type
 Matrix= array[aM, array[aN, bool]]
 PMatrix = ref  Matrix

type Gol =  ref object of RootObj
  w: int
  h: int
  p1 : ref Matrix
  p2 : ref Matrix

proc makeGol() : Gol =
  result= Gol(w: aM,h: aN,p1:  new(Matrix),p2:  new(Matrix))

method reset(self: Gol)  =
  for row in 0..aM-1:
    for col in 0..aN-1:
      self.p2[row][col]=false

template hypot(a,b : int): expr = math.sqrt(float(a*a+b*b))
method invert(self:Gol,x,y: int) =
  const d=8
  const r=7
  for dy in -d..d:
    for dx in -d..d:
      if x+dx>=0 and y+dy>0:
        if x+dx<self.w and y+dy<self.h:
          if hypot(dx,dy)<r:
            self.p2[y+dy][x+dx]= true

method formula(self : Gol,row,col: int) : bool =
  var nb  = 0
  for dr in -1..1:
    for dc in -1..1:
      if dr!=0 or dc!=0:  nb += (if self.p1[row+dr][col+dc]: 1 else: 0)
      
  result= if self.p1[row][col]:
            nb==2 or nb==3
          else:
            nb==3

method on_tick(self:Gol)  =
  let a= self.p2
  self.p2 = self.p1
  self.p1 = a
  for y in 1..aM-2:
    for x in 1..aN-2:
      self.p2[y][x]= formula(self,y,x)

#proc irandom(max: float) : int =  result = int(math.random( max ))
proc irandom(max: int) : int =    result = int(math.random( float(max) ))

method random(self:Gol) : void =
  var n = irandom(10) + irandom( aN*24 )
  echo("random on ",n, " from ",aN*24)
  for i in 0..n:
    var y=irandom(self.h-1)
    var x=irandom(self.w-1)
    self.p2[y][x] = not self.p2[y][x]


template get(self: Gol,x,y : int) : expr =
  self.p2[y][x]



################################################################
#            M A I N : Gui
################################################################


let gol = makeGol()
var start = false
var gcv : PWidget
var cpt=0

proc refresh_cairo() =  gcv.queue_draw_area(gint(0),gint(0),gint(aN),gint(aM))
proc redraw(widget : PWidget) =
  var cr : PContext = widget.window.cairo_create()
  cr.set_source_rgba(0.0, 0.3, 0.1 , 1.0)
  cr.rectangle(0,0,aN,aM)
  cr.fill
  cr.set_source_rgba(1.0, 0.3, 0.1 , 1.0)
  for y in 1..aM-1:
    for x in 1..aN-1:
      if gol.get(x,y):
        cr.rectangle(float(x),float(y),1.0,1.0)
        cr.fill
  cr.destroy()

"Game of life".gtk_app(aN,aM+30):
  stack:
    canvas(aN,aM):
      handle_expose       proc (widget: PWidget, event: PEventExpose): gboolean {.cdecl.} =
        redraw(widget)
        result=false
      handle_button_press proc (widget: PWidget, event: TEventButton): gboolean {.cdecl.} =
        gol.invert(int(event.x) %% aN ,int(event.y) %% aM)
        refresh_cairo()
      handle_timer 100,    proc(w:PWidget) {.cdecl.} =
        if start:
          gol.on_tick
          refresh_cairo()
    gcv=glastWidget
    flowi:
      frame("ee"):
        button  "gtk-clear",proc () {.gcsafe, locks: 0.} =
          gol.reset()
          refresh_cairo()

        button  "gtk-help",proc () {.gcsafe, locks: 0.} =
          gol.random
          refresh_cairo()

        button  "gtk-open",proc () {.gcsafe, locks: 0.} =
          start=true

        button  "gtk-close",proc () {.gcsafe, locks: 0.} =
          start=false

