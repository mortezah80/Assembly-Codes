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
	   Msg1 dq    'low '
	   Msg2 dq    'high '
	   Msg3 dq    'x '
	   Msg4 dq    'less '
	   Msg5 dq    'rax '
		Msg6 dq    'NaN'

section .bss
		myarr resq 1000000
		lengtharr resq 1
		indexfind resq 1
		testCount resq 1
		
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
		je bfExit
		call readNum
		mov [myarr+r9*8] , rax
		jmp readArr




binarySearch:
		push rbp
		mov rbp , rsp
		mov r8 , [rbp+16]   ; left
		mov r9 , [rbp+24]	; right
		mov r10 , [rbp+32]	; x
		
		
	
		
		cmp r9 , r8
		je binarySearchOneItem
		cmp r9 , r8
		jl binarySearchEnd
		mov rax , r9
		sub rax , r8
		

		
		mov rcx , 2
		

		
		cqo
		div rcx
		
	
		
		add rax , r8    			; middle in rax
		mov r12 , [myarr+rax*8]

		cmp r12 , r10   		
		je  binarySearchEqual		; arr[mid] == x ?
		cmp r12 , r10
		jg	binarySearchGreater		; arr[mid] > x ?
		cmp r12 , r10
		
		jl 	binarySearchLess		; arr[mid] < x ?	
		jmp binarySearchEnd






binarySearchOneItem:
		mov r15 , [myarr+r8*8]
		cmp r15 , r10
		je binarySearchEqual
		jmp binarySearchEnd
		

; ///////////////////////////////////////////////		
binarySearchEqual:
		mov r13 , [indexfind]
		cmp r13 , -1
		jne binarySearchEqualnot
		mov [indexfind] , rax
		
binarySearchEqualLoop:
		dec rax
		cmp [myarr+rax*8] , r10
		jne binarySearchEnd
		mov [indexfind] , rax
		jmp binarySearchEqualLoop
	
		
	
		
		
		
		jmp binarySearchEnd
		

binarySearchEqualnot:
		cmp rax , r13
		jg binarySearchEqualnotret
		mov [indexfind] , rax
		
binarySearchEqualLoop2:
		dec rax
		cmp [myarr+rax*8] , r10
		jne binarySearchEnd
		mov [indexfind] , rax
		jmp binarySearchEqualLoop2
	
		
		jmp binarySearchEnd
		
binarySearchEqualnotret:
		jmp binarySearchEnd
		

; ///////////////////////////////////////////////




binarySearchGreater:		;arr[mid] > x
	
		
		push r8
		push r9
		push r10
		push r11
		push r12
		push r13
		push rax
		push r10
		dec rax 
		push rax
		push r8
		call binarySearch
		pop rax
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		jmp binarySearchEnd




; ///////////////////////////////////////////////

binarySearchLess:		;arr[mid] < x



		
		
		push r8
		push r9
		push r10
		push r11
		push r12
		push r13
		push rax
		push r10
		push r9
		inc rax
		push rax
		call binarySearch
		pop rax
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		jmp binarySearchEnd
		
		
; ///////////////////////////////////////////////



binarySearchEnd:
		pop rbp
		ret 24


bfExit:
		call readNum
		mov rbx , rax
		inc rbx
		mov [testCount] , rbx	
		
		
bfExitloop:
		mov rbx , [testCount]
		dec rbx
		mov [testCount] , rbx
		cmp rbx , 0
		je Exit
		
		
		push r8
		push r9
		push r10
		push r11
		push r12
		push r13
		push rax
		
		mov r15 , -1
		mov [indexfind] , r15
		call readNum
		mov r15 , rax
		push r15
		mov r15 , [lengtharr]
		push r15
		mov r15 , 0
		push r15

		
		call binarySearch
		
		mov rax , [indexfind]
		cmp rax , -1
		je NaN
		call writeNum
		call newLine
		jmp AfterNaN

NaN:
		mov rsi , Msg6
		call printString
		call newLine
		
AfterNaN:
		
		
		
		pop rax
	    pop r13
	    pop r12
	    pop r11
	    pop r10
	    pop r9
	    pop r8
	    
	    

		jmp  bfExitloop
		
		
		
Exit:

        mov rax ,60
        xor rdi,rdi
        syscall