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
      temp dq "" 
      temp2 dq ""
      IndexDict dq "000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" , "000" , "001" , "010" , "011" , "101" , "110" , "111" , 0
      ScaleDict dq "00" , "01" , "10" , "11" , 0
      BaseDict dq "000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" , "000" , "010" , "011" , "100" , "101" , "110" , "111" , 0
      RMDict dq "000" , "000" , "000" , "001" , "001" , "001" ,"010" , "010" , "010" , "011" , "011" , "011"  , "100" , "100" , "100" , "101" , "101" , "101" , "110" , "110" , "110", "111" , "111" , "111" , "000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" , 0
      RegDict dq "000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" ,"000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" , "000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" , "000" , "001" , "010" , "011" , "100" , "101" , "110" , "111" , 0
      RegDict64 dq "0000" , "0000" , "0000" , "0000" ,"0001" , "0001" , "0001" , "0001" , "0010" , "0010" , "0010" , "0010"  , "0011" , "0011" , "0011" , "0011" , "0100" , "0100" , "0100" , "0100" , "0101" , "0101" , "0101" , "0101"  , "0110" , "0110" , "0110" , "0110" , "0111" , "0111" , "0111" , "0111" , "1000" , "1000" , "1000" , "1000" ,  "1001" , "1001" , "1001" , "1001" , "1010" , "1010" , "1010" , "1010" , "1011" , "1011" , "1011" , "1011" , "1100" , "1100" , "1100" , "1100" , "1101" , "1101" , "1101" , "1101" , "1110" , "1110" , "1110" , "1110"  , "1111" , "1111" , "1111" , "1111" , 0 
      get_sib_ind dq -1 , 0
      get_sib_plus dq -1 , 0
      get_sib_Star dq -1 , 0
      get_sib_index dq "" , 0
      get_sib_scale dq "" , 0

      sib1_index dq "" , 0
      sib1_scale dq "" , 0

      sib2_index dq "" , 0
      sib2_scale dq "" , 0


      i dq 0
      make_hex_hex dq "0" , "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "a" , "b" , "c" , "d" , "e" , "f" , 0
      ;inp db "mov rax,rbx" , 0                     ;for test
      check_sib db "DWORD PTR [ebp+r9d*4+0x55]"
section .bss
      inp resb 2000
      operand resb 2000
      operation resb 2000
      operand1 resb 2000
      operand2 resb 2000
      opcode resb 2000
      Regop resb 2000
      type1 resb 200
      type2 resb 200
      Immediate resb 200
      single_operand resb 200

      tempop resb 100
      get_sib_base resb 100
      get_sib_operandTemp resb 1000
      tempfortest resb 100
      get_sib_operand resb 2000
      get_sib_displacment resb 2000
      make_hex_answer resb 2000
      temp_hex resb 2000

      answer resb 2000
      temp_cmp_str resb 2000
      swap_twoString_temp resb 2000
      D resq 1
      W resq 1
      rexW resq 1
      rexR resq 1
      rexX resq 1
      rexB resq 1
      Sib resb 2000
      sib resb 2000
      opCode resb 2000
      mod resb 2000
      rm resb 2000
      prefix resb 2000
      displacement resb 2000
      displacment_8 resb 2000
      displacement_32 resb 2000
      new_register resb 2000
      directAddress resb 2000
      reg1 resb 2000
      reg2 resb 2000
      single_operand_regValue resb 2000
      sib1_base resb 100
      sib1_displacment resb 2000

      sib2_base resb 100
      sib2_displacment resb 2000

      displc1 resq 1
      displc2 resq 1
      no_displacement resb 2000

      temparr resb 2000 
      temparr2 resb 2000

section .text
      global _start
        
_start:
      mov rbx , 7
      mov rax , [IndexDict+rbx*8]
      mov [temp] , rax
      mov rsi , temp
      call printString
      call newLine
      jmp endFunctions

getIndexDict:
		push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; key in rax
      xor rbx , rbx         ; value in rbx


      cmp rax , "eax" 
      cmove rbx , [IndexDict + 0*8]
      cmp rax , "ecx" 
      cmove rbx , [IndexDict + 1*8]
      cmp rax , "edx" 
      cmove rbx , [IndexDict + 2*8]
      cmp rax , "ebx" 
      cmove rbx , [IndexDict + 3*8]
      cmp rax , "illegal" 
      cmove rbx , [IndexDict + 4*8]
      cmp rax , "ebp" 
      cmove rbx , [IndexDict + 5*8]
      cmp rax , "esi" 
      cmove rbx , [IndexDict + 6*8]
      cmp rax , "edi" 
      cmove rbx , [IndexDict + 7*8]
      cmp rax , "rax" 
      cmove rbx , [IndexDict + 8*8]
      cmp rax , "rcx" 
      cmove rbx , [IndexDict + 9*8]
      cmp rax , "rdx" 
      cmove rbx , [IndexDict + 10*8]
      cmp rax , "rbx" 
      cmove rbx , [IndexDict + 11*8]
      cmp rax , "rbp" 
      cmove rbx , [IndexDict + 12*8]
      cmp rax , "rsi" 
      cmove rbx , [IndexDict + 13*8]
      cmp rax , "rdi" 
      cmove rbx , [IndexDict + 14*8]

      mov rax , rbx           ; key in rax
      pop rbp
      ret 8



getScaleDict:
		push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; key in rax
      xor rbx , rbx         ; value in rbx
      cmp rax , "1" 
      cmove rbx , [ScaleDict + 0*8]
      cmp rax , "2" 
      cmove rbx , [ScaleDict + 1*8]
      cmp rax , "4" 
      cmove rbx , [ScaleDict + 2*8]
      cmp rax , "8" 
      cmove rbx , [ScaleDict + 3*8]

      mov rax , rbx           ; key in rax
      pop rbp
      ret 8


getBaseDict:
		push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; key in rax
      xor rbx , rbx         ; value in rbx


      cmp rax , "eax" 
      cmove rbx , [BaseDict + 0*8]
      cmp rax , "ecx" 
      cmove rbx , [BaseDict + 1*8]
      cmp rax , "edx" 
      cmove rbx , [BaseDict + 2*8]
      cmp rax , "ebx" 
      cmove rbx , [BaseDict + 3*8]
      cmp rax , "esp" 
      cmove rbx , [BaseDict + 4*8]
      cmp rax , "ebp" 
      cmove rbx , [BaseDict + 5*8]
      cmp rax , "esi" 
      cmove rbx , [BaseDict + 6*8]
      cmp rax , "edi" 
      cmove rbx , [BaseDict + 7*8]
      cmp rax , "rax" 
      cmove rbx , [BaseDict + 8*8]
      cmp rax , "rcx" 
      cmove rbx , [BaseDict + 9*8]
      cmp rax , "rdx" 
      cmove rbx , [BaseDict + 10*8]
      cmp rax , "rbx" 
      cmove rbx , [BaseDict + 11*8]
      cmp rax , "rbp" 
      cmove rbx , [BaseDict + 12*8]
      cmp rax , "rsi" 
      cmove rbx , [BaseDict + 13*8]
      cmp rax , "rdi" 
      cmove rbx , [BaseDict + 14*8]

      mov rax , rbx           ; key in rax
      pop rbp
      ret 8


getRMDict:
		push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; key in rax
      xor rbx , rbx         ; value in rbx


      cmp rax , "al" 
      cmove rbx , [RMDict + 0*8]
      cmp rax , "ax" 
      cmove rbx , [RMDict + 1*8]
      cmp rax , "eax" 
      cmove rbx , [RMDict + 2*8]
      cmp rax , "cl" 
      cmove rbx , [RMDict + 3*8]
      cmp rax , "cx" 
      cmove rbx , [RMDict + 4*8]
      cmp rax , "ecx" 
      cmove rbx , [RMDict + 5*8]
      cmp rax , "dl" 
      cmove rbx , [RMDict + 6*8]
      cmp rax , "dx" 
      cmove rbx , [RMDict + 7*8]
      cmp rax , "edx" 
      cmove rbx , [RMDict + 8*8]
      cmp rax , "bl" 
      cmove rbx , [RMDict + 9*8]
      cmp rax , "bx" 
      cmove rbx , [RMDict + 10*8]
      cmp rax , "ebx" 
      cmove rbx , [RMDict + 11*8]
      cmp rax , "ah" 
      cmove rbx , [RMDict + 12*8]
      cmp rax , "sp" 
      cmove rbx , [RMDict + 13*8]
      cmp rax , "esp" 
      cmove rbx , [RMDict + 14*8]
      cmp rax , "ch" 
      cmove rbx , [RMDict + 15*8]
      cmp rax , "bp" 
      cmove rbx , [RMDict + 16*8]
      cmp rax , "ebp" 
      cmove rbx , [RMDict + 17*8]
      cmp rax , "dh" 
      cmove rbx , [RMDict + 18*8]
      cmp rax , "si" 
      cmove rbx , [RMDict + 19*8]
      cmp rax , "esi" 
      cmove rbx , [RMDict + 20*8]
      cmp rax , "bh" 
      cmove rbx , [RMDict + 21*8]
      cmp rax , "di" 
      cmove rbx , [RMDict + 22*8]
      cmp rax , "edi" 
      cmove rbx , [RMDict + 23*8]
      cmp rax , "rax" 
      cmove rbx , [RMDict + 24*8]
      cmp rax , "rcx" 
      cmove rbx , [RMDict + 25*8]
      cmp rax , "rdx" 
      cmove rbx , [RMDict + 26*8]
      cmp rax , "rbx" 
      cmove rbx , [RMDict + 27*8]
      cmp rax , "rsp" 
      cmove rbx , [RMDict + 28*8]
      cmp rax , "rbp" 
      cmove rbx , [RMDict + 29*8]
      cmp rax , "rsi" 
      cmove rbx , [RMDict + 30*8]
      cmp rax , "rdi" 
      cmove rbx , [RMDict + 31*8]


      mov rax , rbx           ; key in rax
      pop rbp
      ret 8


getRegDict:
		push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; key in rax
      xor rbx , rbx         ; value in rbx


      cmp rax , "ax" 
      cmove rbx , [RegDict + 0*8]
      cmp rax , "cx" 
      cmove rbx , [RegDict + 1*8]
      cmp rax , "dx" 
      cmove rbx , [RegDict + 2*8]
      cmp rax , "bx" 
      cmove rbx , [RegDict + 3*8]
      cmp rax , "sp" 
      cmove rbx , [RegDict + 4*8]
      cmp rax , "bp" 
      cmove rbx , [RegDict + 5*8]
      cmp rax , "si" 
      cmove rbx , [RegDict + 6*8]
      cmp rax , "di" 
      cmove rbx , [RegDict + 7*8]
      cmp rax , "al" 
      cmove rbx , [RegDict + 8*8]
      cmp rax , "cl" 
      cmove rbx , [RegDict + 9*8]
      cmp rax , "dl" 
      cmove rbx , [RegDict + 10*8]
      cmp rax , "bl" 
      cmove rbx , [RegDict + 11*8]
      cmp rax , "ah" 
      cmove rbx , [RegDict + 12*8]
      cmp rax , "ch" 
      cmove rbx , [RegDict + 13*8]
      cmp rax , "dh" 
      cmove rbx , [RegDict + 14*8]
      cmp rax , "bh" 
      cmove rbx , [RegDict + 15*8]
      cmp rax , "eax" 
      cmove rbx , [RegDict + 16*8]
      cmp rax , "ecx" 
      cmove rbx , [RegDict + 17*8]
      cmp rax , "edx" 
      cmove rbx , [RegDict + 18*8]
      cmp rax , "ebx" 
      cmove rbx , [RegDict + 19*8]
      cmp rax , "esp" 
      cmove rbx , [RegDict + 20*8]
      cmp rax , "ebp" 
      cmove rbx , [RegDict + 21*8]
      cmp rax , "esi" 
      cmove rbx , [RegDict + 22*8]
      cmp rax , "edi" 
      cmove rbx , [RegDict + 23*8]
      cmp rax , "rax" 
      cmove rbx , [RegDict + 24*8]
      cmp rax , "rcx" 
      cmove rbx , [RegDict + 25*8]
      cmp rax , "rdx" 
      cmove rbx , [RegDict + 26*8]
      cmp rax , "rbx" 
      cmove rbx , [RegDict + 27*8]
      cmp rax , "rsp" 
      cmove rbx , [RegDict + 28*8]
      cmp rax , "rbp" 
      cmove rbx , [RegDict + 29*8]
      cmp rax , "rsi" 
      cmove rbx , [RegDict + 30*8]
      cmp rax , "rdi" 
      cmove rbx , [RegDict + 31*8]


      mov rax , rbx           ; key in rax
      pop rbp
      ret 8



getReg64Dict:
		push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; key in rax
      xor rbx , rbx         ; value in rbx


      cmp rax , "rax" 
      cmove rbx , [RegDict64 + 0*8]
      cmp rax , "eax" 
      cmove rbx , [RegDict64 + 1*8]
      cmp rax , "ax" 
      cmove rbx , [RegDict64 + 2*8]
      cmp rax , "al" 
      cmove rbx , [RegDict64 + 3*8]
      cmp rax , "rcx" 
      cmove rbx , [RegDict64 + 4*8]
      cmp rax , "ecx" 
      cmove rbx , [RegDict64 + 5*8]
      cmp rax , "cx" 
      cmove rbx , [RegDict64 + 6*8]
      cmp rax , "cl" 
      cmove rbx , [RegDict64 + 7*8]
      cmp rax , "rdx" 
      cmove rbx , [RegDict64 + 8*8]
      cmp rax , "edx" 
      cmove rbx , [RegDict64 + 9*8]
      cmp rax , "dx" 
      cmove rbx , [RegDict64 + 10*8]
      cmp rax , "dl" 
      cmove rbx , [RegDict64 + 11*8]
      cmp rax , "rbx" 
      cmove rbx , [RegDict64 + 12*8]
      cmp rax , "ebx" 
      cmove rbx , [RegDict64 + 13*8]
      cmp rax , "bx" 
      cmove rbx , [RegDict64 + 14*8]
      cmp rax , "bl" 
      cmove rbx , [RegDict64 + 15*8]
      cmp rax , "rsp" 
      cmove rbx , [RegDict64 + 16*8]
      cmp rax , "esp" 
      cmove rbx , [RegDict64 + 17*8]
      cmp rax , "sp" 
      cmove rbx , [RegDict64 + 18*8]
      cmp rax , "ah" 
      cmove rbx , [RegDict64 + 19*8]
      cmp rax , "rbp" 
      cmove rbx , [RegDict64 + 20*8]
      cmp rax , "ebp" 
      cmove rbx , [RegDict64 + 21*8]
      cmp rax , "bp" 
      cmove rbx , [RegDict64 + 22*8]
      cmp rax , "ch" 
      cmove rbx , [RegDict64 + 23*8]
      cmp rax , "rsi" 
      cmove rbx , [RegDict64 + 24*8]
      cmp rax , "esi" 
      cmove rbx , [RegDict64 + 25*8]
      cmp rax , "si" 
      cmove rbx , [RegDict64 + 26*8]
      cmp rax , "dh" 
      cmove rbx , [RegDict64 + 27*8]
      cmp rax , "rdi" 
      cmove rbx , [RegDict64 + 28*8]
      cmp rax , "edi" 
      cmove rbx , [RegDict64 + 29*8]
      cmp rax , "di" 
      cmove rbx , [RegDict64 + 30*8]
      cmp rax , "bh" 
      cmove rbx , [RegDict64 + 31*8]
      cmp rax , "r8" 
      cmove rbx , [RegDict64 + 32*8]
      cmp rax , "r8d" 
      cmove rbx , [RegDict64 + 33*8]
      cmp rax , "r8w" 
      cmove rbx , [RegDict64 + 34*8]
      cmp rax , "r8b" 
      cmove rbx , [RegDict64 + 35*8]
      cmp rax , "r9" 
      cmove rbx , [RegDict64 + 36*8]
      cmp rax , "r9d" 
      cmove rbx , [RegDict64 + 37*8]
      cmp rax , "r9w" 
      cmove rbx , [RegDict64 + 38*8]
      cmp rax , "r9b" 
      cmove rbx , [RegDict64 + 39*8]
      cmp rax , "r10" 
      cmove rbx , [RegDict64 + 40*8]
      cmp rax , "r10d" 
      cmove rbx , [RegDict64 + 41*8]
      cmp rax , "r10w" 
      cmove rbx , [RegDict64 + 42*8]
      cmp rax , "r10b" 
      cmove rbx , [RegDict64 + 43*8]
      cmp rax , "r11" 
      cmove rbx , [RegDict64 + 44*8]
      cmp rax , "r11d" 
      cmove rbx , [RegDict64 + 45*8]
      cmp rax , "r11w" 
      cmove rbx , [RegDict64 + 46*8]
      cmp rax , "r11b" 
      cmove rbx , [RegDict64 + 47*8]
      cmp rax , "r12" 
      cmove rbx , [RegDict64 + 48*8]
      
      cmp rax , "r12d" 
      cmove rbx , [RegDict64 + 49*8]
      cmp rax , "r12w" 
      cmove rbx , [RegDict64 + 50*8]
      cmp rax , "r12b" 
      cmove rbx , [RegDict64 + 51*8]
      cmp rax , "r13" 
      cmove rbx , [RegDict64 + 52*8]
      cmp rax , "r13d" 
      cmove rbx , [RegDict64 + 53*8]
      cmp rax , "r13w" 
      cmove rbx , [RegDict64 + 54*8]
      cmp rax , "r13b" 
      cmove rbx , [RegDict64 + 55*8]
      cmp rax , "r14" 
      cmove rbx , [RegDict64 + 56*8]
      cmp rax , "r14d" 
      cmove rbx , [RegDict64 + 57*8]
      cmp rax , "r14w" 
      cmove rbx , [RegDict64 + 58*8]
      cmp rax , "r14b" 
      cmove rbx , [RegDict64 + 59*8]
      cmp rax , "r15" 
      cmove rbx , [RegDict64 + 60*8]
      cmp rax , "r15d" 
      cmove rbx , [RegDict64 + 61*8]
      cmp rax , "r15w" 
      cmove rbx , [RegDict64 + 62*8]
      cmp rax , "r15b" 
      cmove rbx , [RegDict64 + 63*8]

      mov rax , rbx           ; key in rax
      pop rbp
      ret 8







getLen:
      push rbp
      mov rbp , rsp
      mov rax , [rbp+16]    ; start pointer of string in rax




      xor r8 , r8         ; len in r8
      dec r8
      mov rcx , 0
      mov rbx , rax
getLenloop:
      inc r8
      cmp [rax + r8] , cl     ; compare with 0. for find end of string
      je getLenEndLoop
      jmp getLenloop
getLenEndLoop:



      mov rax , r8     ; len in rax
      pop rbp
      ret 8



;////////////////////////////////////////////////////////////////////////////////////


operand_type:
      push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; operand in rax
      xor rbx , rbx         ; operand type in rbx
      push rax
  
      push rax                   ; len(operand) == 0 ?
      call getLen
      mov r8 , rax                 ; len in rax and r8
      cmp rax , 0
      je operand_type_eqZeroLen

      pop rax

      mov r9 , 0
      dec r9
operand_type_PTRloop:
      inc r9
      cmp r9 , r8
      je operand_type_Immediate


      mov cl , "P"
      cmp [rax + r9] , cl
      jne operand_type_PTRloop

  
      mov cl , "T"
      cmp [rax + r9 +1] , cl
      jne operand_type_PTRloop




      mov cl , "R"
      cmp [rax + r9 +2] , cl
      jne operand_type_PTRloop            ; agar azija rad she yani PTR find shode.
      mov rax , 7
      call writeNum
      call newLine
      mov rbx , "Memory"
      mov rax , rbx           ; operand type in rax
      pop rbp
      ret 8

operand_type_Immediate:                         ; for returning immediate
      mov cl , [rax]                   ; operand[0] in cl
      cmp cl , "0"
      jl operand_type_Register
      cmp cl , "9"
      jg operand_type_Register
      mov rbx , "Imdiate"
      mov rax , rbx           ; operand type in rax
      pop rbp
      ret 8


operand_type_eqZeroLen:
      pop rax
      mov rbx , "NONE"
      mov rax , rbx           ; operand type in rax
      pop rbp
      ret 8

operand_type_Register: 

      mov rax , "Reg"           ; operand type in rax
      pop rbp
      ret 8



;////////////////////////////////////////////////////////////////////////////////////

register_type:
      push rbp
		mov rbp , rsp
		mov rax , [rbp+16]    ; operand in rax
      xor rbx , rbx         ; Register type in rbx
      push rax

      
      push rax
      call getLen
      cmp rax , 0
      je register_type0         ; len(operand) == 0 ?   

      pop rax            ; operand in rax
      push rax

      push rax
      call operand_type
      cmp rax , "Reg"
      jne register_type0       ; or operand_type(operand) != "Reg" 

      pop rax             ; operand in rax

      mov cl , [rax]      ; operand[0] in cl

      cmp cl , "r"
      je register_type_r

      push rax 

      push rax
      call getLen
      cmp rax , 2
      jne register_type_return32

      mov rcx , rax           ; operand len in rcx
      pop rax                 ; operand in rax

      dec rcx
      mov r15b , [rax+rcx]
      cmp r15b , "l"
      je register_type_justlen2
      
      cmp r15b , "h"
      je register_type_justlen2

      mov rbx , 16                        ; 16 because condition is true
      mov rax , rbx
      pop rbp
      ret 8








register_type0:
      pop rax
      mov rbx , 0
      mov rax , rbx
      pop rbp
      ret 8



register_type_r:
      push rax          ; store operand

   


      push rax
      call getLen
      mov rcx , rax     ; len  operand in rcx

      pop rax           ; operand in rax

      dec rcx           ; len(operand)-1 in rcx 

      mov rbx , 64      ; deafult return is 64

      mov r15b , [rax+rcx]
      mov r14 , 32
      cmp r15b , "d"
      cmove rbx , r14               ; move 32 in rbx
      mov r14 , 16         
      cmp r15b , "w"
      cmove rbx , r14               ; mov 16 in rbx
      mov r14 , 8
      cmp r15b , "b"
      cmove rbx , r14               ; mov 8 in rbx

      mov rax , rbx     ; return 32 in rax
      pop rbp
      ret 8


register_type_justlen2:

      mov rbx , 8
      mov rax , rbx     ; return in rax
      pop rbp
      ret 8

register_type_return32:
      pop rax
      mov rbx , 32
      mov rax , rbx     ; return in rax
      pop rbp
      ret 8



; ////////////////////////////////////////////////////////////////////////////////////////

memory_type:
      push rbp
      mov rbp , rsp
      mov rax , [rbp+16]    ; operand in rax
      xor rbx , rbx         ; Memory type in rbx

      push rax               ; store operand
  
      push rax             
      call getLen
      mov r8 , rax                 ; len in rax and r8


      pop rax               ; operand in rax



      mov r9 , 0
      dec r9
memory_type_PTRloop:
      inc r9
      cmp r9 , r8
      je memory_type_PTRNotFound


      mov cl , "P"
      cmp [rax + r9] , cl
      jne memory_type_PTRloop

  
      mov cl , "T"
      cmp [rax + r9 +1] , cl
      jne memory_type_PTRloop




      mov cl , "R"
      cmp [rax + r9 +2] , cl
      jne memory_type_PTRloop            ; agar azija rad she yani PTR find shode.


      jmp memory_type_beforeBYTEloop





memory_type_PTRNotFound:

      mov rbx , 0
      dec rbx
      mov rax , rbx           ; -1 in rax. because find PTR.
      pop rbp
      ret 8

memory_type_beforeBYTEloop:
      mov r9 , 0
      dec r9
memory_type_BYTEloop:
      inc r9
      cmp r9 , r8
      je memory_type_beforeDWORDloop


      mov cl , "B"
      cmp [rax + r9] , cl
      jne memory_type_BYTEloop

  
      mov cl , "Y"
      cmp [rax + r9 +1] , cl
      jne memory_type_BYTEloop


      mov cl , "T"
      cmp [rax + r9 +2] , cl
      jne memory_type_BYTEloop            

      mov cl , "E"
      cmp [rax + r9 +3] , cl
      jne memory_type_BYTEloop         ; rad she yani Byte peyda shode.

      mov rbx , 8
      mov rax , rbx           ; 8 in rax. because find BYTE.
      pop rbp
      ret 8


memory_type_beforeDWORDloop:
      mov r9 , 0
      dec r9

memory_type_DWORDloop:
      inc r9
      cmp r9 , r8
      je memory_type_beforeQWORDloop


      mov cl , "D"
      cmp [rax + r9] , cl
      jne memory_type_DWORDloop

  
      mov cl , "W"
      cmp [rax + r9 +1] , cl
      jne memory_type_DWORDloop

      mov cl , "O"
      cmp [rax + r9 +2] , cl
      jne memory_type_DWORDloop   
         

      mov cl , "R"
      cmp [rax + r9 +3] , cl
      jne memory_type_DWORDloop  

      mov cl , "D"
      cmp [rax + r9 +4] , cl
      jne memory_type_DWORDloop               ; age azinja rad she dword peyda shode


   
      

      mov rbx , 32
      mov rax , rbx           ; 32 in rax. because find DWORD.
      pop rbp
      ret 8


memory_type_beforeQWORDloop:
      mov r9 , 0
      dec r9
memory_type_QWORDloop:
      inc r9
      cmp r9 , r8
      je memory_type_beforeWORDloop


      mov cl , "Q"
      cmp [rax + r9] , cl
      jne memory_type_QWORDloop

  
      mov cl , "W"
      cmp [rax + r9 +1] , cl
      jne memory_type_QWORDloop


      mov cl , "O"
      cmp [rax + r9 +2] , cl
      jne memory_type_QWORDloop            

      mov cl , "R"
      cmp [rax + r9 +3] , cl
      jne memory_type_QWORDloop         

      mov cl , "D"
      cmp [rax + r9 +4] , cl
      jne memory_type_QWORDloop               ; age azinja rad she dword peyda shode

      mov rbx , 64
      mov rax , rbx           ; 64 in rax. because find QWORD.
      pop rbp
      ret 8

memory_type_beforeWORDloop:
      mov r9 , 0
      dec r9
memory_type_WORDloop:

      inc r9
      cmp r9 , r8
      je memory_type_return0


      mov cl , "W"
      cmp [rax + r9] , cl
      jne memory_type_WORDloop

  
      mov cl , "O"
      cmp [rax + r9 +1] , cl
      jne memory_type_WORDloop


      mov cl , "R"
      cmp [rax + r9 +2] , cl
      jne memory_type_WORDloop            

      mov cl , "D"
      cmp [rax + r9 +3] , cl 
      jne memory_type_WORDloop              ; age azinja rad she dword peyda shode


      mov rbx , 16
      mov rax , rbx           ; 16 in rax. because find WORD.
      pop rbp
      ret 8

memory_type_return0:
      mov rbx , 0
      mov rax , rbx           ; 0 in rax. because nothing found.
      pop rbp
      ret 8


; ////////////////////////////////////////////////////////////////////////////////////



get_str_slice:
      ; rax , rcx , rdx , r8 ,r9 , r10 
      push rax
      push rcx
      push rdx
      push r8
      push r9
      push r10
      push rbp
      mov rbp , rsp
      mov rax , [rbp+64]    ; str start adress in rax
      mov rdx , [rbp+72]    ; new str store adress in rbx (buffer)
      mov r9 , [rbp+ 80]     ; end of slice in r9
      mov r8 , [rbp+ 88]     ; start of slice in r8

      mov r10 , 0             ; start of buffer
      dec r10
      dec r8
get_str_sliceLoop:
      inc r8
      inc r10
      cmp r8 , r9
      je get_str_sliceLoopEnd
      mov cl , [rax + r8]
      mov [rdx + r10] , cl
      jmp get_str_sliceLoop


    

get_str_sliceLoopEnd:
      pop rbp
      pop r10
      pop r9
      pop r8
      pop rdx
      pop rcx
      pop rax
      ret 32

make_reverse:
      push rbp
      mov rbp , rsp
      mov rax , [rbp+16]    ; str start adress in rax
      
      push rax


 

      push rax
      call getLen
      mov r8 , rax            ; len in r8

    

      pop rax

      mov r9 , 0
      dec r9
make_reverseLoop:
      inc r9
      dec r8
      cmp r9 , r8             ; r9    r8
      jge make_reverseLoopEnd
      mov cl , [rax+r8]
      mov bl , [rax+r9]
      mov [rax + r9] , cl
      mov [rax + r8] , bl
      jmp make_reverseLoop

make_reverseLoopEnd:
      pop rbp
      ret 8

get_sib:
      push rbp
      mov rbp , rsp
      mov rax , [rbp+16]    ; operand in rax
      xor rbx , rbx         ; Memory type in rbx

      push rax

      mov rsi , rax
      call printString
      call newLine


      push rax
      call operand_type

      mov [temp] , rax
      pop rax


      push rax

      mov rsi , temp
      call printString
      call newLine
      pop rax

      push rax


      mov rcx , 6  
      mov rbx , "Memory"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , temp
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      mov r9 , rax                        ; eqaul or not in r9

      pop rax


      push rax
      mov rax,r9
      call writeNum
      call newLine
      pop rax



      cmp r9 , 1

      jne get_sib_returnminus1



      push rax
  
      push rax                  
      call getLen
      mov r8 , rax                 ; len in rax and r8

      pop rax

      mov rbx , 0 
      dec rbx                     ; -1 in rbx. its a flag for finding PTR Start
      mov r9 , 0
      dec r9
get_sib_PTRloop:
      inc r9
      cmp r9 , r8
      je get_sib_PTRNotFounded


      mov cl , "P"
      cmp [rax + r9] , cl
      jne get_sib_PTRloop

  
      mov cl , "T"
      cmp [rax + r9 +1] , cl
      jne get_sib_PTRloop




      mov cl , "R"
      cmp [rax + r9 +2] , cl
      jne get_sib_PTRloop            ; agar azija rad she yani PTR find shode.
      
      mov rbx , r9
      jmp get_sib_PTRloopEnd  


get_sib_PTRNotFounded:

      push rax
      mov rax , 23
      call writeNum
      call newLine
      pop rax

      mov rax , "Error"
      pop rbp
      ret 8

get_sib_PTRloopEnd:                  ; start of PTR is in rbx
      add rbx , 3
      mov r15 , 0
      dec r15



      push rax
      mov r12b , [rax+rbx]
      mov rax , r12
      mov [temp] , rax
      mov rsi , temp
      call printString
      call newLine

      mov rax , rbx
      call writeNum
      call newLine
      pop rax

get_sib_operandShiftL4loop:
      inc r15
      inc rbx
      cmp rbx , r8
      je get_sib_operandShiftL4loopEnd
      mov r12b , [rax+rbx]
      mov [rax+r15] , r12b
      jmp get_sib_operandShiftL4loop


get_sib_operandShiftL4loopEnd:
      mov r13 , 0




      push rax
      mov rax , r8
      call writeNum
      call newLine
      pop rax


      dec r15
      mov r13 , 0
get_sib_operandShiftL4loopEnd_makeZeroLoop:
      inc r15
      cmp r15 , r8
      je get_sib_operandShiftL4loopEnd_makeZeroLoop_end
      mov [rax+r15] , r13b
      jmp get_sib_operandShiftL4loopEnd_makeZeroLoop

get_sib_operandShiftL4loopEnd_makeZeroLoop_end:

      mov rsi , rax
      call printString
      call newLine

      mov r9 , 0
      dec r9
get_sib_Starloop:
      inc r9
      cmp r9 , r8
      je get_sib_StarNotFounded
      mov rbx , r9
      mov cl , "*"
      cmp [rax + r9] , cl
      je get_sib_StarFounded


      jmp get_sib_Starloop
      
get_sib_StarFounded:                            ; start of * is in rbx

      mov [get_sib_Star] , rbx
      mov r12 , rbx                              ; start of * is in r12 too.
      dec rbx
      mov [get_sib_ind] , rbx

      mov r9 , rbx
      mov r10 , 0
      dec r10
get_sib_StarFoundedLoop1:

      mov r12b , [rax+r9]
      cmp r12b , "[" 
      je get_sib_StarFoundedLoop1End
      cmp r12b , "+"
      je get_sib_StarFoundedLoop1End
      inc r10                                   ; pointer to end of index
      mov [get_sib_index + r10 ] , r12b
      dec r9                                     ; ind -= 1
      jmp get_sib_StarFoundedLoop1


get_sib_StarFoundedLoop1End:
      push rax

      push rax
      mov rsi ,get_sib_index
      call printString
      call newLine
      pop rax



      mov rax , get_sib_index
      push rax
      call make_reverse

      pop rax


      push rax
      mov rsi ,get_sib_index
      call printString
      call newLine
      pop rax

      mov rbx , r12
      inc rbx
      mov [get_sib_ind] , rbx

      mov r9 , [get_sib_Star]
      mov r10 , 0
      dec r10
      inc r9
      xor r12 , r12



get_sib_StarFoundedLoop2:


      mov r12b , [rax+r9]
      cmp r12b , "]" 
      je get_sib_StarFoundedLoop2End
      cmp r12b , "+"
      je get_sib_StarFoundedLoop2End
      inc r10                                   ; pointer to end of index
      mov [get_sib_scale + r10 ] ,r12b
      inc r9                                     ; ind += 1
      jmp get_sib_StarFoundedLoop2


get_sib_StarFoundedLoop2End:
    

      push rax
      mov rsi ,get_sib_scale
      call printString
      call newLine
      pop rax

      push rax

      push rax
      call getLen
      mov r8 , rax            ; new len in r8




      pop rax

      mov r9 , 0
      dec r9
get_sib_Plusloop:


      inc r9
      cmp r9 , r8
      je get_sib_PlusNotFounded

      mov r12b , "+"
      cqo
      cmp [rax + r9] , r12b
      jne get_sib_Plusloop



      mov rbx , r9
      jmp get_sib_PlusFounded

get_sib_PlusFounded:



      mov [get_sib_plus] , rbx
      mov r15 , rbx                       ; start of + is in r15
      mov rbx , r12                       ; ind = operand.find("*")
      cmp r15 , rbx
      jge get_sib_PlusFoundedPlusNotLesInd           ; plus < ind ?

      push rax

      mov r9 , 1                                               ; plus < ind
      mov r10 , [get_sib_plus]
      mov r11 , get_sib_base
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; base = operand [1:plus]

      pop rax
     
     
      
      mov r9 , [get_sib_plus]                            ; plus start in r9
      mov r10 , r8
      dec r10
get_sib_Plusloop2:
      inc r9
      cmp r9 , r10
      je get_sib_Plusloop2NotFound


      mov cl , "+"
      cmp [rax + r9] , cl
      jne get_sib_Plusloop2

      mov rbx , r9
      jmp get_sib_Plusloop2Found

get_sib_Plusloop2Found:

      push rax

      mov r9 , rbx                   ; plus < ind
      add r9 , 3
      mov r10 , r8
      dec r10
      mov r11 , get_sib_displacment
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; displacement = operand[plus + 3 : len(operand) - 1]

      pop rax

      jmp get_sib_End

get_sib_Plusloop2NotFound:
      ; nothing is happening here

      push rax
      mov rax , 64
      call writeNum
      call newLine
      pop rax

      jmp get_sib_End

get_sib_PlusFoundedPlusNotLesInd:
      push rax

      mov r9 , [get_sib_plus]                   ; plus < ind
      add r9 , 3
      mov r10 , r8
      dec r10
      mov r11 , get_sib_displacment
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; base = operand [1:plus]

      pop rax

      jmp get_sib_End

get_sib_PlusNotFounded:
      ; nothing is happening here
      jmp get_sib_End
get_sib_StarNotFounded:
      mov r9 , 0
      dec r9
get_sib_StarNotFounded_Plusloop:
      inc r9
      cmp r9 , r8
      je get_sib_StarNotFounded_PlusNotFounded

      mov cl , "+"
      cmp [rax + r9] , cl
      jne get_sib_StarNotFounded_Plusloop

      mov rbx , r9
      jmp get_sib_StarNotFounded_PlusFounded



get_sib_StarNotFounded_PlusNotFounded:
      mov cl , [rax +2]
      cmp cl , "x"                  ;operand[2] != "x" ?
      je get_sib_StarNotFounded_PlusNotFounded_eqX
      push rax

      mov r9 , 1                                               ; plus < ind
      mov r10 , r8
      dec r10                                   ; len operand - 1 in r10
      mov r11 , get_sib_base
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; base = operand [1:plus]

      pop rax  



      jmp get_sib_End

get_sib_StarNotFounded_PlusNotFounded_eqX:
      push rax

      mov r9 , 3                                           
      mov r10 , r8
      dec r10                                   
      mov r11 , get_sib_displacment
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; displacement = operand [3 : len(operand )-1]

      pop rax  



      jmp get_sib_End

get_sib_StarNotFounded_PlusFounded:
      mov [get_sib_ind] , rbx

      push rbx
      push rax

      mov r9 , 1                                              
      mov r10 , rbx
                                  
      mov r11 , get_sib_base
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; base = operand [1:ind]

      pop rax 
      pop rbx

      inc rbx
      mov cl , [rax + rbx]
      dec rbx
      cmp cl , "0"
      jne get_sib_StarNotFounded_PlusFounded_NotZero

      push rax

      mov r9 , rbx
      add r9 , 3                                           
      mov r10 , r8
      dec r10                                   
      mov r11 , get_sib_displacment
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; displacement = operand [ind + 3 : len(operand )-1]

      pop rax  

      jmp get_sib_End
get_sib_StarNotFounded_PlusFounded_NotZero:

      mov r9 , 1
      mov [get_sib_scale] , r9
      inc rbx

      mov r10 , 0
      dec r10
get_sib_StarNotFounded_PlusFounded_NotZeroLoop:
      cmp rbx , r8
      jge get_sib_StarNotFounded_PlusFounded_NotZeroLoopEnd     ; ind<len(operand) 
      mov cl , [rax + rbx]
      cmp cl , "]"
      je get_sib_StarNotFounded_PlusFounded_NotZeroLoopEnd      ; operand[ind] != "]"
      cmp cl , "+"
      je get_sib_StarNotFounded_PlusFounded_NotZeroLoopEnd      ; operand[ind] != "+"
      inc r10
      mov [get_sib_index + r10] , cl                              ; index += operand[ind]
      inc rbx
      jmp get_sib_StarNotFounded_PlusFounded_NotZeroLoop



get_sib_StarNotFounded_PlusFounded_NotZeroLoopEnd:
      mov cl , [rax + rbx]
      cmp cl , "+"
      jne get_sib_StarNotFounded_PlusFounded_NotZeroLoopEnd_Notplus

      push rax

      mov r9 , rbx
      add r9 , 3                                           
      mov r10 , r8
      dec r10                                   
      mov r11 , get_sib_displacment
      push r9
      push r10
      push r11
      push rax
      call get_str_slice                        ; displacement = operand [ind + 3 : len(operand )-1]

      pop rax  

      jmp get_sib_End
get_sib_StarNotFounded_PlusFounded_NotZeroLoopEnd_Notplus:

      jmp get_sib_End



get_sib_End:

      push rax

      mov rax , get_sib_displacment
      push rax
      call getLen
      mov r9 , rax                        ; len displacment in r9

      pop rax

      cmp r9 , 2
      jle get_sib_End_LessTwo

      mov rdx , [get_sib_displacment]
      mov r10 , 8
      sub r10 , r9

      inc r10
get_sib_End_shiftLoop:
      dec r10
      cmp r10 , 0
      je get_sib_End_shiftLoopEnd
      shr rdx , 1
      mov cl , "0"
      mov [rdx+0] , cl
      jmp get_sib_End_shiftLoop

get_sib_End_shiftLoopEnd:
      mov [get_sib_displacment] , rdx

      pop rbp
      ret 8
get_sib_End_LessTwo:

      pop rbp
      ret 8

get_sib_returnminus1:
      mov rbx , 0
      dec rbx
      mov rax , rbx           ; -1 in rax. because this is not memory.
      pop rbp



      ret 8



make_hex:
      push rbp
      push r8
      push r9
      push r10
      push r11
      push r12
      push r13
      push rbx
      push rdx
      push rax
      push rcx

      mov rax , 0
      mov [make_hex_answer] , rax
       
      mov [make_hex_answer+8] , rax
      mov [make_hex_answer+16] , rax

      mov [make_hex_answer+24] , rax

      mov [make_hex_answer+32] , rax


      mov rbp , rsp
      mov rax , [rbp+96]    ; str start in rax
      xor rbx , rbx         ; nothing in rbx

      push rax


      push rax
      call getLen
      mov r8 , rax           ; str len in r8
 

      pop rax

 

      push rax

      mov rax , r8
      mov rbx , 8
      cqo
      div rbx                 ; len(str) % 8 in rdx
      
      mov rax , 8
      sub rax , rdx           ; 8 - len(str)%8
      mov r10 , rax            ; 8 - len(str)%8 in r10
      
  

      pop rax

      cmp rdx , 0
      je make_hex_firstLoop_end

      
      mov r9 , r8;
      dec r9                  ; its ready to reach last element of array



      inc r9

make_hex_shiftLoop:
      dec r9
      cmp r9 , -1
      je make_hex_shiftLoop_end
      mov cl , [rax+r9] 
      mov r12 , r9
      add r12 , r10
      mov [rax+r12] , cl
      jmp make_hex_shiftLoop

make_hex_shiftLoop_end:

      mov r9 , 0
      dec r9

make_hex_firstLoop:



      inc r9
      cmp r9 , r10
      je make_hex_firstLoop_end
      mov cl , "0"
      mov [rax+r9] ,cl
      jmp make_hex_firstLoop



make_hex_firstLoop_end:
      xor r12 , r12
      mov r9 , 0
      sub r9 , 4
      mov r13 , 0
      dec r13

        push rax
      mov rax , 4
      call writeNum
      call newLine
      pop rax

make_hex_secondLoop:
      inc r13
      add r9 , 4
      cmp r9 , r8
      jge make_hex_secondLoop_end
      mov r12d , [rax+r9]                 ; 4 byte mikhoone inja, "0010" masalan.

      push rax
      mov rax , 4
      call writeNum
      call newLine
      pop rax


      cmp r12d , "0000"
      cmove rcx , [make_hex_hex + 0*8]
      cmp r12d , "0001"
      cmove rcx , [make_hex_hex + 1*8]
      cmp r12d , "0010"
      cmove rcx , [make_hex_hex + 2*8]
      cmp r12d , "0011"
      cmove rcx , [make_hex_hex + 3*8]
      cmp r12d , "0100"
      cmove rcx , [make_hex_hex + 4*8]
      cmp r12d , "0101"
      cmove rcx , [make_hex_hex + 5*8]
      cmp r12d , "0110"
      cmove rcx , [make_hex_hex + 6*8]
      cmp r12d , "0111"
      cmove rcx , [make_hex_hex + 7*8]
      cmp r12d , "1000"
      cmove rcx , [make_hex_hex + 8*8]
      cmp r12d , "1001"
      cmove rcx , [make_hex_hex + 9*8]
      cmp r12d , "1010"
      cmove rcx , [make_hex_hex + 10*8]
      cmp r12d , "1011"
      cmove rcx , [make_hex_hex + 11*8]
      cmp r12d , "1100"
      cmove rcx , [make_hex_hex + 12*8]
      cmp r12d , "1101"
      cmove rcx , [make_hex_hex + 13*8]
      cmp r12d , "1110"
      cmove rcx , [make_hex_hex + 14*8]
      cmp r12d , "1111"
      cmove rcx , [make_hex_hex + 15*8]

      mov [make_hex_answer + r13] , cl
      jmp make_hex_secondLoop

make_hex_secondLoop_end:


      push rax
      mov rax , 4
      call writeNum
      call newLine
      pop rax

      pop rcx
      pop rax
      pop rdx
      pop rbx
      pop r13
      pop r12
      pop r11
      pop r10
      pop r9
      pop r8

      pop rbp

      ret 8




is_new:

      push rbp
      push r8
      push r9
      push r10

      mov rbp , rsp
      mov rax , [rbp+96]    ; str start in rax
      xor rbx , rbx         ; nothing in rbx

      push rax



      push rax
      call getLen
      mov r8 , rax                 ; len in r8

      pop rax
      push rax

      push rax
      call operand_type
      mov r10 , rax

      pop rax

      cmp r10 , "Reg"
      jne is_new_false



      mov r9 , 0
      dec r9
is_new_r_loop:
      inc r9
      cmp r9 , r8
      je is_new_false


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r_loop
      
      mov rax , "true"
      pop r10
      pop r9
      pop r8

      pop rbp
      ret 8

is_new_false:

      mov rax , "false"

      pop r10
      pop r9
      pop r8

      pop rbp
      ret 8



not_all_zero:

      push rbp
      push rcx
      push r8
      push r9
      mov rbp , rsp
      mov rax , [rbp+40]    ; dispalcemnt start in rax
      xor rbx , rbx         ; nothing in rbx


      push rax

      push rax
      call getLen
      mov r8 , rax            ; len in r8

      pop rax

      mov r9 , 0
      dec r9
      mov cl , "0"
not_all_zero_loop:  
      inc r9
      cmp r9 , r8
      je not_all_zero_loop_false


      cmp [rax+r9] , cl
      je not_all_zero_loop

      mov rax , "true"
      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8

not_all_zero_loop_false:
      mov rax , "false"
      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8



old_register:

      push rbp
      push rcx
      push r8
      push r9
      mov rbp , rsp
      mov rax , [rbp+40]    ; dispalcemnt start in rax
      xor rbx , rbx         ; nothing in rbx


      push rax

      push rax
      call getLen
      mov r8 , rax          ; len in r8

      pop rax

      cmp r8 , 0
      jne is_new_r8_loop_before

      mov rax , "false"
      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8

is_new_r8_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r8_loop:
      inc r9
      cmp r9 , r8
      je is_new_r9_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r8_loop

      mov cl , "8"
      cmp [rax + r9+1] , cl
      jne is_new_r8_loop
      
      mov rax , "false"
 
      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8


is_new_r9_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r9_loop:
      inc r9
      cmp r9 , r8
      je is_new_r10_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r9_loop
      
      mov cl , "9"
      cmp [rax + r9+1] , cl
      jne is_new_r9_loop

      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8

is_new_r10_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r10_loop:
      inc r9
      cmp r9 , r8
      je is_new_r11_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r10_loop

      mov cl , "1"
      cmp [rax + r9+1] , cl
      jne is_new_r10_loop

      mov cl , "0"
      cmp [rax + r9+2] , cl
      jne is_new_r10_loop
      
      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8

is_new_r11_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r11_loop:

      inc r9
      cmp r9 , r8
      je is_new_r12_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r11_loop

      mov cl , "1"
      cmp [rax + r9+1] , cl
      jne is_new_r11_loop

      mov cl , "1"
      cmp [rax + r9+2] , cl
      jne is_new_r11_loop
      
      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8


is_new_r12_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r12_loop:
      inc r9
      cmp r9 , r8
      je is_new_r13_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r12_loop

      mov cl , "1"
      cmp [rax + r9+1] , cl
      jne is_new_r12_loop

      mov cl , "2"
      cmp [rax + r9+2] , cl
      jne is_new_r12_loop
      
      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8


is_new_r13_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r13_loop:

      inc r9
      cmp r9 , r8
      je is_new_r14_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r13_loop

      mov cl , "1"
      cmp [rax + r9+1] , cl
      jne is_new_r13_loop

      mov cl , "3"
      cmp [rax + r9+2] , cl
      jne is_new_r13_loop
      
      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8


is_new_r14_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r14_loop:

      inc r9
      cmp r9 , r8
      je is_new_r15_loop_before


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r14_loop

      mov cl , "1"
      cmp [rax + r9+1] , cl
      jne is_new_r14_loop

      mov cl , "4"
      cmp [rax + r9+2] , cl
      jne is_new_r14_loop
      
      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8

is_new_r15_loop_before:
      mov r9 , 0
      dec r9
      xor rcx , rcx
is_new_r15_loop:

      inc r9
      cmp r9 , r8
      je old_register_true


      mov cl , "r"
      cmp [rax + r9] , cl
      jne is_new_r15_loop

      mov cl , "1"
      cmp [rax + r9+1] , cl
      jne is_new_r15_loop

      mov cl , "5"
      cmp [rax + r9+2] , cl
      jne is_new_r15_loop
      
      mov rax , "false"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8


old_register_true:

      mov rax , "true"

      pop r9
      pop r8
      pop rcx
      pop rbp
      ret 8


inc_i:
      push rax

      mov rax , [i]
      inc rax
      mov [i] , rax

      pop rax

      ret


check_just_operation:

      push rbp

      mov rbp , rsp
      mov rax , [rbp+16]    ; operation start in rax
      xor rbx , rbx         ; nothing in rbx





      mov cl , "s"
      cmp [rax+0] , cl
      jne check_just_operation_2
      mov cl , "t"
      cmp [rax+1] , cl
      jne check_just_operation_2
      mov cl , "c"
      cmp [rax+2] , cl
      je check_just_operation_stc 
      

check_just_operation_2:


      mov cl , "c"
      cmp [rax+0] , cl
      jne check_just_operation_3
      mov cl , "l"
      cmp [rax+1] , cl
      jne check_just_operation_3
      mov cl , "c"
      cmp [rax+2] , cl
      je check_just_operation_clc


check_just_operation_3:

      mov cl , "s"
      cmp [rax+0] , cl
      jne check_just_operation_4
      mov cl , "t"
      cmp [rax+1] , cl
      jne check_just_operation_4
      mov cl , "d"
      cmp [rax+2] , cl
      je check_just_operation_std

check_just_operation_4:

      mov cl , "c"
      cmp [rax+0] , cl
      jne check_just_operation_5
      mov cl , "l"
      cmp [rax+1] , cl
      jne check_just_operation_5
      mov cl , "d"
      cmp [rax+2] , cl
      je check_just_operation_cld

check_just_operation_5:


      mov cl , "s"
      cmp [rax+0] , cl
      jne check_just_operation_6
      mov cl , "y"
      cmp [rax+1] , cl
      jne check_just_operation_6
      mov cl , "s"
      cmp [rax+2] , cl
      jne check_just_operation_6
      mov cl , "c"
      cmp [rax+3] , cl
      jne check_just_operation_6
      mov cl , "a"
      
      cmp [rax+4] , cl
      jne check_just_operation_6
      mov cl , "l"
      cmp [rax+5] , cl
      jne check_just_operation_6
      mov cl , "l"
      cmp [rax+6] , cl
      je check_just_operation_syscall

check_just_operation_6:

      pop rbp 
      ret 8


  check_just_operation_stc:



      mov rax , "11111001"
      mov [temp_hex] , rax
      mov rax , temp_hex
      push rax
      call make_hex



      mov rsi , make_hex_answer
      call printString
      call newLine


      jmp Exit



  check_just_operation_clc:

      mov rax , "11111000"
      mov [temp_hex] , rax
      mov rax , temp_hex
      push rax
      call make_hex



      mov rsi , make_hex_answer
      call printString
      call newLine


      jmp Exit



  check_just_operation_std:

      mov rax , "11111101"
      mov [temp_hex] , rax
      mov rax , temp_hex
      push rax
      call make_hex



      mov rsi , make_hex_answer
      call printString
      call newLine


      jmp Exit


  check_just_operation_cld:

      mov rax , "11111100"
      mov [temp_hex] , rax
      mov rax , temp_hex
      push rax
      call make_hex



      mov rsi , make_hex_answer
      call printString
      call newLine


      jmp Exit


  check_just_operation_syscall:

      mov rax , 5
      call writeNum
      call newLine

      mov rax , "00001111"
      mov [temp_hex] , rax
      mov rax , temp_hex
      push rax
      call make_hex



      mov rsi , make_hex_answer
      call printString

      mov rax , "00000101"
      mov [temp_hex] , rax
      mov rax , temp_hex
      push rax
      call make_hex



      mov rsi , make_hex_answer
      call printString
      call newLine


      jmp Exit



cmp_memory_str:
      push rbp

      push rbx
      push rcx
      push rdx
      push r9

      mov rbp , rsp
      mov rax , [rbp+48]    ; str start in rax
      mov rbx , [rbp+56]    ; string in rbx
      mov rcx , [rbp+64]    ; string len in rcx

  

      mov r9 , 0
      dec r9
 
cmp_memory_str_loop:
      xor rdx, rdx

      inc r9

      push rax
      mov rax , r9
      call writeNum
      call newLine
      pop rax

      cqo
      cmp r9 , rcx
      je cmp_memory_str_loop_end
      cqo
      mov dl , [rbx+r9]
  
      cmp [rax+r9] , dl
      je cmp_memory_str_loop



      mov rax , 0


      pop r9
      pop rdx     
      pop rcx
      pop rbx


      pop rbp
      ret 24

cmp_memory_str_loop_end:



      mov rax , 1

      
      pop r9
      pop rdx     
      pop rcx
      pop rbx


      pop rbp
      ret 24


swap_twoString:
      push rbp

      push rbx
      push rcx
      push rdx
      push r9

      mov rbp , rsp
      mov rax , [rbp+48]    ; first string start in rax
      mov rbx , [rbp+56]    ; second string start in rax

      push rax
      push rbx



      push rax
      call getLen
      mov r8 , rax        ; len in r8    


      pop rbx
      pop rax


   


      mov r9 , 0
      dec r9
      xor rcx , rcx
swap_twoString_loop:
      inc r9
      cmp r9 , r8
      je swap_twoString_loop_beforeEnd
      mov cl , [rax+r9]
      mov [swap_twoString_temp+r9] , cl
      mov cl , [rbx +r9]
      mov [rax +r9] , cl
      mov cl , [swap_twoString_temp+r9]
      mov [rbx+r9] , cl


      
      jmp swap_twoString_loop


swap_twoString_loop_beforeEnd:
      mov r9 , 0
      dec r9
      mov rax , 0
swap_twoString_loop_beforeEnd_loop:
      inc r9
      cmp r9 , 10
      je swap_twoString_loop_End
      mov [swap_twoString_temp + r9] , rax
      jmp swap_twoString_loop_beforeEnd_loop

swap_twoString_loop_End:
      pop r9
      pop rdx
      pop rcx
      pop rbx

      pop rbp
      ret 16



cmp_twoString:

      push rbp

      push rbx
      push rcx
      push rdx
      push r9

      mov rbp , rsp
      mov rax , [rbp+48]    ; first string start in rax
      mov rbx , [rbp+56]    ; second string start in rax

      push rax
      push rbx

      push rax
      call getLen
      mov r8 , rax            ; len in r8

      pop rbx
      pop rax

      mov r9 , 0
      dec r9
      xor rcx , rcx

cmp_twoString_loop:
      inc r9
      cmp r9 , r8
      je cmp_twoString_loop_end
      mov cl , [rax+r9]
      cmp [rbx+r9] , cl
      je cmp_twoString_loop

      mov rax , 0
      pop r9
      pop rdx
      pop rcx
      pop rbx

      pop rbp
      ret 16

cmp_twoString_loop_end:
      mov rax , 1
      pop r9
      pop rdx
      pop rcx
      pop rbx

      pop rbp
      ret 16

type12_operand12_swap:

      ; operation == "xchg" and type1 == "Memory"
      mov rcx , 4    
      mov rbx , "xchg"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operation
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      cmp rax , 1
      jne type12_operand12_swap_if2


      mov rcx , 4    
      mov rbx , "Memory"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , type1
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      cmp rax , 1
      jne type12_operand12_swap_if2     

      mov rax , type1
      mov rbx , type2
      push rbx
      push rax
      call swap_twoString

      mov rax , operand1
      mov rbx , operand2
      push rbx
      push rax
      call swap_twoString




type12_operand12_swap_if2:
      push rbp
      ; operation == "test" and type1 == "Memory"
      mov rcx , 4    
      mov rbx , "test"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operation
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      cmp rax , 1
      jne type12_operand12_swap_if3


      mov rcx , 4    
      mov rbx , "Memory"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , type2
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      cmp rax , 1
      jne type12_operand12_swap_if3

      mov rax , type1
      mov rbx , type2
      push rbx
      push rax
      call swap_twoString

      mov rax , operand1
      mov rbx , operand2
      push rbx
      push rax
      call swap_twoString


type12_operand12_swap_if3:


     ; operation == "bsr" and type1 == type2
      mov rcx , 3
      mov rbx , "bsr"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operation
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      cmp rax , 1
      jne type12_operand12_swap_if4

      mov rax , type1
      mov rbx , type2
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne type12_operand12_swap_if4

      mov rax , operand1
      mov rbx , operand2
      push rbx
      push rax
      call swap_twoString

type12_operand12_swap_if4:

     ; operation == "bsf" and type1 == type2
      mov rcx , 3
      mov rbx , "bsf"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operation
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
      cmp rax , 1
      jne type12_operand12_swap_if5

      mov rax , type1
      mov rbx , type2
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne type12_operand12_swap_if5
      
      mov rax , operand1
      mov rbx , operand2
      push rbx
      push rax
      call swap_twoString

type12_operand12_swap_if5:
      pop rbp
      ret



change_mod_displc:
      mov rax , [displc1]
      mov rbx , [displc2]
      cmp rax , 8
      jne change_mod_displc2
      cmp rbx , 8
      jne change_mod_displc2
      mov rax , "01"
      mov [mod] , rax
      ret

change_mod_displc2:
      mov rax , [displc1]
      mov rbx , [displc2]
      cmp rax , 16
      jne change_mod_displc3
      cmp rbx , 16
      jne change_mod_displc3
      mov rax , "10"
      mov [mod] , rax
      ret

change_mod_displc3:
      mov rax , [displc1]
      mov rbx , [displc2]
      cmp rax , 32
      jne change_mod_displc4
      cmp rbx , 32
      jne change_mod_displc4
      mov rax , "10"
      mov [mod] , rax
      ret

change_mod_displc4:
      ret



change_mod_displc_second:

      mov rax , "Reg"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne change_mod_displc_second2

      mov rax , "Reg"
      mov [temp] , rax
      mov rax , type2
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne change_mod_displc_second2   
      mov rax , "11" 
      mov [mod]  , rax
      ret


change_mod_displc_second2:
     
      mov rax , "Reg"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne change_mod_displc_second3

      mov rax , "true"
      mov [temp] , rax
      mov rax , single_operand
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne change_mod_displc_second3 
      mov rax , "11" 
      mov [mod]  , rax
      ret
 

change_mod_displc_second3:
      ret


start_is_new_2:

      mov rax , "Memory"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne start_is_new_2_false

      mov rax , sib1_base
      push rax
      call is_new
      mov [temp] , rax
      mov rax , temp
      mov rbx , "true"
      mov [temp2] , rbx
      mov rbx ,temp2
      push rax
      push rbx
      call cmp_twoString
      cmp rax , 1
      je start_is_new2_true

      mov rax , sib1_index
      push rax
      call is_new
      mov [temp] , rax
      mov rax , temp
      mov rbx , "true"
      mov [temp2] , rbx
      mov rbx ,temp2
      push rax
      push rbx
      call cmp_twoString
      cmp rax , 1
      je start_is_new2_true

      jmp start_is_new_2_false

      

start_is_new2_true:
      mov rax , "true"
      mov [new_register] , rax
      ret

start_is_new_2_false:
      ret




start_is_new_3:

      mov rax , "Memory"
      mov [temp] , rax
      mov rax , type2
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne start_is_new_3_false

      mov rax , sib2_base
      push rax
      call is_new
      mov [temp] , rax
      mov rax , temp
      mov rbx , "true"
      mov [temp2] , rbx
      mov rbx ,temp2
      push rax
      push rbx
      call cmp_twoString
      cmp rax , 1
      je start_is_new3_true

      mov rax , sib2_index
      push rax
      call is_new
      mov [temp] , rax
      mov rax , temp
      mov rbx , "true"
      mov [temp2] , rbx
      mov rbx ,temp2
      push rax
      push rbx
      call cmp_twoString
      cmp rax , 1
      je start_is_new3_true

      jmp start_is_new_3_false

      

start_is_new3_true:
      mov rax , "true"
      mov [new_register] , rax
      ret

start_is_new_3_false:
      ret




Opcode_two_operand_noSwap:

      mov rax , "xor"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_xor


      mov rax , "bsf"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_bsf


      mov rax , "bsr"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_bsr


      mov rax , "adc"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_adc


      mov rax , "add"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_add


      mov rax , "and"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_and



      mov rax , "or"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_or




      mov rax , "xadd"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_xadd


      mov rax , "mov"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_mov




      mov rax , "sub"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_sub




      mov rax , "sbb"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_sbb



      mov rax , "cmp"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_cmp


      mov rax , "test"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_test


      mov rax , "imul"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_imul



      mov rax , "idiv"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_noSwap_idiv









Opcode_two_operand_noSwap_xor:
      mov rax , "001100"
      mov [opCode] , rax
      ret
Opcode_two_operand_noSwap_adc:
      mov rax , "000100"
      mov [opCode] , rax

      mov rax , "Imdiate"
      mov [temp] , rax
      mov rax , type2
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_two_operand_noSwap_adc_notIm

      mov rax , "100000"
      mov [opCode] , rax

Opcode_two_operand_noSwap_adc_notIm:
      ret

Opcode_two_operand_noSwap_add:
      mov rax , "000000"
      mov [opCode] , rax

      mov rax , "Imdiate"
      mov [temp] , rax
      mov rax , type2
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_two_operand_noSwap_add_notIm

      mov rax , "100000"
      mov [opCode] , rax


      mov rax , "Memory"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_two_operand_noSwap_add_D1
      mov rax , "0"
      mov [D] , rax
      ret
Opcode_two_operand_noSwap_add_D1:
      mov rax , "1"
      mov [D] , rax
      ret
Opcode_two_operand_noSwap_add_notIm:
      ret


Opcode_two_operand_noSwap_and:
      mov rax , "001000"
      mov [opCode] , rax



Opcode_two_operand_noSwap_or:
      mov rax , "000010"
      mov [opCode] , rax

Opcode_two_operand_noSwap_xadd:
      mov rax , "00001111"
      mov [opCode] , rax
      mov rax , "110000"
      mov [opCode+8] , rax

Opcode_two_operand_noSwap_mov:



      mov rax , "100010"
      mov [opCode] , rax

      mov rax , "Imdiate"
      mov [temp] , rax
      mov rax , type2
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_two_operand_noSwap_mov_notIm

      mov rax , "1011"
      mov [opCode] , rax

Opcode_two_operand_noSwap_mov_notIm:
      ret


Opcode_two_operand_noSwap_sub:

      mov rax , "001010"
      mov [opCode] , rax


Opcode_two_operand_noSwap_bsf:
      mov rax , "00001111"
      mov [opCode] , rax
      mov rax , "101111"
      mov [opCode+8] , rax

Opcode_two_operand_noSwap_bsr:
      mov rax , "00001111"
      mov [opCode] , rax
      mov rax , "101111"
      mov [opCode+8] , rax


Opcode_two_operand_noSwap_sbb:
      mov rax , "000110"
      mov [opCode] , rax
Opcode_two_operand_noSwap_cmp:
      mov rax , "001110"
      mov [opCode] , rax

Opcode_two_operand_noSwap_test:

      mov rax , "100001"
      mov [opCode] , rax
Opcode_two_operand_noSwap_imul:

      mov rax , "00001111"
      mov [opCode] , rax
      mov rax , "101011"
      mov [opCode+8] , rax

      mov rax , "true"
      mov [temp] , rax
      mov rax , single_operand
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_two_operand_noSwap_imul_Notsingle

      mov rax , "111101"
      mov [opCode] , rax
      mov rax , 0
      mov [opCode+8] , rax

      mov rax , "1"
      mov [D] , rax
      mov [W] , rax
      mov rax , "101"
      mov [Regop] , rax
      ret
Opcode_two_operand_noSwap_imul_Notsingle:
      mov rax , "1"
      mov [D] , rax
      mov [W] , rax

      ret


Opcode_two_operand_noSwap_idiv:

      mov rax , "true"
      mov [temp] , rax
      mov rax , single_operand
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_two_operand_noSwap_idiv_Notsingle

      mov rax , "111101"
      mov [opCode] , rax
      mov rax , "1"
      mov [D] , rax
      mov rax , "111"
      mov [Regop] , rax


Opcode_two_operand_noSwap_idiv_Notsingle:
      ret



Opcode_two_operand_Swap:

      mov rax , "xchg"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_Swap_xchg

      mov rax , "test"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_two_operand_Swap_test



Opcode_two_operand_Swap_xchg:
      mov rax , "100001"
      mov [opCode] , rax
      mov rax , "1"
      mov [D] , rax
Opcode_two_operand_Swap_test:

      mov rax , "100001"
      mov [opCode] , rax
      mov rax , "0"
      mov [D] , rax



Opcode_one_operand:
      mov rax , "inc"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_inc


      mov rax , "dec"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_dec

      mov rax , "shl"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_shl


      mov rax , "shr"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_shr

      mov rax , "neg"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_neg

      mov rax , "not"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_not


      mov rax , "jmp"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_jmp


      mov rax , "call"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je Opcode_one_operand_call





Opcode_one_operand_inc:

      mov rax , "111111"
      mov [opCode] , rax
      mov rax , "000"
      mov [Regop] , rax

Opcode_one_operand_dec:
      mov rax , "111111"
      mov [opCode] , rax
      mov rax , "001"
      mov [Regop] , rax

Opcode_one_operand_shl:
      mov rax , "110000"
      mov [opCode] , rax
      mov rax , "100"
      mov [Regop] , rax
      mov rax , "0"
      mov [D] , rax

      mov rax , "true"
      mov [temp] , rax
      mov rax , single_operand
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_one_operand_shl_notSingle

      mov rax , "110100"
      mov [opCode] , rax
Opcode_one_operand_shl_notSingle:
      mov rax , "true"
      mov [single_operand] , rax
      ret

Opcode_one_operand_shr:


      mov rax , "110000"
      mov [opCode] , rax
      mov rax , "101"
      mov [Regop] , rax
      mov rax , "0"
      mov [D] , rax

      mov rax , "true"
      mov [temp] , rax
      mov rax , single_operand
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Opcode_one_operand_shr_notSingle

      mov rax , "110100"
      mov [opCode] , rax
Opcode_one_operand_shr_notSingle:
      mov rax , "true"
      mov [single_operand] , rax
      ret


Opcode_one_operand_neg:


      mov rax , "111101"
      mov [opCode] , rax
      mov rax , "011"
      mov [Regop] , rax
      mov rax , "1"
      mov [D] , rax

Opcode_one_operand_not:

      mov rax , "111101"
      mov [opCode] , rax
      mov rax , "010"
      mov [Regop] , rax
      mov rax , "1"
      mov [D] , rax

Opcode_one_operand_jmp:

      mov rax , "111111"
      mov [opCode] , rax
      mov rax , "100"
      mov [Regop] , rax
      mov rax , "1"
      mov [D] , rax
      mov [W] , rax

Opcode_one_operand_call:

      mov rax , "111111"
      mov [opCode] , rax
      mov rax , "010"
      mov [Regop] , rax
      mov rax , "1"
      mov [D] , rax



fsingle_operand:

 

      mov rax , [reg1]
      cmp rax , 64
      je fsingle_operand_then

      mov rax , "true"
      mov [temp] , rax
      mov rax , new_register
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then

      ;///////////////////////////////////// else


      
fsingle_operand_then:
      ; ///////////////////////// 64 bit single operand

 

      push rax 
      mov rax , 3
      call writeNum
      call newLine
      pop rax

      mov rax , operand1
      push rax
      call getLen
      mov r8 , rax      ; len in r8

      mov r9 , 0
      dec r9


      xor rcx , rcx


      mov rax , operand1
 fsingle_operand_then_loop:     

      push rax
      mov rax , 61
      call writeNum
      call newLine
      pop rax



      inc r9
      cmp r9 , r8
      je fsingle_operand_then_loop_end_notFind


      push rax
      mov rax , 49
      call writeNum
      call newLine
      pop rax


      mov cl , "D"
      cmp [rax + r9] , cl
      jne fsingle_operand_then_loop



  
      mov cl , "W"
      cmp [rax + r9 +1] , cl
      jne fsingle_operand_then_loop




      mov cl , "O"
      cmp [rax + r9 +2] , cl
      jne fsingle_operand_then_loop   
         

      mov cl , "R"
      cmp [rax + r9 +3] , cl
      jne fsingle_operand_then_loop  

      mov cl , "D"
      cmp [rax + r9 +4] , cl
      jne fsingle_operand_then_loop               ; age azinja rad she dword peyda shode



      jmp fsingle_operand_then_loop_end_found


fsingle_operand_then_loop_end_found:


      mov rax , "0"
      mov [rexW] , rax
      jmp fsingle_operand_then_loop_end_notFind_after



      
fsingle_operand_then_loop_end_notFind:




      mov rax , "1"
      mov [rexW] , rax
fsingle_operand_then_loop_end_notFind_after:
      mov rax , "0"
      mov [rexR] , rax
      mov [rexX] , rax
      mov [rexB] , rax


      mov rax , "jmp"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_notJmp
      mov rax , "0"
      mov [rexW] , rax
fsingle_operand_then_notJmp:

   
      mov rax , "Reg"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_type1_Reg_else   

      mov rax , "11"
      mov [mod] , rax
      mov rax , operand1
      push rax
      call getReg64Dict
      mov [single_operand_regValue] , rax

      xor rcx , rcx
      mov cl , [single_operand_regValue]
      mov [rexB] , rcx


      mov rax , operand1
      push rax
      call getLen
      mov r8 , rax      ; len in r8

      mov rax , 1
      mov rbx , r8
      mov rcx , rm
      mov rdx , single_operand_regValue
      push rax
      push rbx
      push rcx
      push rdx
      call get_str_slice

      mov rax , "1"
      mov [W] , rax


      xor rax , rax
      mov rax , operand1
      push rax
      call register_type
      cmp rax , 8
      jne fsingle_operand_then_notJmp_WnotZero

      mov rax , "shr"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_notJmp_WZero

      mov rax , "shl"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_notJmp_WZero

      jmp fsingle_operand_then_notJmp_WnotZero

fsingle_operand_then_notJmp_WZero:
      mov rax , "0"
      mov [W] , rax

fsingle_operand_then_notJmp_WnotZero:



      jmp fsingle_operand_then_type1_Reg_else_after



fsingle_operand_then_type1_Reg_else:                   ; type1 is not Reg





      xor rax , rax
      mov rax , operand1
      push rax
      call memory_type
      mov r8 , "0"
      mov r9,"1"

      cmp rax , 8
      cmove r12 , r8
      cmp rax , 8
      cmovne r12, r9
      mov [W] , r12
      
      mov rax , [sib1_scale]

      cmp rax , ""
      jne fsingle_operand_then_if2_then

      mov rax , "rbp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then

      mov rax , "ebp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then


      mov rax , "bp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then

      jmp fsingle_operand_then_if2_else
fsingle_operand_then_if2_then:
      mov rax , "true"
      mov [sib] , rax
      mov rax , [sib1_base]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif

      mov rax , "ebp"
      mov [sib1_base] , rax
      mov rax , "true"
      mov [displacement_32] , rax

      mov rax , "true"
      mov [displacement_32] , rax

      mov rax , "00"
      mov [mod] , rax

      mov rax , [sib1_displacment]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_tinyIF
      mov rax , "00"
      mov [sib1_displacment] , rax


fsingle_operand_then_if2_then_tinyIF:

      jmp fsingle_operand_then_if2_then_if1_elif_after
fsingle_operand_then_if2_then_if1_elif:

      mov rax , "rbp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif_then


      mov rax , "ebp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif_then


      mov rax , "bp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif_then

      jmp fsingle_operand_then_if2_then_if1_elif_then_after

      ;////////////////////////////////;elif(sib1[0] == "rbp" or sib1[0] == "ebp" or sib1[0] == "bp"):
fsingle_operand_then_if2_then_if1_elif_then:
      mov rax , "10"
      mov [temp] , rax
      mov rax , mod
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif_then_tinyIF1
      mov rax , "01"
      mov [mod] , rax



fsingle_operand_then_if2_then_if1_elif_then_tinyIF1:
      mov rax , "false"
      mov [displacement_32] , rax
      mov rax , [sib1_index]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif_then_tinyIF2

      mov rax , [sib1_scale]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif_then_tinyIF2
      mov rax , "false"
      mov [sib] , rax

fsingle_operand_then_if2_then_if1_elif_then_tinyIF2:
      mov rax , [sib1_displacment]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif_then_tinyIF3
      mov rax , "00"
      mov [sib1_displacment] , rax

fsingle_operand_then_if2_then_if1_elif_then_tinyIF3:

      jmp fsingle_operand_then_if2_then_if1_if4

fsingle_operand_then_if2_then_if1_elif_then_after:
      ; nothign doing here
fsingle_operand_then_if2_then_if1_elif_after:

                              ; elif(sib1[0] == "" and sib1[1] == "" and sib1[2] == ""):


      mov rax , [sib1_base]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif2_after
      mov rax , [sib1_index]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif2_after
      mov rax , [sib1_scale]
      cmp rax , ""
      jne fsingle_operand_then_if2_then_if1_elif2_after
      mov rax , "00100101"
      mov [Sib] , rax
      mov rax , "00"
      mov [mod] , rax
      mov rax , "true"
      mov [sib] , rax
      mov [directAddress] , rax

      jmp fsingle_operand_then_if2_then_if1_if4

fsingle_operand_then_if2_then_if1_elif2_after:

      mov rax , "r12"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif3_then


      mov rax , "r12d"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif3_then

      mov rax , "rsp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif3_then


      mov rax , "esp"
      mov [temp] , rax
      mov rax , sib1_base
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      je fsingle_operand_then_if2_then_if1_elif3_then


      jmp fsingle_operand_then_if2_then_if1_elif3_then_after
fsingle_operand_then_if2_then_if1_elif3_then:

      mov rax , "true"
      mov [sib] , rax
      mov rax , "esp"
      mov [sib1_index] , rax

      mov rax , "1"
      mov [sib1_scale] , rax
      mov rax , [sib1_displacment]
      cmp rax , ""
      je fsingle_operand_then_if2_then_if1_elif3_then_TinyIF
      mov rax , "true"
      mov [displacement_32] , rax
fsingle_operand_then_if2_then_if1_elif3_then_TinyIF:
      ; nothing is doing here
      
fsingle_operand_then_if2_then_if1_if4:         ;if(sib):
      mov rax , "true"
      mov [temp] , rax
      mov rax , sib
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if1_if5
      mov rax , "100"
      mov [rm] , rax


fsingle_operand_then_if2_then_if1_if5:                ;///////////////piade sazi nashode kamel
    ;  mov rax , "true"
   ;   mov [temp] , rax
  ;    mov rax , sib
   ;   mov rbx , temp
   ;   push rbx
   ;   push rax
    ;  call cmp_twoString
   ;   cmp rax , 1 
    ;  jne fsingle_operand_then_if2_then_if1_if5_elif

   ;   mov rax , "false"
  ;    mov [temp] , rax
   ;   mov rax , DirectAddress
   ;   mov rbx , temp
   ;;   push rbx
   ;   push rax
  ;    call cmp_twoString
   ;   cmp rax , 1 
  ;    jne fsingle_operand_then_if2_then_if1_if5_elif


  ;    mov rax , sib1_index
  ;    push rax
  ;    call getReg64Dict
  ;    mov [temp] , rax
  ;    xor rax , rax
  ;    mov al , [temp]
    ;  mov [rexX] , rax
;
    ;  mov rax , sib1_base
  ;    push rax
    ;  call getReg64Dict
    ;  mov [temp] , rax
    ;  xor rax , rax
    ;  mov al , [temp]
    ;  mov [rexB] , rax

    ;  mov rax , sib1_scale
    ;  push rax
    ;  call getScaleDict
    ;  mov [Sib] , rax

    ;  mov rax , sib1_index
    ;  push rax

      

   ;  mov rax , sib1_index
    ;  push rax
    ;  call getReg64Dict



fsingle_operand_then_if2_then_if1_if5_elif:           ;elif(DirectAddress == False):
      mov rax , "false"
      mov [temp] , rax
      mov rax , directAddress
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1 
      jne fsingle_operand_then_if2_then_if1_if5_elif_end

      mov rax , sib1_base
      push rax
      call getReg64Dict
      mov [temp] , rax
      xor rax , rax
      mov al , [temp]
      mov [rexB] , rax

      
      mov rax , 1
      mov rbx , 8
      mov rcx , rm
      mov rdx , temp
      push rax
      push rbx
      push rcx
      push rdx
      call get_str_slice


      push rax
      mov rax,34
      call writeNum
      call newLine
      pop rax


fsingle_operand_then_if2_then_if1_if5_elif_end:
      mov rax , [sib1_displacment]
      mov [displacement] , rax

fsingle_operand_then_if2_then_if1_elif3_then_after: ;if(mod == "01" and displacement_32 == True):
      mov rax , ""
      mov [prefix] , rax


      mov rax , "01"
      mov [temp] , rax
      mov rax , mod
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if2_not

      mov rax , "true"
      mov [temp] , rax
      mov rax , displacement
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if2_not     

      fsingle_operand_then_if2_then_f2:
            mov rax , "10"
            mov [mod] , rax

fsingle_operand_then_if2_then_if2_not:


      mov rax , "Memory"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if3_not     

      fsingle_operand_then_if2_then_if3:

            xor rax , rax
            mov rax , operand1
            push rax
            call memory_type
            mov r8 , rax                  ;operand_size

            xor rax , rax
            mov rax , sib1_base
            push rax
            call register_type
            mov r9 , rax                  ;operand_size   

            xor rax , rax
            mov rax , sib1_index
            push rax
            call register_type
            mov r10 , rax                  ;operand_size   

            cmp r9 , r10
            cmovl r9 , r10          ; max in adress_size

            mov rax , r9
            cmp rax , 32
            jne fsingle_operand_then_if2_then_if3_tinyIF1_not
                  fsingle_operand_then_if2_then_if3_tinyIF1:
                        mov rax , "67"
                        mov [prefix] , rax
                        jmp fsingle_operand_then_if2_then_if3_tinyIF2
            fsingle_operand_then_if2_then_if3_tinyIF1_not:
            mov rax , r9
            cmp rax , 16
            jne fsingle_operand_then_if2_then_if3_tinyIF2_not
                  fsingle_operand_then_if2_then_if3_tinyIF2:
                        mov rax , prefix
                        cmp rax , ""
                        jne fsingle_operand_then_if2_then_if3_tinyIF2_tiny
                        fsingle_operand_then_if2_then_if3_tinyIF2_tiny:
                              mov rax , "66"
                              mov [prefix+2] , rax

                              jmp fsingle_operand_then_if2_then_if3_tinyIF2_not
                  fsingle_operand_then_if2_then_if3_tinyIF2_tiny_not:
                        mov rax , "66"
                        mov [prefix] , rax   
            fsingle_operand_then_if2_then_if3_tinyIF2_not:

fsingle_operand_then_if2_then_if3_not:

      xor rax , rax
      mov rax , r8
      push rax
      call register_type
      mov r9 , "66"
      cmp rax , 16
      jne fsingle_operand_then_if2_then_if3_not_if_not
            fsingle_operand_then_if2_then_if3_not_if:
                  mov [prefix] , r9
      fsingle_operand_then_if2_then_if3_not_if_not:

      mov rax , answer
      push rax
      call make_str_zero

      mov eax , "0100"
      mov [answer] , eax


      mov rbx , rexW
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , rexR
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , rexB
      mov rax , answer
      push rbx
      push rax
      call str_concat



      mov rbx , opCode
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , D
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , W
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , mod
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , Regop
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , rm
      mov rax , answer
      push rbx
      push rax
      call str_concat



      push rax
      mov rax,34
      call writeNum
      call newLine
      pop rax

      mov rax , "push"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if4_not
            fsingle_operand_then_if2_then_if4:
                  mov rax , "Reg"
                  mov [temp] , rax
                  mov rax , type1
                  mov rbx , temp
                  push rbx
                  push rax
                  call cmp_twoString
                  cmp rax , 1
                  jne fsingle_operand_then_if2_then_if4_if1_not
                        fsingle_operand_then_if2_then_if4_if1:

                                    push rax
                                    mov rax,34
                                    call writeNum
                                    call newLine
                                    pop rax

                                    mov rax , answer
                                    push rax
                                    call make_str_zero

                                    mov eax , "0100"
                                    mov [answer] , eax


                                    mov rbx , rexW
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rbx , rexR
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rbx , rexX
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rbx , rexB
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rax , "01010"
                                    mov [temp] , rax
                                    mov rbx , temp
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat
                                    
                                    mov rbx , rm
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                              jmp fsingle_operand_then_if2_then_if4_if1_not_after

                  fsingle_operand_then_if2_then_if4_if1_not:

                        mov rax , answer
                        push rax
                        call make_str_zero

                        mov eax , "0100"
                        mov [answer] , eax


                        mov rbx , rexW
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , rexR
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , rexX
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , rexB
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rax , "11111111"
                        mov [temp] , rax
                        mov rbx , temp
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , mod
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rax , "110"
                        mov [temp] , rax
                        mov rbx , temp
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat
                        
                        mov rbx , rm
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                  fsingle_operand_then_if2_then_if4_if1_not_after:

                        jmp fsingle_operand_then_if2_then_if4_not_after

      fsingle_operand_then_if2_then_if4_not:


      fsingle_operand_then_if2_then_if4_not_after:

      
      mov rax , "pop"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if5_not
            fsingle_operand_then_if2_then_if5:
                  mov rax , "Reg"
                  mov [temp] , rax
                  mov rax , type1
                  mov rbx , temp
                  push rbx
                  push rax
                  call cmp_twoString
                  cmp rax , 1
                  jne fsingle_operand_then_if2_then_if5_if1_not
                        fsingle_operand_then_if2_then_if5_if1:
                                    mov rax , answer
                                    push rax
                                    call make_str_zero

                                    mov eax , "0100"
                                    mov [answer] , eax


                                    mov rbx , rexW
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rbx , rexR
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rbx , rexX
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rbx , rexB
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                                    mov rax , "01011"
                                    mov [temp] , rax
                                    mov rbx , temp
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat
                                    
                                    mov rbx , rm
                                    mov rax , answer
                                    push rbx
                                    push rax
                                    call str_concat

                              jmp fsingle_operand_then_if2_then_if5_if1_not_after

                  fsingle_operand_then_if2_then_if5_if1_not:

                        mov rax , answer
                        push rax
                        call make_str_zero

                        mov eax , "0100"
                        mov [answer] , eax


                        mov rbx , rexW
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , rexR
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , rexX
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , rexB
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rax , "10001111"
                        mov [temp] , rax
                        mov rbx , temp
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rbx , mod
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                        mov rax , "000"
                        mov [temp] , rax
                        mov rbx , temp
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat
                        
                        mov rbx , rm
                        mov rax , answer
                        push rbx
                        push rax
                        call str_concat

                  fsingle_operand_then_if2_then_if5_if1_not_after:

                        jmp fsingle_operand_then_if2_then_if5_not

      fsingle_operand_then_if2_then_if5_not:

      mov rax , "true"
      mov [temp] , rax
      mov rax , sib
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if6_not
            fsingle_operand_then_if2_then_if6:
                  mov rbx , Sib
                  mov rax , answer
                  push rbx
                  push rax
                  call str_concat
      fsingle_operand_then_if2_then_if6_not:

      mov rax , answer
      push rax
      call make_hex
      mov rsi , make_hex_answer
      call printString
      call newLine

      mov rax , answer
      push rax
      call make_str_zero    


      mov rax , make_hex_answer
      push rax
      call getLen
      mov r8 , rax
      
      mov rax , 0
      mov rbx , r8
      mov rcx , answer
      mov rdx , make_hex_answer
      push rax
      push rbx
      push rcx
      push rdx
      call get_str_slice

      mov rax , displacement
      push rax
      call make_reverse

      mov rax , "true"
      mov [temp] , rax
      mov rax , displacement_32
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if7_not
            fsingle_operand_then_if2_then_if7:
                  mov rax , displacement
                  push rax
                  call getLen
                  mov r8 , 8
                  sub r8 , rax
                  mov r9 , 0
                  dec r9
                  fsingle_operand_then_if2_then_if7_loop:
                        inc r9
                        cmp r9 , r8
                        je fsingle_operand_then_if2_then_if7_loop_end
                        mov rax , "0"
                        mov [temp] , rax
                        mov rbx , temp
                        mov rax , displacement
                        push rbx
                        push rax
                        call str_concat

                        jmp fsingle_operand_then_if2_then_if7_loop


                  fsingle_operand_then_if2_then_if7_loop_end:



      fsingle_operand_then_if2_then_if7_not:
            mov rax , temparr
            push rax
            call make_str_zero


            mov rbx , prefix
            mov rax , temparr
            push rbx
            push rax
            call str_concat

          
            mov rbx , answer
            mov rax , temparr
            push rbx
            push rax
            call str_concat
  
            mov rbx , displacement
            mov rax , temparr
            push rbx
            push rax
            call str_concat
      
            mov rax , answer
            push rax
            call make_str_zero

            mov rbx , temparr
            mov rax , answer
            push rbx
            push rax
            call str_concat

            ; //////////////////////////////////// handle nashode baraue of(immediate)


      mov rax , "true"
      mov [temp] , rax
      mov rax , Immediate
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fsingle_operand_then_if2_then_if8_not

            fsingle_operand_then_if2_then_if8:
                  mov rax , operand2
                  push rax
                  call getLen
                  mov r8 , rax            ; len operan2 in r8

                  cmp r8 , 1
                  je fsingle_operand_then_if2_then_if8_if1
                  mov r8b , [operand2+1]
                  cmp r8b , "x"
                  je fsingle_operand_then_if2_then_if8_if1
                  jmp fsingle_operand_then_if2_then_if8_else
                  
                        fsingle_operand_then_if2_then_if8_if1:
                              mov rax , temparr
                              push rax
                              call make_str_zero

                              mov rax , operand2
                              push rax
                              call getLen
                              mov r8 , rax

                              mov rax , 2
                              mov rbx , r8
                              mov rcx , temparr
                              mov rdx , operand2
                              push rax
                              push rbx
                              push rcx
                              push rdx
                              call get_str_slice

                              mov rax , operand2
                              push rax
                              call make_str_zero

                              mov rbx , operand2
                              mov rax , temparr
                              push rbx
                              push rax
                              call str_concat

                        jmp fsingle_operand_then_if2_then_if8_else_after
            
                  fsingle_operand_then_if2_then_if8_else:


                              mov rax , 2
                              mov rbx , r8
                              mov rcx , temparr
                              mov rdx , operand2
                              push rax
                              push rbx
                              push rcx
                              push rdx
                              call get_str_slice

                              mov rax , operand2
                              push rax
                              call make_str_zero

                              mov rbx , temparr
                              mov rax , operand2
                              push rbx
                              push rax
                              call str_concat
                  fsingle_operand_then_if2_then_if8_else_after:

      fsingle_operand_then_if2_then_if8_not:
            mov rax , operand2
            push rax
            call make_reverse

            mov rbx , operand2
            mov rax , answer
            push rbx
            push rax
            call str_concat



      mov rsi , answer
      call printString
      call newLine
      jmp Exit
            
fsingle_operand_then_if2_else:  


      ;///////////////////////////////////// baraye 32 bit.baad miam soraghesh.
      ret

fsingle_operand_then_if2_else_after:

ret
fsingle_operand_then_type1_Reg_else_after:

      ret



fdual_operand:
      mov rax , "01"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fdual_operand_if1_not


      mov rax , "Memory"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fdual_operand_if1_not
      

      mov rax , ""
      mov [temp] , rax
      mov rax , sib1_scale
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fdual_operand_if1_not


      mov rax , [displc1]
      cmp rax , 8
      jle fdual_operand_if1_not

      mov rax , "01"
      mov [mod] , rax


fdual_operand_if1_not:

      mov rax , "01"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fdual_operand_if2_not


      mov rax , "Memory"
      mov [temp] , rax
      mov rax , type2
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fdual_operand_if2_not
      

      mov rax , ""
      mov [temp] , rax
      mov rax , sib2_scale
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne fdual_operand_if2_not


      mov rax , [displc2]
      cmp rax , 8
      jle fdual_operand_if2_not

      mov rax , "01"
      mov [mod] , rax



fdual_operand_if2_not:
      mov rax , [reg1]
      cmp rax , 64
      je fdual_operand_if3_yes
      
      mov rax , [reg2]
      cmp rax , 64
      je fdual_operand_if3_yes
      mov rax , "0"
      mov [rexW] , rax
      jmp fdual_operand_if3_yes_after

fdual_operand_if3_yes:
      mov rax , "1"
      mov [rexW] , rax

fdual_operand_if3_yes_after:
str_concat:
      push rbp

      mov rbp , rsp
      mov rax , [rbp+16]    ; first string start in rax. (behesh ezafe mishe)
      mov rbx , [rbp+24]    ; second string start in rax

      push rax 
      push rbx

      push rax
      call getLen
      mov r14 , rax            ; len first string in r8


      pop rbx
      pop rax

      push rax
      push rbx

      mov rax , rbx
      push rax
      call getLen
      mov r15 , rax
      add r15 , r14            ; len second string in r10


      pop rbx
      pop rax

      push rax
      mov rax , r15
      call writeNum
      call newLine
      pop rax

      mov r9 , r14
      dec r9
      xor rcx , rcx
      mov r12 , 0

      dec r12

 str_concat_loop:   

  
      inc r12
      inc r9
      cmp r9 , r15
      je str_concat_loop_end
      cqo 

      mov cl , [rbx+r12]
      mov [rax+r9] , cl


      jmp str_concat_loop



str_concat_loop_end:



      pop rbp
      ret 16


make_str_zero:

      push rbp

      mov rbp , rsp
      mov rax , [rbp+16]    ; string start in rax.

      mov r8 ,0
      dec r8
make_str_zero_loop:
      inc r8
      cmp r8 , 10
      je make_str_zero_loop_end
      mov r9 , 0
      mov [rax +r8] , r9
      jmp make_str_zero_loop
make_str_zero_loop_end:
      pop rbp
      ret 8


endFunctions: 
  

      mov rbx , "gfjfd"
      mov [operand] , rbx
      mov rax , operand
      push rax
      call getLen
      call writeNum
      call newLine


      mov rbx , "gfRfd"
      mov [operand] , rbx
      mov rax , operand
      push rax
      call operand_type
      mov [temp] , rax
      mov rsi , temp
      call printString
      call newLine


      xor rax , rax
      mov rbx , "j3dff"
      mov [operand] , rbx
      mov rax , operand
      push rax
      call register_type
      call writeNum
      call newLine




      mov al , "P"
      mov [tempop] , al
      mov al , "T"
      mov [tempop + 1] , al
      mov al , "R"
      mov [tempop + 2] , al
      mov al , "Q"
      mov [tempop + 3] , al
      mov al , "W"
      mov [tempop + 4] , al
      mov al , "O"
      mov [tempop + 5] , al
      mov al , "R"
      mov [tempop + 6] , al
      mov al , "D"
      mov [tempop + 7] , al 


      xor rax , rax
      mov rbx , "PTRWORD"
      mov [operand] , rbx
      mov rax , tempop
      push rax
      call getLen
      call writeNum
      call newLine

      mov rax , tempop
      push rax
      call make_reverse
      mov rsi , tempop
      call printString
      call newLine


      mov rax , 1
      mov rbx , 4
      mov rcx , tempfortest
      mov rdx , tempop
      push rax
      push rbx
      push rcx
      push rdx
      call get_str_slice
      mov rsi , tempfortest
      call printString
      call newLine


      mov rax , 50
      call writeNum
      call newLine
      mov rbx , 3
      cqo
      div rbx
      call writeNum
      call newLine
      mov rax , 3
      call writeNum
      call newLine
      mov rax , rdx
      call writeNum
      call newLine




      mov al , "1"
      mov [tempop] , al
      mov al , "1"
      mov [tempop + 1] , al
      mov al , "1"
      mov [tempop + 2] , al
      mov al , "1"
      mov [tempop + 3] , al
      mov al , "1"
      mov [tempop + 4] , al
      mov al , "0"
      mov [tempop + 5] , al
      mov al , "1"
      mov [tempop + 6] , al
      mov al , "0"
      mov [tempop + 7] , al 


      mov rax , tempop
      push rax
      call make_hex
      mov rsi , make_hex_answer
      call printString
      call newLine

      mov rax , 4
      call writeNum
      call newLine


      xor rax , rax
      mov rbx , "00100"
      mov [operand] , rbx
      mov rax , operand
      push rax
      call not_all_zero

      mov [operand] , rax
      mov rsi , operand
      call printString
      call newLine


      xor rax , rax
      mov rbx , "fdr8d"
      mov [operand] , rbx
      mov rax , operand
      push rax
      call old_register

      mov [operand] , rax
      mov rsi , operand
      call printString
      call newLine


      mov rax , 0
      mov rdi , 0
      mov rsi , inp
      mov rdx , 100                 ; reading input
      syscall

      
      push rax

      mov rsi , inp
      call printString
      call newLine
      pop rax


  
      mov rax , [i]
      call writeNum
      call newLine
      
      push rax

      mov rax , inp
      push rax
      call getLen
      mov r8 , rax            ; len(inp) in r8
      dec r8                  ; decreament beacuse enter at the end of string i shouldnt read it.
      pop rax


      mov r10 , 0
      dec r10
while_get_operation:


      mov r9 , [i]
      cmp r9 , r8
      jge while_get_operation_end
      inc r10
      mov cl , [inp+r9]
      cmp cl , " "
      je while_get_operation_end
      mov [operation + r10] , cl
      call inc_i

      jmp while_get_operation



while_get_operation_end:
      mov r9 , [i]
      cmp r9 , r8
      jge while_get_operation_end2
      inc r10
      mov cl , [inp+r9]
      cmp cl , " "
      jne while_get_operation_end2
      call inc_i
      jmp while_get_operation_end



while_get_operation_end2:

      mov r10 , 0
      dec r10
while_get_operand1:
      mov r9 , [i]
      cmp r9 , r8
      jge while_get_operand1_end
      inc r10
      mov cl , [inp+r9]
      cmp cl , ","
      je while_get_operand1_end
      mov [operand1 + r10] , cl
      call inc_i
      jmp while_get_operand1

while_get_operand1_end:

      mov r9 , [i]
      cmp r9 , r8
      jge white_get_operand2_end

      mov cl , [inp+r9]
      cmp cl , ","
      jne white_get_operand2_end
      
      mov r10 , 0
      dec r10
      call inc_i
white_get_operand2_loopBefore:
      mov r9 , [i]
      mov cl , [inp+r9]
      cmp cl , " "
      jne white_get_operand2_before
      call inc_i
      jmp white_get_operand2_loopBefore


white_get_operand2_before:
      mov r10 , 0
      dec r10
white_get_operand2:
      mov r9 , [i]
      cmp r9 , r8
      jge white_get_operand2_end
      inc r10
      mov cl , [inp+r9]
      mov [operand2 + r10] , cl
      call inc_i
      jmp white_get_operand2



white_get_operand2_end:

      mov rsi , operation
      call printString
      call newLine

      mov rsi , operand1
      call printString
      call newLine

      mov rsi , operand2
      call printString
      call newLine

      mov rax , operand1
      mov rbx , operand2
      push rax
      push rbx
      call swap_twoString

 
      mov rsi , operand1
      call printString
      call newLine

      mov rsi , operand2
      call printString
      call newLine



      mov rax , 65
      call writeNum
      call newLine



      ;   ///////////////////////////////////////// no operands. just operation.
      

      mov rax , operation
      push rax
      call check_just_operation


      mov rax , "false"
      mov [Immediate] , rax


      mov rax , operand1
      push rax
      call operand_type
      mov [type1] , rax
      mov rsi , type1
      call printString
      call newLine



      mov rax , operand2
      push rax
      call operand_type
      mov [type2] , rax
      mov rsi , type2
      call printString
      call newLine




      mov rcx , 7    
      mov rbx , "Imdiate"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , type2
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0
            
      call writeNum
      call newLine

      cmp rax , 0  
      je start_not_Imdiate
      mov rax , "true"
      mov [Immediate] , rax

start_not_Imdiate:
      mov rax , "true"
      mov [single_operand] , rax
      
      mov rax , operand2
      push rax
      call getLen
      cmp rax , 0
      jne start_not_single_operand
      mov rax , "false"
      mov [single_operand] , rax

start_not_single_operand:



      mov rcx , 3    
      mov rbx , "shl"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operation
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0

      call writeNum
      call newLine

      cmp rax , 1
      je start_operation_shl_or_shr


      mov rcx , 3    
      mov rbx , "shr"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operation
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0

      call writeNum
      call newLine

      cmp rax , 1
      jne start_operation_shl_or_shr_not


start_operation_shl_or_shr:

      mov rax , 28
      call writeNum
      call newLine
      
      mov rcx , 1
      mov rbx , "1"
      mov [temp_cmp_str] , rbx
      mov rbx ,temp_cmp_str
      mov rax  , operand2
      push rcx
      push rbx
      push rax
      call cmp_memory_str                 ; rax = 1 if equal. else rax = 0

      cmp rax , 1
      jne start_operation_shl_or_shr_notOne
      mov rax , "true"
      mov [single_operand] , rax
      mov rax , ""
      mov [operand2] , rax
      mov rax , "false"
      mov [Immediate] , rax

      mov rax , "false"
      mov [sib] , rax
      
start_operation_shl_or_shr_notOne:
      ; nothing doing here
start_operation_shl_or_shr_not:
      call type12_operand12_swap

      xor rax , rax
      mov rax , operand1
      push rax
      call register_type
      mov r8 , rax

      xor rax , rax
      mov rax , operand1
      push rax
      call memory_type
      cmp rax , r8
      cmovl rax , r8
      mov [reg1] , rax



      xor rax , rax
      mov rax , operand2
      push rax
      call register_type
      mov r8 , rax

      xor rax , rax
      mov rax , operand2
      push rax
      call memory_type
      cmp rax , r8
      cmovl rax , r8
      mov [reg1] , rax


      mov rax , 4
      mov r8 , 3
      cmp rax , r8
      cmovl rax , r8
      call writeNum
      call newLine


      ; check_sib db "DWORD PTR [ebp+r9d*4+0x55]"
      mov rbx , check_sib
      mov [temp] , rbx
      mov rax , operand1
      push rax
      call get_sib
      call writeNum
      call newLine
      cmp rax , -1
      je count_sib_2


      mov r14 , 4
      mov rax , get_sib_displacment
      push rax
      call getLen
      mul r14
      mov [displc1] , rax

      mov rax , get_sib_base
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib1_base
      mov rax , get_sib_base
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice
      

      mov rax , get_sib_index
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib1_index
      mov rax , get_sib_index
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice
      

      mov rax , get_sib_scale
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib1_scale
      mov rax , get_sib_scale
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice


      mov rax , get_sib_displacment
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib1_displacment
      mov rax , get_sib_displacment
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice




      mov rsi , get_sib_base
      call printString
      call newLine

      mov rsi , get_sib_index
      call printString
      call newLine

      mov rsi , get_sib_scale
      call printString
      call newLine


      mov rsi , get_sib_displacment
      call printString
      call newLine

count_sib_2:
      mov r15 , 0
      cmp rax , -1 
      jne count_sib_2_continue
      mov [displc1] , r15
count_sib_2_continue:

      mov rax , operand2
      push rax
      call get_sib
      call writeNum
      call newLine
      cmp rax , -1
      je count_sib_3

      mov r14 , 4
      mov rax , get_sib_displacment
      push rax
      call getLen
      mul r14
      mov [displc2] , rax

      mov rax , get_sib_base
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib2_base
      mov rax , get_sib_base
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice
      

      mov rax , get_sib_index
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib2_index
      mov rax , get_sib_index
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice
      

      mov rax , get_sib_scale
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib2_scale
      mov rax , get_sib_scale
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice


      mov rax , get_sib_displacment
      push rax
      call getLen
      mov r9 , rax
      mov r8 , 0
      ;mov r9 , 5
      mov rbx , sib2_displacment
      mov rax , get_sib_displacment
      push r8
      push r9
      push rbx
      push rax
      call get_str_slice




count_sib_3:
      mov r15 , 0
      cmp rax , -1 
      jne count_sib_3_continue
      mov [displc2] ,r15

count_sib_3_continue:

      mov rax , "00"
      mov [mod] , rax

      call change_mod_displc
      call change_mod_displc_second

      mov rax , "false"
      mov [new_register] , rax
      mov [displacement_32] , rax
      mov [directAddress] , rax


      mov rax , "jrcxzs"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Start_not_jrcxz

      mov rax , "11100011"
      push rax
      call make_hex

      mov rsi , make_hex_answer
      call printString
      mov rsi , operand1
      call printString
      call newLine
      jmp Exit

Start_not_jrcxz:
     

      mov rax , "call"
      mov [temp] , rax
      mov rax , operation
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Start_not_call

      mov rax , "Imdiate"
      mov [temp] , rax
      mov rax , type1
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne Start_not_call


      mov rax , "11101000"
      push rax
      call make_hex

      mov rsi , make_hex_answer
      call printString

      mov rax , operand1
      push rax
      call make_reverse
      mov rsi , operand1
      call printString


      mov rax , make_hex_answer
      push rax
      call getLen
      mov r8 , rax

      mov rax , operand1
      push rax
      call getLen
      add r8 , rax

      mov r10 ,8
      sub r10 , r8                  ; 8 - len(operand1)
      mov rax , r10
      mov r13 , 2
      mul r13

      mov r9 , 0
      dec r9
Start_call_loop:
      inc r9
      cmp r9 , rax
      je Start_call_loop_end
      mov rax , "0"
      mov [temp] , rax
      mov rsi , temp
      call printString



Start_call_loop_end:

      jmp Exit

Start_not_call:
      mov rax , operand1
      push rax
      call is_new
      mov [temp] , rax
      mov rax , temp
      mov rbx , "true"
      mov [temp2] , rbx
      mov rbx ,temp2
      push rax
      push rbx
      call cmp_twoString
      cmp rax , 1
      je start_is_new1_true

      mov rax , operand2
      push rax
      call is_new
      mov [temp] , rax
      mov rax , temp
      mov rbx , "true"
      mov [temp2] , rbx
      mov rbx ,temp2
      push rax
      push rbx
      call cmp_twoString
      cmp rax , 1
      je start_is_new1_true

      jmp start_is_new1_true_after

start_is_new1_true:
      mov rax , "true"
      mov [new_register] , rax



      
start_is_new1_true_after:

      call start_is_new_2
      call start_is_new_3

      ; two operand with no swap
      call Opcode_two_operand_noSwap
      call Opcode_two_operand_Swap
      call Opcode_one_operand

      mov rax , "false"
      mov [no_displacement] , rax
      mov [displacment_8] , rax


      mov rax , 23
      call writeNum
      call newLine
      

      mov rax , "jir"
      mov [temparr] , rax

      mov rax , "false"
      mov [temparr2] , rax 
      mov rax , temparr
      mov rbx , temparr2
      push rax
      push rbx
      call str_concat

      mov rax , temparr
      mov rbx , temparr2
      push rax
      push rbx
      call str_concat

      
      mov rsi , temparr
      call printString
      call newLine

      mov rsi , temparr2
      call printString
      call newLine

      mov rax , temparr2
      push rax
      call make_str_zero

      mov rsi , temparr2
      call printString
      call newLine
      ;bargard


      mov rax , 43
      call writeNum
      call newLine

      mov rsi , single_operand
      call printString
      call newLine

      mov rax , "true"
      mov [temp] , rax
      mov rax , single_operand
      mov rbx , temp
      push rbx
      push rax
      call cmp_twoString
      cmp rax , 1
      jne start_not_singleOperand

      

      mov rax , 43
      call writeNum
      call newLine
      
 
      call fsingle_operand
      jmp start_not_singleOperand_after


      
start_not_singleOperand:
      call fdual_operand

start_not_singleOperand_after:
      push rax
      mov rax , 10
      call writeNum
      call newLine
      pop rax

            push rax
      mov rax , 82
      call writeNum
      call newLine
      pop rax


    mov rax , answer
      push rax
      call make_str_zero




      mov rbx , prefix
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , opCode
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , rexW
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , rexR
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , rexB
      mov rax , answer
      push rbx
      push rax
      call str_concat



      mov rbx , opCode
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rbx , D
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , W
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , mod
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , Regop
      mov rax , answer
      push rbx
      push rax
      call str_concat


      mov rbx , rm
      mov rax , answer
      push rbx
      push rax
      call str_concat

      mov rsi , answer
      call printString
      call newLine

      mov rax , answer
      push rax
      call make_hex
      mov rsi , make_hex_answer
      call printString
      call newLine
      
Exit:

        mov rax ,60
        xor rdi,rdi
        syscall