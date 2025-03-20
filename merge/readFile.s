section .data
    msg_input_file db "Enter input file name: ", 0
    msg_open_error db "Error: cannot open file", 10, 0
    msg_read_error db "Error: Cannot read file", 10, 0

section .bss 
    filename resb 255
    buffer resb 255
    buffer_len resq 1

extern remove_newline
extern Sys_write
extern Sys_read

section .text
global open_input_file
global buffer, buffer_len

open_input_file: 
    mov rsi, msg_input_file
    mov rdx, 24
    call Sys_write

    mov rsi, filename
    call Sys_read

    ; Remove newline character (\n) if present
    mov rcx, filename
    call remove_newline

     ;open file
    mov rax, 2 ;SYS_open
    mov rdi, filename
    mov rsi, 0 ;O_RDONLY
    syscall
    cmp rax, 0
    jl error_open
    mov r12, rax

    ;read file
    mov rax, 0 ;SYS_read
    mov rdi, r12
    mov rsi, buffer
    syscall
    mov [buffer_len], rax 
    cmp rax, 0
    jl error_read
    mov r13, rax

    ;close file
    mov rax, 3 ;SYS_close
    mov rdi, r12
    syscall

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
exit:
    mov rax, 60 ;SYS_exit 
    mov rdi, 0  
    syscall
