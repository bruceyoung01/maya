;Amy Gehring
;METR465 
;Homework 3 Problem 1

;PRO hw3p1

;************************************NEW CODE*************************************

So=1368. ;solar constant in Wm^-2
day=FINDGEN(365)+1
F=FLTARR(365,181)
;latn=FLTARR(365)
;lats=FLTARR(365)
y=FLTARR(181)
;tnight=FLTARR(365)

FOR i=0, 180 DO BEGIN

	lat=(i-90.)*!dtor
 	y[i]=(i-90)
	
	FOR j=0, 364 DO BEGIN

	delta=-23.45*!dtor*cos((day[j]+10.)/365*2*!pi)
	delta2=-23.45*cos((day[j]+10.)/365*2*!pi)
	ar=1.+0.034*cos(((day[j]-3.)/365.)*2.*!pi)
	tnight=90-abs(delta2)
			
			if (y[i] GE tnight) then begin
				if (delta GE 0.0) then begin
					H = !pi
				endif else begin
					H = 0.0
				endelse
			endif else if (abs(y[i]) GE tnight) then begin
				if (delta LE 0.0) then begin
					H = !pi
				endif else begin
					H = 0.0
				endelse
			endif else begin
				H = acos(-tan(lat)*tan(delta))
			endelse

			Q = (So/!pi) * ar * (H*sin(lat)*sin(delta) + cos(lat)*cos(delta)*sin(H))
			F[j,i] = Q

ENDFOR
ENDFOR

; calculate the total solar energy received at Lincoln per m2

; define days for each Month
Mons = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

; define the starting Julian day for each month
MonJD = fltarr(13)
for i = 1, 12 do begin
MonJD[i] = Mons[i-1] + MonJD[i-1]
endfor
 
; define the latitude of Lincoln 40.8, -96.67
LNKLAT = 40.8
LNKLatinx =fix((LNKLAT + 90))

; calculate the monthly mean solar Flux at Lincoln
FLNK = fltarr(12)
for i = 0, 11 do begin
  FLNK[i] = mean(F[MonJD[i]:MonJD[i+1]-1, LNKLATinx])
endfor

; read in 10yr-average T
nouse = ' '
TLNK = fltarr(12)
a=0.0
c=0.0
openr, 1, 'Lincoln_2001_2010_MontlyTAVG.txt'
readf, 1, nouse
readf, 1, nouse
for i = 0, 11 do begin
 readf, 1, a, c
TLNK[i] = c
endfor
close, 1 

; read cloud fraction
readcol, 'Lincoln_cloud_frac_2001_2010.txt', time, cldfrc, $
     format='A, f', skipline=7
tmp=fltarr(10)
cldfrcm = fltarr(12)
for i = 0, 11 do begin
 for j  = i, 9*12+i, 12 do begin
  tmp(j/12) = cldfrc(j)
 endfor
 result = where(tmp gt 0)
 cldfrcm(i) = mean(tmp(result))
endfor

set_plot, 'ps'
device, filename = 'LNKT_F.ps', xoffset = 0.5,$
    yoffset=0.5, xsize = 7.5, ysize = 10, /color, bits = 8, $
    /inches 
r = [255, 0, 255,   0,   0]
g = [255, 0,   0, 255,   0]
b = [255, 0,   0,   0, 255]
tvlct, r, g, b

; plot the T and flux
; monthy array
m=findgen(12)+1
!p.multi = [0, 1, 1]
!p.charsize=1
plot,[0.5, 12.5], [20, 80], xtitle = 'mon', $
       ytitle = 'T (F)',  color=1, xrange = [0.5, 12.5], $
       yrange = [20, 80], xstyle=1, ystyle=1, /nodata, $
       title='2001-2010 averages of montly mean T,!C cloud fraction, and solar flux density', $
       position = [0.1, 0.5, 0.9, 0.9], xtickv=findgen(12)+1, xticks=11 
 plots, m, TLNK, psym = 5, color=2,  symsize=2
 oplot, m, TLNK, color=2 

; plot solar flux in right y-axis
; change right y-axis definition
axis, yaxis=1, yrange = [0, 600], ystyle=1, color=1, /save, $
         ytitle='Solar flux density (Wm!u-2!n)', yticks=6 
 plots, m, FLNK, psym = 4,  symsize=2, color=3
 oplot, m, FLNK, color=3

 plots, m, FLNK*(1-cldfrcm), psym = 4,  symsize=2, color=4
 oplot, m, FLNK*(1-cldfrcm), color=4

; write legend
 plots, 4, 130, psym=5, color=2, symsize=2
 xyouts, 4.5, 130, color=2, 'Temperature (F)'
 plots, 4, 100, psym=4, color=3, symsize=2
 xyouts, 4.5, 100, color=3, 'Clear-Sky  Solar Flux Density'

 plots, 4, 70, psym=4, color=4, symsize=2
 xyouts, 4.5, 70, color=4, 'All-Sky Solar Flux Density'


; conduct the scatter plot
!p.multi = [0, 1, 3]
!p.charsize=2
plot, [0, 600], [20, 80], /nodata, yrange = [20, 80], xrange=[0, 600], xstyle=1, ystyle=1, $
    ytitle = '2001-2010 averages of monthly T (F)', $
     xtitle = 'Clear-sky monthly-mean downward solar flux density (Wm!u-2!n)', $ 
     color=1
plots, FLNK, TLNK, psym=4, color=2
xyouts, 20, 70, 'R = ' + string(correlate( FLNK, TLNK), format='(f5.2)'), color=1
 
plot, [0, 1], [20, 80], /nodata, yrange = [20, 80], xrange=[0.3, 0.9], xstyle=1, ystyle=1, $
    ytitle = '2001-2010 averages of monthly T (F)', $
     xtitle = 'Monthly cloud fraction from MODIS', color=1 
plots,  cldfrcm, TLNK, psym=4, color=2
xyouts, 0.35, 30, 'R = ' + string(correlate( cldfrcm, TLNK), format='(f5.2)'), color=1

plot, [0, 1], [20, 80], /nodata, yrange = [20, 80], xrange=[0, 400], xstyle=1, ystyle=1, $
    ytitle = '2001-2010 averages of monthly T (F)', $
     xtitle = 'All-sky monthly-mean downward solar flux density (Wm!u-2!n)', color=1 
plots, (1-cldfrcm)*FLNK, TLNK, psym=4, color=2
xyouts, 20, 70, 'R = ' + string(correlate((1-cldfrcm)*FLNK, TLNK), format='(f5.2)'), color=1

print, correlate(TLNK, FLNK)
print, correlate(TLNK, cldfrcm)
print, correlate(TLNK, (1-cldfrcm)*FLNK)
device, /close


END                                         
