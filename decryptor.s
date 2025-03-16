
extern xor_encrypt
global _start

section .data
    LF equ 10 
    NULL equ 0
    
    msg_input_file db "Enter input file name: ", 0
    msg_output_file db "Enter output file name: ", 0
    msg_key db "Enter key (max. 3 characters): ", 0
    msg_reading_file db "Reading input file...OK", 10, 0
    msg_generating_file db "Generating output file...OK", 10, 0
    msg_decrypt_generated db "original.txt generated", 10, 0
    msg_open_error db "Error: cannot open file", 10, 0
    msg_read_error db "Error: Cannot read file", 10, 0
    newLine db LF, NULL

section .bss 
    filename resb 100        
    output_filename resb 100 
    key resb 4               
    buffer resb 100          
    bytes_read resq 1        
    input_encrypt resq 1     
    output_encrypt resq 1    

section .text
_start:
get_input:
    mov rdi, msg_input_file
    call printString 

    ;read file name
    mov rax, 0 ;SYS_read 
    mov rdi, 0 ;STDIN 
    mov rsi, buffer
    mov rdx, 100  
    syscall

    ; Remove newline character (\n) if present
    mov rcx, buffer
remove_newline:
    cmp byte [rcx], 10  
    je set_null
    cmp byte [rcx], 0   
    je continue_open
    inc rcx
    jmp remove_newline
set_null:
    mov byte [rcx], 0

continue_open:
    ;open file
    mov rax, 2 ;SYS_open
    mov rdi, buffer 
    mov rsi, 0 ;O_RDONLY
    syscall
    cmp rax, 0
    jl error_open
    mov r12, rax

    ;read file
    mov rax, 0 ;SYS_read
    mov rdi, r12
    mov rsi, buffer
    mov rdx, 256
    syscall
    cmp rax, 0
    jl error_read
    mov r13, rax

    call xor_encrypt

    ;show file's data
    mov rax, 1 ;SYS_write
    mov rdi, 1 ;STDOUT
    mov rsi, buffer
    mov rdx, r13
    syscall

    ;close file
    mov rax, 3 ;SYS_close
    mov rdi, r12
    syscall

exit:
    mov rax, 60 ;SYS_exit 
    mov rdi, 0  
    syscall

printString:
    push rbx 
    mov rbx, rdi 
    mov rdx, 0

strCountLoop: 
    cmp byte [rbx], NULL
    je strCountDone 
    inc rdx 
    inc rbx 
    jmp strCountLoop

strCountDone: 
    cmp rdx, 0  
    je strPrintDone
    mov rax, 1 ;SYS_write 
    mov rsi, rdi 
    mov rdi, 1 ;STDOUT 
    syscall 
strPrintDone:
    pop rbx
    ret 
error_open:
    mov rax,1 ;SYS_write
    mov rdi,1 ;STDOUT
    mov rsi, msg_open_error
    mov rdx, 26
    syscall 
    jmp exit
error_read: 
    mov rax,1 ;SYS_write 
    mov rdi,1 ;STDOUT
    mov rsi, msg_read_error
    mov rdx, 26
    syscall 
    jmp exit