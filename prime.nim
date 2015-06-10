
import
  math

include gtk_dsl
const
  aM = 800
  aN = 800
  mx= aM*aN
  nP = 1000+int(mx*0.3) # mx/ln(mx) ?
  
proc calculatePrime() : array[nP,int] =
  echo("start prims calculate...")
  result[0]=2
  var pos=1
  var n=3
  var ok: bool
  var max=0
  while pos < nP:
    ok=true
    max=int(math.sqrt(float(n)))
    for i in 0..(pos-1):
      if result[i]>max: break
      if (n %% result[i])==0: ( ok=false ; break )
    if ok:
      if (pos %% 100000)==0:
        echo("[",pos,"] => ",n, "  /",nP)
      result[pos]=n
      pos+=1
    n+=1
  echo("end prims calculate, size=" & $pos & " last=>" & $result[pos-1])



################################################################
#            M A I N : Gui
################################################################


let primes = calculatePrime()
var start = false
var gcv : PWidget
var cpt=0

proc refresh_cairo() =  gcv.queue_draw_area(gint(0),gint(0),gint(aN),gint(aM))

template move(cr:PContext ,n,pos,x,y,dx,dy,len : int): stmt =
  if len>0 and pos<nP:
    for i in 1..len:
      #cr.move_to(float(x),float(y))
      x+=dx
      y+=dy
      #cr.line_to(float(x),float(y))
      #cr.stroke
      if primes[pos]==n:
        cr.rectangle(float(x),float(y),float(1),float(1))
        cr.fill
        pos+=1
        if pos>=nP: break
      n+=1

proc redraw(widget : PWidget) =
  echo "redraw"
  var cr : PContext = widget.window.cairo_create()
  cr.set_source_rgba(0.0, 0.3, 0.1 , 1.0)
  cr.rectangle(0,0,aN,aM)
  cr.fill
  cr.set_source_rgba(1.0, 0.3, 0.1 , 1.0)
  var 
    n=1
    pos=0
    x=int(aN/2)
    y=int(aM/2)
    d=1
    len=d
  while x<aN and y< aM:
      move(cr,n,pos,x,y, 0,-d,len-1)
      move(cr,n,pos,x,y,-d, 0,len)
      move(cr,n,pos,x,y, 0, d,len)
      move(cr,n,pos,x,y, d, 0,len+1)
      if pos==nP: break
      len+=2
  cr.destroy()
  echo "end redraw"

"Primes".gtk_app(aN,aM+30):
  stack:
    canvas(aN,aM):
      handle_expose       proc (widget: PWidget, event: PEventExpose): gboolean {.cdecl.} =
        redraw(widget)
        result=false
    gcv=glastWidget
    flowi:
      frame("ee"):
        button  "gtk-clear",proc () {.gcsafe, locks: 0.} =
          refresh_cairo()
