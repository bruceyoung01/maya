
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR AND MARKER PLOT USING 
; WRF/CHEM OUTPUT FILE AND EPA STATION OBSERVATION FILE
; THE STEPS ARE AS FOLLOWING : 
; 1, PLOT THE EPA MARKERS ON THE MAP.
; 2, PLOT THE CONTOUR OF WRF/CHEM OUTPUT.
; 3, OVERLAY THE CONTOUR AND EPA MARKERS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

; OPEN WRF/CHEM OUTPUT FILE
  a = addfile("/media/disk/data/wrfchem/sahel/sahel200802_f/wrfout_d01_2008-02-05_00:00:00.nc","r")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_2008-02-05_sahelf_1")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; The specific pressure levels that we want the data interpolated to.
  pressure = 700   ; pressure levels to plot

; DO TIME LOOP
  do it = 0, 23, 1

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode    = "latlon"
;----------CA------------------------
;  res@mpMinLatF      = 10.0
;  res@mpMaxLatF      = 45.0
;  res@mpMinLonF      = -115.0
;  res@mpMaxLonF      = -65.0
;----------SAHEL---------------------
  res@mpMinLatF      = -20.0
  res@mpMaxLatF      =  40.0
  res@mpMinLonF      = -30.0
  res@mpMaxLonF      =  55.0


; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn            = True
  res@mpGeophysicalLineColor      = "White"
  res@mpNationalLineColor         = "White"
  res@mpUSStateLineColor          = "White"
  res@mpGridLineColor             = "White"
  res@mpLimbLineColor             = "White"
  res@mpPerimLineColor            = "White"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"
  
  map  = gsn_csm_map(wks,res)

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  ;res@gsnLeftString                = "PM2.5 SURFACE MASS CONCENTRATION"
  res@gsnLeftString   = "Height (m) at 700hpa"
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors = True
  ;res@gsnSpreadColorStart = 0
  ;res@gsnSpreadColorEnd   = 200
  res@cnInfoLabelOn        = True
  res@cnInfoLabelFontHeightF = 0.01

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF           = 0.0
  res@cnMaxLevelValF           = 20.0
  res@cnLevelSpacingF        = 2.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.6
  res@pmLabelBarHeightF      = 0.08
  res@lbLabelFontHeightF     = 0.013
  res@lbLabelStride          = 1
  res@lbBoxLinesOn           = False


; SET UP COLOR BAR
  res@tiMainFontHeightF      = 0.02
  res@lbTitleString          = "PM2.5 SURFACE MASS CONCENTRATION (ug m^-3)"
  res@lbTitleFontHeightF     = 0.015
  res@lbTitlePosition        = "Bottom"

; PLOT THE CONTOUR OVER THE CE MAP
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times      = a->Times(it,:)
   pm25       = a->PM2_5_DRY(it,:,:,:)
   pm25@lat2d = a->XLAT(it,:,:)
   pm25@lon2d = a->XLONG(it,:,:)
   res@tiMainString = "WRF/CHEM    PM2.5   " + times
   print(times)

   z  = wrf_user_getvar(a, "z",it)        ; grid point height
   z  = z/10.
   ;ph         = a->PH(it,:,:,:)
   ;phb        = a->PHB(it,:,:,:)
   ;z          = ph(0:26,:,:)+phb(0:26,:,:)
   z@lat2d = a->XLAT(it,:,:)
   z@lon2d = a->XLONG(it,:,:)
   

;  SET UP SUBTITLE
   res@gsnLeftString   = z@description + z@units ;"Height (m) at 700 hpa"

   pa        = a->P(it,:,:,:)
   pb        = a->PB(it,:,:,:)
   p          = pa+pb
   p@lat2d = a->XLAT(it,:,:)
   p@lon2d = a->XLONG(it,:,:)

   z_plane  = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)
; SET UP Z RESOURCES
   res2                                = True
   res2@cnLevelSelectionMode           = "ManualLevels"
   res2@cnMinLevelValF                 = 290.
   res2@cnMaxLevelValF                 = 320.
   res2@cnLevelSpacingF                = 2.
   res2@cnLabelDrawOrder               = "PostDraw"
   res2@cnLineColor                    = "Red"
   res2@cnInfoLabelOn                  = False
   res2@gsnContourLineThicknessesScale = 1.5
   res2@cnLineLabelInterval            = 2
   res2@cnLineLabelsOn                 = True          ; turn on line labels
   map = gsn_csm_contour_map_overlay(wks,pm25(0,:,:),z_plane,map,res,res2)
   delete(res)
   delete(res2)
  end do ; END OF IT LOOP
end
