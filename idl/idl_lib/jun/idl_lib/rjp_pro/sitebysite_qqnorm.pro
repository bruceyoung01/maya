
pro map_dist, obs, sim, bkg, nat, asi, pos=pos

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  ; Data selecting 

  CASE SPEC OF
   'SO4' : begin
             bkg_fld = bbext_ammso4
             nat_fld = nbext_ammso4
           end
   'NO3' : begin
             bkg_fld = bbext_ammno3
             nat_fld = nbext_ammno3
           end
   'EC'  : begin
             bkg_fld = bbext_ec
             nat_fld = nbext_ec
           end
   'OMC' : begin
             bkg_fld = bbext_omc
             nat_fld = nbext_omc
           end
   'ALL4': begin
             bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
             nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           end
   'ALL' : begin
        ;     bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+0.5+1.8
        ;     nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+0.5+1.8
             bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+soil_bext+cm_bext
             nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+soil_bext+cm_bext
           end
  END

  ; Convert extinction into visibility
  bkg_fld = 10. * Alog( (bkg_fld + 10.) / 10. )
  nat_fld = 10. * Alog( (nat_fld + 10.) / 10. )

  bkg_stat  = stat( bkg, bkg_fld )
  nat_stat  = stat( nat, nat_fld )

  Min_avg = 1.
  Max_avg = 13.

  Min_std = 1.
  Max_std = 7.


 if n_elements(pos) eq 0 then begin
  ;---------------Plotting----------------------;
 !P.multi=[0,2,2,0,0]

 Pos = cposition(2,2,xoffset=[0.05,0.15],yoffset=[0.1,0.1], $
       xgap=0.02,ygap=0.12,order=0)

 end

 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom
 Ndiv   = 7
 Format = '(I3)'
 Unit   = '[dv]'
 csfac  = 1.2

 C_bkg_avg = bytscl( bkg_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_nat_avg = bytscl( nat_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_bkg_std = bytscl( bkg_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

 C_nat_std = bytscl( nat_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

  ;=========================
  ; Distribution of mean 
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

 
  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0]

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, bkg_stat.lon, bkg_stat.Lat, color=c_bkg_avg, psym=8, symsize=symsize

  ;----simulation------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa, $
   /noerase, position=pos[*,1]
  plots, nat_stat.lon, nat_stat.Lat, color=c_nat_avg, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ; colorbar
  dx = pos[2,1]-pos[2,1]*0.8
  CBPosition = [pos[0,0]+dx,pos[1,0]-0.05,pos[2,1]*0.8,pos[1,0]-0.03]
  ColorBar, Max=max_avg,     Min=min_avg,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e


  ;==========================
  ; Distribution of std
  ;==========================

  ;------observation----------
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,2], /noerase

  plots, bkg_stat.lon, bkg_stat.Lat, color=c_bkg_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac , charthick=charthick
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ;------simulation----------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa,$
    position=pos[*,3], /noerase

  plots, nat_stat.lon, nat_stat.Lat, color=c_nat_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ;------colorbar---------------
  dx = pos[2,3]-pos[2,3]*0.8
  CBPosition = [pos[0,2]+dx,pos[1,2]-0.05,pos[2,3]*0.8,pos[1,2]-0.03]
 
  ColorBar, Max=max_std,     Min=min_std,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format, Charsize=csfac,       $
     	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

  x1 = 0.5*(pos[0,0]+pos[2,0])
  x2 = 0.5*(pos[0,1]+pos[2,1])
  y1 = pos[3,0]+0.01

  xyouts, 0.07, 0.95, spec, color=1, charsize=tcharsize, $
   charthick=charthick, /normal, alignment=0.5

  xyouts, x1, y1, 'Background', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y1, 'Natural', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5

  x1 = 0.5*(pos[2,0]+pos[0,1])
  x2 = 0.5*(pos[2,2]+pos[0,3])
  y2 = pos[3,2]+0.01
  xyouts, x1, y1, 'MEAN', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y2, 'STANDARD DEVIATION', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5


  x = pos[0,0]
  str = string(mean(bkg_stat.avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,1]
  str = string(mean(nat_stat.avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  x3 = pos[0,2]
  str = string(mean(bkg_stat.std),format='(f3.1)')
  xyouts, x3, y2, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x4 = pos[2,3]
  str = string(mean(nat_stat.std),format='(f3.1)')
  xyouts, x4, y2, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end


;=======================================================================


 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, cumulative=cumulative, $
     deciview=deciview, position=position, label=label, $
     maxval=maxval, minval=minval

  COMMON SHARE, SPEC, MAXD, MAXP

  if n_elements(maxval) eq 0 then maxval = maxD

  @define_plot_size
  @calc_bext

  Nbins = 100.

  p    = [0.1,0.9]

;  Xtitle = 'B!dext!n (Mm!u-1!n)'

  obs_d = obs_bext
  sim_d = sim_bext
  bkg_d = bkg_bext
  nat_d = nat_bext 
  asi_d = asi_bext

  if keyword_set(deciview) then begin
     obs_d = obs_vis
     sim_d = sim_vis
     bkg_d = bkg_vis     
     nat_d = nat_vis
     asi_d = asi_vis
  endif
   
  if keyword_set(cumulative) then begin

     MinD = Min(obs_d) < Min(sim_d)
     if n_elements(minval) eq 0 then minval = minD

     yrange = [0., MaxD]
     Xtitle = 'dv'
     xrange = [0., 100.]

  end else begin

     MinD = Min(obs_d) < Min(sim_d)
;     yrange = [MinD,MaxD]
     Xtitle = ' '
     yrange = [0., MaxP]
     xrange = [0., MaxD]
     line   = 0
  end

;  out = nan_chk(obs_bext, sim_bext)
;  check, out

;xrange = [-4., 4.]

; title = 'B!dext!n ('+SPEC+') at IMPROVE in the West (<95!uo!nW)'
 title = 'Frequency distribution of B!dext!n at IMPROVE sites'
 title = ' '

  N2S = reverse(sort(obs.lat))

  for N = 0, N_elements(obs)-1 do begin
    data = chk_undefined(10. * Alog( (nat_bext[*,N2S[N]]+10.) / 10. ))

    if N eq 0 then $
    qqnorm, data, position=position, /qline, yrange=yrange, xrange=[-3,3] else $
    qqnorm, data, /over, /qline, color=N+1L

;    halt

  end


;  qqnorm, nat_d, color=4, /over, /qline


 if Keyword_set(Label) then begin
  ;=======Label=========
   format='(f5.1)'
   dx=(xrange[1]-xrange[0])*0.05
   xrange=[-dx,dx]
   dy=(yrange[1]-yrange[0])*0.05
   yval  = yrange[1]+dy*6.5
   dy    = yrange[1]/15.


  label = 'B!dext!n for Sulfate, Nitrate, OMC, EC';, !8Soil, CM!3'
  label = ' '
  xyouts, xrange[1]*0.6, yval+dy, label,$
          color=1, charsize=charsize, charthick=charthick

  charsize=1.
  xyouts, xrange[1]*1.1, yval, '( Mean, STD, p10, p90 )', color=1, $
         charsize=charsize, charthick=charthick

;  plots, xrange, [yval,yval]-0.9*dy, color=1, psym=8, thick=dthick
;  string='('+string(o.mean,format=format)+$
;         ','+string(o.std, format=format)+$
;         ','+string(o.p[0],format=format)+$
;         ','+string(o.p[1],format=format)+$
;         ' ) IMPROVE '
;  xyouts, xrange[1]*1.1, yval-dy, string, color=1, charthick=charthick,$
;          charsize=charsize
;
;  plots, xrange, [yval,yval]-1.9*dy, color=4, psym=8, thick=dthick
;  string='('+string(s.mean,format=format)+$
;         ','+string(s.std, format=format)+$
;         ','+string(s.p[0],format=format)+$
;         ','+string(s.p[1],format=format)+$
;         ' ) Model '
;  xyouts, xrange[1]*1.1, yval-2*dy, string, color=1, charthick=charthick,$
;          charsize=charsize

        plots, xrange, [yval,yval]-0.9*dy, color=1, psym=8, thick=dthick
        string='('+string(d.mean,format=format)+$
               ','+string(d.std, format=format)+$
               ','+string(d.p[0],format=format)+$
               ','+string(d.p[1],format=format)+$
               ' ) Model (bkgn) '
        xyouts, xrange[1]*1.1, yval-1*dy, string, color=1, charthick=charthick,$
                charsize=charsize

        plots, xrange, [yval,yval]-1.9*dy, color=4, psym=8, thick=dthick
        string='('+string(n.mean,format=format)+$
               ','+string(n.std, format=format)+$
               ','+string(n.p[0],format=format)+$
               ','+string(n.p[1],format=format)+$
               ' ) Model (natural) '
        xyouts, xrange[1]*1.1, yval-2*dy, string, color=1, charthick=charthick,$
                charsize=charsize

;        plots, xrange, [yval,yval]-2.9*dy, color=3, psym=8, thick=dthick
;        string='('+string(a.mean,format=format)+$
;               ','+string(a.std, format=format)+$
;               ','+string(a.p[0],format=format)+$
;               ','+string(a.p[1],format=format)+$
;               ' ) Model (no NA) '
;        xyouts, xrange[1]*1.1, yval-3*dy, string, color=1, charthick=charthick,$
;                charsize=charsize

  endif

 return

 end

;============================================================================

  @ctl
  SPEC    = 'ALL4'
  figfile = 'figure09.ps'

  Maxd   = 20.
  Maxp   = 5.
  maxval = Maxd 
;  minval = 1.

  e_bad1 = [13,25,99,35,77,93,114] ; south east coastal
  e_bad2 = [0,86,72,78]
  bad    = e_bad1

  ; east
  mapid = where(newobs.lon gt -95. and newobs.lat gt 35. and newobs.std gt 5. and newobs.mean gt 18.)
  mapid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)

  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.05,0.15],yoffset=[0.15,0.15], $
        xgap=0.01,ygap=0.15,order=0)

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape

  erase


  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,3:4]

  map_dist, newobs(mapid), newsim(mapid), newbkg(mapid), newnat(mapid), newasi(mapid), pos=newpos

  dxx= 0.13

  position = pos[*,5]
  dx = 0.04
  dy = -0.25
  position = [position[0]+dx,position[1]-dy,position[2]+dxx,position[3]-dy]

  deciview=1
  position = [0.63, 0.25, 0.98, 0.75]
  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), nat=newnat(mapid), $
    asi=newasi(mapid), deciview=deciview, position=position, /cumulative, $
    maxval=maxval, minval=minval

  print, '==========Mean altitude============'
  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))


 if !D.name eq 'PS' then close_device

End
