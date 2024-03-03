
%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
 
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000

    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif

; Read a signed number from keybord and return in rax and write it to consol as a string
; using syscall

;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:  

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9  
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall 
    
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
; rsi : zero terminated string start 
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx

    pop     rax
    pop     rcx
    pop     rbx
    ret
;-------------------------------------------



section .data
      mysp db " " , 0
      directory db "this", 0
      folder dq "" , 0
      newDirc  db "new2" , 0
      newFold dq "" , 0
      newfile dq "" , 0
      nename dq "this is new", 0
      test7 dq "just write this please" , 0

section .bss
      myread resq 3000
      endbuf resq 1
      names resb 20000
      dfname resb 1
      curfilename resb 20000
      namesLen resq 1
      fileCount resq 1
      bufferread resb 1000
      filedisc resq 1
      tempname resq 1
      curFileExact resb 20000
      bufBetween resb 20000000
      readLen resq 1

section .text
      global _start

_start:
   mov rax , 0
   mov [fileCount] , rax
   mov     rax, 2
   mov     rsi, 65536
   mov     rdi, directory
   syscall
   mov [folder] , rax

   call writeNum
   call newLine

   mov rax , 217
   mov rdi , [folder]
   mov rsi , myread
   mov rdx , 2000
   syscall
   mov [endbuf] , rax
   call writeNum
   call newLine

   xor rdx , rdx
   mov r11 , myread
   add [endbuf] , r11
   mov r15 , 0
   dec r15
   mov r8 , 0
   dec r8
   mov r9 , 0
   dec r9
readall : 
   inc r15
   add rdx , r11
   cmp rdx , [endbuf]
   jge end_read
   xor r11 , r11
   mov r11w , [rdx+16]           ; size of structure
   mov rax , r11

   mov r12 , rdx
   add r12 , 18
   xor r13 , r13
   mov r13b , [r12]                ; r13 if 4 means directory if 8 
   mov rax , r13

   cmp r13 , 8
   inc r12                         ; r12 is name
   cmp r13 , 4
   je readall
writeName:
   inc r8
   inc r9
   mov al , [r12+r8]
   call writeNum
   call newLine
   cmp al , 0
   je endWriteName
   mov [names+r9] , al
   jmp writeName

endWriteName:
   mov rcx , [fileCount]
   inc rcx
   mov [fileCount] , rcx
   inc r9
   mov al , 0
   mov [names+r9] , al
   mov rax , r8
   call newLine
   xor rax , rax
   xor r8 , r8
   dec r8
   jmp readall





end_read:
   mov [namesLen] , r9
   mov r8 , 0
   dec r8
myenloop:
   inc r8
   cmp r8 , r9
   je befchapter2
   mov al , [names+r8]
   cmp al , 0
   je myenloopa
   mov [dfname] , al
   mov rsi , dfname
   call printString
   jmp myenloop
   
myenloopa:
   call newLine
   jmp myenloop



befchapter2:



   ;;;;;;;;;;;;;;;;;; make directory
   mov rax , 83 
   mov rsi , 0q777
   mov rdi , newDirc
   syscall
   mov [newFold], rax


   mov r10 , 0
   dec r10
   mov r12 , 0
   dec r12
chapter2:

   call newLine
   
   inc r10
   cmp r10 , [fileCount]
   je Exit
   mov r8 , 0         ; on directory name
   dec r8
   mov r9 , 0          ; on current file name
   dec r9

ch2loop:
   inc r8
   inc r9
   mov al , [directory+r8]
   cmp al , 0
   je ch2enddir
   mov [curfilename+r9] , al
   jmp ch2loop
ch2enddir: 
   mov al ,'/'
   mov [curfilename+r9] , al

   mov r15 , 0
   dec r15
ch2loop2:
   inc r15
   inc r9
   inc r12
   mov al , [names+r12]
   mov [curfilename+r9] , al
   mov [curFileExact+r15] , al
   cmp al , 0
   je ch2loop2End
   jmp ch2loop2
   


ch2loop2End:
   xor r15  , r15
   push r9
   push rax
   dec r9
   mov al , [curfilename+r9]


   cmp al , 'p'
   jne oner12
   dec r9 
   mov al , [curfilename+r9]


   cmp al , 'm'
   jne twor12
   dec r9
   mov al , [curfilename+r9]


   cmp al , 'b'
   jne threer12
   jmp wasBmp

oner12:
   pop rax
   pop r9
   
   jmp notBmp

twor12:
   pop rax
   pop r9
   jmp notBmp

threer12:
    pop rax
   pop r9
   jmp notBmp

wasBmp:
   pop rax
   pop r9



   inc r12
   mov rsi , curfilename
   call printString
   call newLine

   mov rdi , curfilename
   mov rax, sys_open
   mov rsi, O_RDWR
   syscall
   call writeNum
   call newLine
   mov [filedisc] , rax

   ;seekFile for knowing structure
   mov rdi , [filedisc]
   mov rsi , 14
   mov rdx , 0
   mov     rax, sys_lseek
   syscall

   ;read from file
   mov rdi , [filedisc]
   mov rax, sys_read
   mov rsi , bufferread
   mov rdx , 4
   syscall




  ; create new file in new folder for rewriting
    ; rdi : file name; rsi : file permission
    mov rdi , curFileExact
    mov  rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
   mov [newfile] , rax
   call writeNum
   call newLine




   readFile:
      ; rdi : file descriptor ; rsi : buffer ; rdx : length
      mov rsi , bufBetween
      mov rax, sys_read
      mov rdx , 20000000
      mov rdi,[filedisc]
      syscall
      ; return number of read byte in rax
      mov [readLen] , rax
      call writeNum
      call newLine



   writeFile:
      ; rdi : file descriptor ; rsi : buffer ; rdx : length
      mov rsi , bufBetween
      mov rdx , [readLen]
      mov rdi , [newfile]
      mov     rax, sys_write
      syscall









   mov r13 , 0
   dec r13

printbuf:
   inc r13
   cmp r13 , 1
   je chapter2
   mov al , [bufferread+r13]
   call writeNum

   jmp printbuf


notBmp:
   inc r12
   jmp chapter2
Exit:
   mov rax ,60
   xor rdi,rdi
   syscall
    