; purpose of this program : plot the LST with fire
@/home/bruce/program/idl/arslab4/plot_emission_subroutine_LST_fire_no_monthly.pro

  n = 30
  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filelist = '200304al5lst'
  filelist1= '200304al5lst_fire'
;  filelist    = 'slist'
  
  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename

  filename1 = STRARR(n)
  READCOL, filedir + filelist1, F = 'A', filename1
 
;  date = STRARR(n)
;  For i = 0, n-1 DO BEGIN
;  date(i) = STRMID(filename(i), 0, 17)
;  ENDFOR

  np = 1354
  nl = 2030
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)
  grid_lst     = FLTARR(gridsize_lat*gridsize_lon)

  FOR k = 0, n-1 DO BEGIN
  OPENR, lun, filedir + filename(k), /get_lun
  grid_lat1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_count1= FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  count1 = 0

  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    PRINT, i
    READF, lun, tmplat, tmplon, tmplst,count1
    PRINT, '111111', tmplat, tmplon, tmplst
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
    grid_count1(i)= count1
  ENDFOR
  FREE_LUN, lun

  OPENR, lun1, filedir + filename1, /get_lun
  grid_lat2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_count1= FLTARR(gridsize_lat*gridsize_lon)
  tmplat2 = 0.0
  tmplon2 = 0.0
  tmplst2 = 0.0
  count2  = 0

  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun1, tmplat2, tmplon2, tmplst2, count2
    grid_lat2(i) = tmplat2
    grid_lon2(i) = tmplon2
    grid_lst2(i) = tmplst2
    grid_count2(i)= count2
  ENDFOR
  FREE_LUN, lun1

  grid_lst = grid_lst2 - grid_lst1

  sgrid_lst = WHERE(grid_lst gt 0.0, nsgrid_lst)
  ;PRINT, grid_lst(sgrid_lst)
  ;PRINT, 'DDDDD : ', grid_lst
  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + filename + '_dl5.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine_LST_fire_no_monthly, grid_lat1, grid_lon1,  maxlat, minlat, maxlon, minlon, grid_lst, filename

  DEVICE, /close
  CLOSE, 2

  END

