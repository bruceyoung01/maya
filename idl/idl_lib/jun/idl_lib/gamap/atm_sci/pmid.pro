; $Id: pmid.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        PMID   (function)
;
; PURPOSE:
;        Given the pressures at the vertical edges of a model grid,
;        return the pressures at the centers of the grid.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = PMID( EDGE )
;
; INPUTS:
;        EDGE -> Vector of pressures or pressure-altitudes at
;             the edges of the model grid [hPa]
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        RESULT -> The vector of pressures at the grid centers [hPa]
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The relationship between sigma centers and sigma edges is
;        as follows:
;   
;              MID[N] = ( EDGE[N] + EDGE[N+1] ) / 2.0
;
;        where EDGE[N] is the lower sigma edge, and EDGE[N+1]
;        is the upper sigma edge of the box with center MID[N].
;
; EXAMPLE:
;        Result = PMID( [ 1000.0, 800.0, 600.0, 400.0 ] )
;        print, Result
;            900.000      700.000      500.000
;
; MODIFICATION HISTORY:
;        bmy, 17 Jun 1999: VERSION 1.00
;        bmy, 22 Oct 1999: VERSION 1.44
;                          - Now use SHIFT to compute the average
;                            between successive edges
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine pmid"
;-------------------------------------------------------------


function PMid, Edge
 
   ;====================================================================
   ; Error checking / Keyword settings
   ;====================================================================
   if ( N_Elements( Edge ) eq 0 ) then begin
      Message, 'Must supply pressure or pressure-alt edges!', /Continue
      return, -1
   endif
 
   ;====================================================================
   ; Sort EDGES in descending order (PMID)
   ; Do the interation as described above
   ; RESULT will have one more element than PMID (obviously!)
   ;====================================================================
   Edge   = Reverse( Edge( Sort( Edge ) ) )

   N      = N_Elements( Edge )
   Result = ( Edge[0:N-1] + ( Shift( Edge, -1 ) )[0:N-2] ) * 0.5

   ;====================================================================
   ; Test to make sure that all elements of RESULT are monotonically
   ; decreasing.  If not, then the surface pressure does not 
   ; correspond to the pressure levels.  Print a warning message.
   ;====================================================================
   Test = ( Shift( Result, 1 ) - Result )[1:*]
   if ( Min( Test ) lt 0 ) then begin
      Message, 'WARNING!  PMID contains negative numbers!', /Continue
      Message, 'Make sure PE is correctly specified!',   /Continue
      print, Result
      return, -1
   endif

   ;====================================================================
   ; Return to calling program
   ;====================================================================
   return, Result
 
end
