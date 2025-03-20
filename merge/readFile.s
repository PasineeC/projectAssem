global _start
section .text
    global write_output_file:
open_input_file:
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