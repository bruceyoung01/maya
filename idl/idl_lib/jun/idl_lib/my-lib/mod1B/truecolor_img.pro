;
;  Purpose: plot true color images
; 

PRO truecolor_img, red=red, green=green, blue=blue, $
              flat = flat, flon= flon, mag = mag, $ 
              region = region, winx=winx, winy=winy, $
              outputname = outputname, latdel =latdel, $
              londel = londel, latlab = latlab, $
              lonlab = lonlab, firelat = firelat, $
              firelon = firelon, tornadolat = tornadolat, $
              tornadolon = tornadolon, $
              tornadotime = tornadotime, $
              modtime = modtime 
            
    np = n_elements(red(*,0))
    nl = n_elements(red(0,*))

    if (not keyword_set(region)) then begin
       region = [min(flat)-2, min(flon)-2, max(flat+2), max(flon+2)]
    endif

    if (not keyword_set(OutPutName)) then begin
      print, 'No output file name is specified'
      print, 'File will be saved as jpeg'
      OutPutName = 'overlay' 
    endif

    if (not keyword_set(mag)) then begin
      mag = 1
    endif
 
    if (not keyword_set(winx)) then begin
     winx = 700 
    endif

    if (not keyword_set(winy)) then begin
     winy = 500 
    endif

    if (not keyword_set(londel)) then begin
     londel = 5 
    endif

    if (not keyword_set(latdel)) then begin
     latdel = 5 
    endif
    
    if (not keyword_set(latlab)) then begin
     latlab = region(1)-1.5 
    endif

    if (not keyword_set(lonlab)) then begin
     lonlab = region(0)-1 
    endif

 ; pixel after reprojection, default is white pixel  
   newred = bytarr(winx, winy)+255
   newgreen = bytarr(winx, winy)+255
   newblue = bytarr(winx, winy)+255

 ; MODIS only gives lat and lon not 1km resolution
 ; hence, interpolation is needed to have every 1km pixel
 ; has lat and lon 
   if ( mag gt 1 ) then begin
   red  = congrid(red, np*mag, nl*mag, /interp)
   green= congrid(green, np*mag, nl*mag, /interp)
   blue = congrid(blue, np*mag, nl*mag, /interp)
   flat =  congrid(flat, np*mag, nl*mag, /interp)
   flon =  congrid(flon, np*mag, nl*mag, /interp)
   np = np*mag
   nl = nl*mag
   endif

 ; set up window
   set_plot, 'x'
   device, retain=2
   !p.background=255L + 256L * (255+256L *255)

   window, 1, xsize=winx, ysize=winy
   map_set, latdel = latdel, londel =londel,  $
         /grid, charsize=1.0, mlinethick = 2,$
        limit = region, color = 0, $
        position = [0.05, 0.05, 0.98, 0.98] 

 ; ship coordinate
   imax = 0
   imin = np
   jmin = nl
   jmax = 0
   for i = 0, np-1 do begin
   for j = 0, nl-1 do begin
     if ( flon(i,j) ge region(1) and flon(i,j) le region(3) $
          and flat(i,j) ge region(0) and flat(i,j) le region(2) ) then begin
      result = convert_coord(flon(i,j), flat(i,j), /data, /to_device)
      newcoordx  = result(0)
      newcoordy  = result(1)

      if (newcoordx lt winx and newcoordy lt winy and $
          newcoordx gt 0 and newcoordy gt 0 ) then begin 
         newred(newcoordx, newcoordy) = red(i,j)
         newgreen(newcoordx, newcoordy)=green(i,j)
         newblue(newcoordx, newcoordy) =blue(i,j)
    ;     if ( imax lt i) then imax = i
    ;     if ( imin gt i ) then imin = i
    ;     if ( jmax lt j) then jmax = j
    ;     if ( jmin gt j ) then jmin = j
      endif
     endif
   endfor
   endfor
   print, 'i range', imax, imin
   print, 'j range', jmax, jmin

 ; display the reprojecte image
  tv, [[[newred]], [[newgreen]], [[newblue]]], true=3

 ; redraw the map with noerase opition
   map_set, /noerase, latdel = latdel , londel = londel,  $
         /grid, charsize=1.0, mlinethick = 2,$
         limit = region, color = 0, $
;         latlab = latlab, lonlab = lonlab, $
;         /label, latalign=0, lonalign = 1, $
        position = [0.05, 0.05, 0.98, 0.98]

   map_continents, /hires, /coasts, /usa, color=0
  
 ;  map_grid, latdel = latdel, londel=londel, /box_axes
 
  nxg = (region(3)-region(1))/londel
  nyg = (region(2) - region(0))/latdel
  lats = region(0) + findgen(nyg+1) * latdel
  lons = region(1) + findgen(nxg+1) * londel 
  latlabs = fltarr(nyg+1)+latlab
  lonlabs = fltarr(nxg+1) + lonlab  
  
  xyouts, latlabs, lats, string(lats, format='(I3)'), color=0, align=0.5
  xyouts, lons, lonlabs, string(lons, format='(I4)'), color=0, align=0.5

; plot fire hot spots
  if (keyword_set(firelat) and keyword_set(firelon)) then begin
     result = where(firelon ge region (1) and firelat ge region(0) and $
                    firelon le region(3) and firelat le region(2), count )
      print, 'total fire num: ',count 
      if ( count gt 0 ) then begin      
       plots, firelon(result), firelat(result), psym = sym(1), $
              color = 255
      endif
  endif

; plot tornado events

;  TimePeriod = [0, 4, 8, 12, 16, 20, 24]
;  red   = [0,   0,   0,  255, 255, 76 ]
;  green = [0,   0, 255,  255, 126,  0 ]
;  blue  = [0, 255,   0,    0,   0,  38 ]
 ; colors = red*1L * 256L *(green*1L + 256L * blue*1L)


  if (keyword_set(tornadolat) and keyword_set(tornadolon)) then begin
     result = where(tornadolon ge region (1) and tornadolat ge region(0) and $
                    tornadolon le region(3) and tornadolat le region(2), count )
      print, 'total tornado num: ', count 
      if ( count gt 0 ) then begin     
            for i = 0, count-1 do begin   ; comparing tornado timing with MODIS timing
              inx = result(i)
              
;              result1 = where(TimePeriod ge tornadotime(inx)/100., count1)
;              if count1 lt 0 then stop
;              colorinx = result1(0)-1 
              plots, tornadolon(inx), tornadolat(inx), psym = sym(4), $
                      color = 255L + 256L*(126L + 0), symsize = 2.5 

; the following is plotted the tornado events before and after the
; satellite impages 
;              result1 = where( abs(flat - tornadolat(inx)) le 1 and $
;                              abs(flon - tornadolon(inx)) le 1, count1)
;              if ( count1 ge 0 ) then begin
;                   cnl = result1(0)/np
;                   cnp = result1(0) - cnl*np
;                   print, 'mod lat and lon:', flat(cnp, cnl), flon(cnp, cnl)
;                   print, 'tor lat and lon :', tornadolat(inx), tornadolon(inx) 
;                   print, 'cnl = ', cnl, ' modtime ', modtime(cnl), ' tornadotime ', tornadotime(inx) 
                     
;                   if (modtime(cnl) le tornadotime(inx) ) then begin 
;                      plots, tornadolon(inx), tornadolat(inx), psym = sym(1), $
;                             color = 0L + 256L*(255L + 0), symsize = 2 
;                      print, 'color green'
;                   endif 
                   
;                   if (modtime(cnl) gt tornadotime(inx) ) then begin 
;                      plots, tornadolon(inx), tornadolat(inx), psym = sym(1), $
;                             color = 0L + 256L*(0L + 255L*256), symsize = 2
;                      print, 'color blue'
;                   endif

;             endif else begin
;                      plots, tornadolon(inx), tornadolat(inx), psym = sym(1), $
;                             color = 0L , symsize = 2
;              endelse 

           endfor
     endif
  endif

 ; write image into the file
 ; read current window content 
  image = tvrd(true=3, order=1)

 ; write to tiff
  write_jpeg,  outputname + '.jpg', image, $
               quality = 100, true = 3, order=1

 end
 
