; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

           org     8000h
           lbr     0ff00h
           db      'save',0
           dw      9000h
           dw      endrom+3000h
           dw      6000h
           dw      endrom-6000h
           dw      6000h
           db      0

           org     6000h
           br      start

include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0

start:     ldi     high msg            ; display header
           phi     rf
           ldi     low msg
           plo     rf
           sep     scall               ; get start address
           dw      o_msg
           ldi     high startmsg       ; point to start prompt
           phi     rf
           ldi     low startmsg
           plo     rf
           sep     scall               ; get start address
           dw      input
           sep     scall               ; convert to binary
           dw      f_hexin
           ghi     rd                  ; move number
           phi     rc
           phi     r9
           glo     rd
           plo     rc
           plo     r9
           glo     rc                  ; save RC
           stxd
           ghi     rc
           stxd
           ldi     high endmsg         ; point to start prompt
           phi     rf
           ldi     low endmsg
           plo     rf
           sep     scall               ; get start address
           dw      input
           sep     scall               ; convert to binary
           dw      f_hexin
           irx                         ; recover RC
           ldxa
           phi     rc
           ldx
           plo     rc
           glo     rc                  ; subtract first number from second
           str     r2
           glo     rd
           sm
           plo     r8
           ghi     rc
           str     r2
           ghi     rd
           smb
           phi     r8
           inc     r8                  ; r8 now has count
           ldi     high execmsg        ; point to start prompt
           phi     rf
           ldi     low execmsg
           plo     rf
           sep     scall               ; get start address
           dw      input
           sep     scall               ; convert to binary
           dw      f_hexin
           ghi     rd                  ; transfer exec address
           phi     ra
           glo     rd
           plo     ra
           ldi     high fnamemsg       ; point to start prompt
           phi     rf
           ldi     low fnamemsg
           plo     rf
           sep     scall               ; get start address
           dw      input
fnamelp:   lda     rf                  ; get byte
           smi     33                  ; look for space or less
           lbdf     fnamelp            ; loop until found
           dec     rf                  ; set terminator
           ldi     0
           str     rf
           ldi     high cmdheader      ; point to command header
           phi     rf
           ldi     low cmdheader
           plo     rf
           ghi     r9                  ; store load address
           str     rf
           inc     rf
           glo     r9
           str     rf
           inc     rf
           ghi     r8                  ; store count
           str     rf
           inc     rf
           glo     r8
           str     rf
           inc     rf
           ghi     ra                  ; store start address
           str     rf
           inc     rf
           glo     ra
           str     rf
     
           sep     scall               ; reset buffer address
           dw      getbuffer
           ldi     3                   ; flags, create if non-existant
           plo     r7
           ldi     high fildes         ; get file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           sep     scall               ; open file
           dw      o_open
           lbnf    filegood            ; jump if no error on open
           ldi     high errmsg
           phi     rf
           ldi     low errmsg
           plo     rf
           sep     scall
           dw      o_msg
           sep     sret                ; return to os

filegood:  ldi     high cmdheader      ; point to command header
           phi     rf
           ldi     low cmdheader
           plo     rf
           ldi     0                   ; need to write 6 bytes
           phi     rc
           ldi     6
           plo     rc
           sep     scall               ; write command header
           dw      o_write
           ghi     r9                  ; transfer load address
           phi     rf
           glo     r9
           plo     rf
           ghi     r8                  ; transfer count
           phi     rc
           glo     r8
           plo     rc
           sep     scall               ; write body
           dw      o_write
           sep     scall               ; close the file
           dw      o_close
           sep     sret                ; return to os
           
           
input:     sep     scall               ; display the prompt
           dw      o_msg
           sep     scall               ; get input buffer
           dw      getbuffer
           sep     scall               ; get input from user
           dw      o_input
           ldi     high crlf           ; display a crlf
           phi     rf
           ldi     low crlf
           plo     rf
           sep     scall
           dw      o_msg
           sep     scall
           dw      getbuffer
           sep     sret                ; return to caller

getbuffer: ldi     high dta            ; point to buffer
           phi     rf
           ldi     low dta
           plo     rf
           sep     sret

msg:       db      'File dump utility'
crlf:      db      10,13,0
startmsg:  db      'Start address : ',0
endmsg:    db      'End address   : ',0
execmsg:   db      'Exec address  : ',0
fnamemsg:  db      'Filename      : ',0
errmsg:    db      'Error',10,13,0
cmdheader: dw      0                   ; load address
           dw      0                   ; length
           dw      0                   ; start address

fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

dta:       ds      512

