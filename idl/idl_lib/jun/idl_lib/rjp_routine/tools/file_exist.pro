; $Id: file_exist.pro,v 1.2 2004/06/03 18:01:27 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        FILE_EXIST
;
; PURPOSE:
;        FILE_EXIST checks to see whether a specified file
;        can be found on disk, or if it does not exist.
;
; CATEGORY:
;        Error Checking
;
; CALLING SEQUENCE:
;        RESULT = FILE_EXIST(FILE [,OPTIONS])
;
; INPUTS:
;        FILE (str) --> the name of the file to be checked
;
; KEYWORD PARAMETERS:
;        PATH       -> a path string (e.g. the IDL system variable !PATH)
;            or a list (string array) of directory names to be
;            searched for FILE. Under Unix, a trailing '/' is attached
;            to each entry; under Windows, a trailing '\'; under
;            MacOS, a trailing ':'.  VMS is not supported. 
;
;        FULL_PATH  -> returns the path of FILE if found
;            This is not a true systemwide path but rather a combination
;            of a PATH element (which may be relative) and FILE.
;
;        DIRNAMES   -> 
;            This keyword is now replaced by PATH, and should not be
;            used any more.
;
; OUTPUTS:
;        FILE_EXIST returns a 1 if the file is found or 0 otherwise
;        FULL_PATH contains the file path so it can be used to open the file.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        The PATH entries are expanded prior to use, so it is possible to
;        specify e.g. '~mgs/bla.pro'
;        FILE_EXIST will always return the first file it finds that 
;        matches your specification. 
;
; EXAMPLE: 
;        (1)
;        if (FILE_EXIST('file_exist.pro')) then print,'Found it!'
;
;        (2)
;        dirs = [ '../', '~/DATA/' ]
;        ok = file_exist('test.dat',path=dirs,full=path)
;        if (ok) then openr,u1,path
;        ...
;        
; MODIFICATION HISTORY:
;        mgs, 26 Sep 1997: VERSION 1.00
;        mgs, 28 Sep 1997: - added expand_path() in order to digest ~-pathnames
;                          - initializes FULL_PATH with a zero string
;        mgs, 06 Nov 1997: - replaced DIRNAMES by PATH and added 
;                            string seperation if PATH is a path
;                            string with multiple entries
;        mgs, 05 Feb 1998: - bug fix: use expand_path also if only 
;                            filename is given
;        bmy, 13 Mar 2001: TOOLS VERSION 1.47
;                          - now supports Windows, MacOS, and Unix
;                          - cosmetic change, updated comments
;        bmy, 17 Jan 2002: TOOLS VERSION 1.50
;                          - now call STRBREAK wrapper routine from
;                            the TOOLS subdirectory for backwards
;                            compatiblity for string-splitting;
;        bmy, 03 Oct 2003: TOOLS VERSION 1.53
;                          - minor bug fix: FILE must be placed w/in
;                            the call to EXPAND_PATH for IDL 6.0+
;                          - deleted obsolete code from Jan 2002
;        bmy, 28 May 2004: TOOLS VERSION 2.02
;                          - now call MFINDFILE instead of FINDFILE,
;                            since MFINDFILE will call the new
;                            FILE_SEARCH program for IDL 5.5+
;
;-
; Copyright (C) 1997, 2001, 2003, 2004,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine FILE_EXIST"
;-------------------------------------------------------------


function file_exist, FILE, PATH=PATH, FULL_PATH=FULL_PATH, $
       DIRNAMES=DIRNAMES

   ; External functions
   FORWARD_FUNCTION MFindFile

   ;====================================================================
   ; Check for errors and initialize local variables
   ;====================================================================

   full_path = ''

   on_error, 2

   if (n_params() le 0) then begin
      print, 'FILE_EXIST called with wrong number of arguments'
      return,0
   endif

   ; -----------------------------------------
   ; for compatibility copy dirnames into path
   ; -----------------------------------------

   if(n_elements(path) le 0 AND n_elements(dirnames) gt 0) then $
      path = dirnames

   ;====================================================================
   ; Use FINDFILE command to determine if the file exists.
   ; Always search the current directory first
   ;  FINDFILE returns an array...check the first element.
   ;====================================================================

   ;------------------------------------------
   ; Prior to 5/28/04:
   ;result = findfile(expand_path(FILE))
   ;------------------------------------------

   ; Now use MFINDFILE, which is a wrapper for FILE_SEARCH (bmy, 5/28/04)
   Result = MFindFile( Expand_Path( FILE ) )
   if (strlen(result(0)) gt 0) then begin
      full_path = result(0)
      return,1
   endif
       
   ; file not found, if PATH is passed loop through all path entries
   ; convert string to array first and add delimiter if necessary
   if(n_elements(PATH) gt 0) then begin
      NPATH = PATH              ; make work copy  

      ; Now supports Windows, MacOS, Unix/Linux (bmy, 3/13/01)
      case ( StrUpCase( StrTrim( !VERSION.OS_FAMILY, 2 ) ) ) of
         'UNIX'    : trail   = '/'
         'WINDOWS' : trail   = '\'
         'MACOS'   : trail   = ':'
         else      : Message,  '*** Operating system not supported! ***'
      endcase

      if(n_elements(PATH) eq 1) then begin

         ; Need to use STRBREAK for backwards compatibility 
         ; with all prior versions of IDL (bmy, 1/17/02)
         if ( strpos( PATH, ':' ) ge 0 ) then begin
            NPATH = StrBreak( PATH, ':' ) 
         endif else if ( strpos( PATH, ';' ) ge 0 ) then begin
            NPATH = StrBreak( PATH, ';' )
         endif else if ( strpos( PATH, ',' ) ge 0 ) then begin
            NPATH = StrBreak( PATH, ',' )
         endif
      endif
           
      for i=0,n_elements(NPATH)-1 do begin
         len = strlen(NPATH(i))
         if (strmid(NPATH(i),len-1,1) ne trail) then   $
            NPATH(i) = NPATH(i)+trail 
         ;------------------------------------------------------------------
         ; Prior to 10/3/03:
         ; FILE must be inside the call to EXPAND_PATH (bmy, 10/3/03)
         ;result = findfile(expand_path(NPATH(i))+FILE)
         ;------------------------------------------------------------------
         ; Prior to 5/28/04:
         ; Use MFINDFILE, which is a wrapper for FILE_SEARCH (bmy, 5/28/04)
         ;result = FindFile( Expand_Path( NPATH(i) + FILE ) )
         ;------------------------------------------------------------------

         ; Now call MFINDFILE, which will call the new FILE_SEARCH 
         ; for IDL 5.5+ or FINDFILE for IDL 5.4- (bmy, 5/28/04)
         Result = MFindFile( Expand_Path( NPATH(i) + FILE ) )

         if (strlen(result(0)) gt 0) then begin
            full_path = result(0)
            return,1
         endif
      endfor
   endif                        ; PATH contained entries


   return, 0                    ; default, file not found
end
