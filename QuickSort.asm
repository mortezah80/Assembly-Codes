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
	   Msg1 dq    'low'
	   Msg2 dq    'high'
       Msg3 dq    'Yes'
       Msg4 dq    " "
       Msg5 dq    'befor1 '
       
       Msg6 dq    "after1 "
       Msg7 dq   "parti  "
       Msg8 dq    'befor2 '
       
       Msg9 dq    "after2 "
       Msg10 dq    "qend "

section .bss
		myarr resq 1000000
		lengtharr resq 1

section .text
        global _start
        
_start:
		call readNum 
        mov r8 , rax
        mov r9 , r8
        dec r9
        mov [lengtharr] , r9
        mov r9 , 0
        dec r9
readArr:
		inc r9
		cmp r9 , r8
		je BefquickSort
		call readNum
		mov [myarr+r9*8] , rax
		jmp readArr

bfnextfake:
		push rax
		xor rax , rax
		mov r9 , 0
		dec r9
nextfake:		
		inc r9
		mov rax , [myarr+r9*8]

		cmp r9 , [lengtharr]
		je nextendfake
		jmp nextfake
nextendfake:	
		pop rax
		ret
		

bfnext:
		push rax
		xor rax , rax
		mov r9 , 0
		dec r9
next:		
		inc r9
		mov rax , [myarr+r9*8]
		call writeNum
		mov rsi , Msg4
		call printString
		cmp r9 , [lengtharr]
		je nextend
		jmp next
nextend:	
		pop rax
		ret
		
swap:

		push rbp
		mov rbp , rsp
		mov r8 , [rbp+16]
		mov r9 , [rbp+24]
		mov rax , [myarr+r8*8]

		push r10
		mov r10 , rax
		xor rax , rax
		mov rax , [myarr+r9*8]
		mov [myarr+r8*8] , rax

		xor rax , rax
		mov rax , r10

		mov [myarr+r9*8] , rax

		pop r10
		pop rbp
		ret 16
		
		
partition:
		push rbp
		mov rbp , rsp
		mov r14 , [rbp+16]			;low
		mov rax , r14
		mov r15 , [rbp+24]			;high
		mov rax , r15

		mov rax , [myarr+r15*8]        ;pivot

		mov r10 , rax
		
		mov r12 , r14  			;i
		dec r12
		mov r13 , r14				;j
		dec r13

partloop:

		inc r13
		cmp r13 , r15
		jg partendloop
		mov rax , [myarr+r13*8]
		cmp rax , r10
		jge partloop
		inc r12
		mov rax , r12
		push rax
		xor rax , rax
		mov rax , r13
		push rax

		xor rax , rax

		call swap
		jmp partloop
	
		
		
partendloop:
		inc r12
		mov rax , r12
		push rax
		
		xor rax , rax
		mov rax , r15
		push rax

		xor rax , rax
	
		call swap
		mov rax , r12

		pop rbp
		ret 16
		
		
BefquickSort:
		mov rbx , [lengtharr]
		push "$"
		push rbx
		
		mov rbx , 0
		push rbx

		call quickSort
		jmp Exit
		
quickSort:

		push rbp
		mov rbp , rsp
		mov r8 , [rbp+16]
		mov r9 , [rbp+24]
		mov rax , r9

		cmp r8 , r9
		jg quickSortEnd
		push r9
		push r8
		push r9 
		push r8

		call partition

	

		pop r8
		pop r9
		push r8
		push r9
		dec rax
		push rax
		push rax 
		push r8

		call quickSort
	
		pop rax
			pop r9
		pop r8
		inc rax
		inc rax
		push r8
		push r9
		push rax
	
		push r9
		push rax
		call quickSort
		pop rax
		pop r9
		pop r8 
quickSortEnd:
		pop rbp
		
		ret 16




bExit:
		mov r9 , 0
		dec r9
nextExit:		
		inc r9
		cmp r9 , [lengtharr]
		je Exit
		mov rax , [myarr+r9*8]
		call writeNum
		call newLine
		jmp nextExit
		
Exit:
		mov r8 , [lengtharr]
		mov rax , [myarr+r8*8]
		mov rbx , rax
		dec r8
		mov rax , [myarr+r8*8]
		cmp rax , rbx
		jle lastExit
		mov r10 , rbx
		inc r8
		mov [myarr+r8*8] , rax
		mov rax , rbx
		dec r8
		mov [myarr+r8],rax
		
		
		
lastExit:
		call bfnext

		
        mov rax ,60
        xor rdi,rdi
        syscall