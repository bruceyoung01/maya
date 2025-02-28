;example of plots to make with output data

;REMEMBER THAT THE OUTPUT FILE (.IDLDAT) IS A DATA STRUCTURE!!!
;to see the contents type "help, spdata, /structure"

;data read directory
dir_data='/research/wang/ljudd/sub_pixel_output/texas/'

;number of files
nf=52 ;this will change

;define filenames
filenames = strarr(nf)

;Read filenames file
openr,1, dir_data + 'filenames.txt'
readf,1,filenames
close,1

;OUTPUT directory for plots
outdir='/research/wang/ljudd/graphics_output/'


;create some simple plots

;SET UP PS FILE 
;name of the ps file
outfile='texas_plots'

    ; set up ps file
    ps_color, filename = outdir+outfile + '.ps'

    myclrtable, red =red, green=green, blue=blue
    clrinx = findgen(n_elements(red))
    tvlct, red, green, blue

    black = clrinx(16)
    nlevel = 42            ; level of colors

    
    !p.background = clrinx(0) ; white
    !p.thick=3 
    !p.charthick=3
    !p.charsize=1.2 

;PLOT 1: map of fire pixels

    ;region to plot...the limits you used when downloading data
    latb=25
    latt=37
    lonw=-107
    lone=-93

    ;total map limits...expand the boundaries
    latbt=latb-5
    lattt=latt+5
    lonet=lone+10
    lonwt=lonw-10

    ; define region
    region = [LATBt, LONWt, LATTt, LONEt]
    position = [0.1, 0.37, 0.9, 0.7]

    Map_set, /continent, /usa, limit = region, $
      position = position, color = black, $
      /label, latlab = region(1), lonlab = region(0), $
      title = 'MODIS Fire Counts'

    plots, [lonw, lone, lone, lonw, lonw], $ 
	 [latb, latb, latt, latt, latb], color = black, thick=10
    
    ;restore each individual data structure and plot fire locations
    ;go through each file
    totfire=0	
    for ff=0, nf-1 do begin	    
    restore, dir_data+filenames(ff)   
	;get lat/lons for only the regional subset
	rdata=where((spdata.flat ge latb and spdata.flat le latt) and $
        	 (spdata.flon ge lonw and spdata.flon le lone), count)
	rdata2=where(spdata.tb11(rdata) gt spdata.pixt11(rdata))
	totfire=totfire+count

	;plot data on map
	if count gt 0 then begin
		plots, spdata.flon(rdata), spdata.flat(rdata), color = 55,psym=sym(1), symsize=.5
		oplot, spdata.flon(rdata2), spdata.flat(rdata2), color = 20, psym=sym(1), symsize=.5	
	endif  
    endfor
	xyouts, .34, .35, 'Total Fire Pixels: '+ string(totfire), color=black, /normal 


Device, /close
STOP


;PLOT 2: compare MODIS FRP to the sub-pixel FRP 
    	 position1 = [0.1, 0.37, 0.9, 0.9]    	
	 title='FRP Comparison'
	 XTITLE = 'MODIS !6FRP!Ip!N (MW)'
	 YTITLE = 'Sub-Pixel !6FRP!If!N (MW)' 
	 range  = [0,1000]
	    PLOT, range, range, YRANGE = range, xrange=range,color=black, $
	    PSYM = 10,title=title,xthick=2, ythick=2,thick=2,$
    		XTITLE = xtitle, YTITLE = ytitle,$
		position=position1, /nodata
		
	;BUILD LOOP HERE...as in the above example
	
	;restore file
	;restore each individual data structure and plot fire locations
    ;go through each file
   	
    for ff=0, nf-1 do begin	    
    restore, dir_data+filenames(ff)
		
	    ;plot data 
	    xdata=spdata.frp_modis
	    ydata=spdata.frp_fire   	    
	    PLOTs,xdata, ydata,color=black,psym=sym(1), symsize=1
    endfor
	;END LOOP HERE

	    ;plot 1 to 1 line
    	    oplot, range,range,color=black,linestyle=2



;PLOT 3: compare the MODIS 11um pixel temp to the 11um background temp
	toterr=0
	 title='Brightness Temperatures (MODIS Fire Pixels)'
	 XTITLE = 'MODIS 11 um Background Brightness Temp. (K)'
	 YTITLE = 'MODIS 11 um Pixel Brightness Temp. (K)'  
	 range=[260,340]  
	    PLOT, range, range, YRANGE = range, xrange=range,color=black, $
	    PSYM = 10,title=title,xthick=2, ythick=2,thick=2,$
    		XTITLE = xtitle, YTITLE = ytitle,$
		position=position1, /nodata 
	
	
	    ;THIS ONE IS A BIT HARDER
	    ;We need the xyouts command to reflect all data not just one file
	    
	    ;START
	    
	    ;restore 
	    for ff=0, nf-1 do begin	    
    	    restore, dir_data+filenames(ff)

	    ;plot data
	    xdata=spdata.tb11
	    ydata=spdata.pixt11   	

    
	    PLOTs,xdata, ydata,color=black,psym=sym(1), symsize=1
	    
	    ;find cases where the background temp is warmer than the mean pixel temp (modis errors)
	    r=where(xdata gt ydata, count)
		toterr=toterr+count
	    if count gt 0 then begin
	    ;plot error pixels in yellow
	    PLOTs,xdata(r), ydata(r),color=50,psym=sym(1), symsize=1
	    ;xyouts, 303, 284, 'Total MODIS Err: '+ '0',color=black	
	    
	    endif  else begin
            
	    
	   
	    endelse

	    endfor

	    ;END
	    xyouts, 303, 284, 'Total MODIS Err: '+ string((toterr),format= '(i3)'),color=black 
	    
	    ;PLOT 1 TO 1 line	
	     oplot, range,range,color=black,linestyle=2
	    
	    ;bottom caption about errors
	    xyouts, 303, 282, 'Total MODIS Pix: '+ string(n_elements(xdata), format= '(i2)'),color=black





device,/close








end
