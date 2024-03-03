extern printf
extern fflush


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
		arr dq 1.2, 5.6, 3.45, 19.34 , 5.32 , 8.42
		len dq 7
		sum dq 0
		fmt db "%fl" , NL , 0
		mindif dq 0
		mytemp dq ""                  ; gharare moghayese beshe ba mindif
		myfirst dq ""
		mysecond dq ""
		fortest dq 0
		temppr dw 0
	
section .bss
		i resb 8
		j resb 8
		mystr resb 100
section .text
        global main
        

main:
		push rbp


		fld qword [arr]
		fsub qword [arr+8]
		fabs
		mov rax , [arr]
		mov [myfirst] , rax
		mov rax , [arr+8]
		mov [mysecond] , rax
		fstp qword [mindif]

		mov r8 , 0
		dec r8
myloop1:
		inc r8
		mov rcx , [len]
		dec rcx
		dec rcx
		cmp r8 , rcx     ; ta yeki be akhari bayad bere
		je bfExit
		mov r9 , r8
		fld qword [arr+r8*8]
myloop2:
	


		fst st0
		inc r9
		cmp r9 , [len]        ; ta akhari mitoone bere
		je gomyloop1
		
		fsub qword [arr+r9*8]
		fabs
		fst qword [mytemp]
		fld qword [mindif]
		fcomi st0 , st1
		jle notmin
		
		fstp qword [mytemp]
		
		fist dword [temppr]

		fstp qword [mindif]

		
		jmp myloop2

		

notmin:
		fstp qword [mindif]
		fstp qword [mytemp]
		jmp myloop2

gomyloop1 :
		fstp qword [mytemp]         ; raha kardan douplicate
		fstp qword [mytemp]         ; raha kardan aslesh
		jmp myloop1


bfExit:
		mov rdi , fmt
		movq xmm0 , qword [mindif]
		mov rax , 1
		call printf
		
		
		
		pop rbp
	
Exit:
	xor  edi, edi
	call fflush
        mov rax ,60
        xor rdi,rdi
        syscall