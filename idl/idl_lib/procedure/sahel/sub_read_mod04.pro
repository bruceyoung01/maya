;
; Purpose of this program is to use HDF to read MOD04 product
;


PRO sub_read_mod04, Filedir, filename, $
		flat,flon,aod,dbaod,np,nl


; check if this file is a valid HDF file
if not hdf_ishdf(filedir + filename) then begin
   print, 'Invalid HDF file ...'
   return
endif else begin
;   print, 'Open HDF file : ' + filename
endelse


; the SDS var name we're interested in
; NOTE: AOD(Optical_Depth_Land_And_Ocean)
;       FAOD(Optical_Depth_Small_Land)
;       DBAOD(Deep_Blue_Aerosol_Optical_Depth_550_Land)
SDSvar = strarr(12)
SDSvar = [ 'Latitude', 'Longitude',                    $
;          'Optical_Depth_Small_Land',                 $
           'Optical_Depth_Land_And_Ocean',             $
           'Deep_Blue_Aerosol_Optical_Depth_550_Land']

; get hdf file id
FileID = Hdf_sd_start(filedir + filename, /read)
for  i = 0, n_elements(SDSvar)-1 do begin
  thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
  thisSDS = hdf_sd_select(FileID, thisSDSinx)
   hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                 Ndims = nd, hdf_type = SdsType

     ; dimension information
      for kk = 0, nd-1 do begin
        DimID =   hdf_sd_dimgetid( thisSDS, kk)
        hdf_sd_dimget, DimID, Count = DimSize, Name = DimName
        if ( i eq 0 ) then begin 
        if ( kk eq 0) then np  = DimSize    ; dimension size
        if ( kk eq 1) then nl  = DimSize
	endif
      endfor

      ; end of entering SDS
       hdf_sd_endaccess, thisSDS
      if ( i ge 2 ) then begin
        scaleinx = HDF_SD_ATTRFIND(thisSDS, 'scale_factor')
        offsetinx = HDF_SD_ATTRFIND(thisSDS, 'add_offset')
        hdf_sd_attrinfo, thisSDS, scaleinx, Data = scale
        hdf_sd_attrinfo, thisSDS, OffsetInx, Data = offset
      endif

      ; get data
       hdf_sd_getdata, thisSDS, Data
       if ( i eq 0 ) then  flat  = data
       if ( i eq 1 ) then  flon  = data
       if ( i eq 2 ) then  AOD   = scale(0) * (data + offset(0))
       if ( i eq 3 ) then  DBAOD = scale(0) * (data + offset(0))
   endfor
  ; end the access to sd
   hdf_sd_end, FileID
END
