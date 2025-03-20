section .text
    global write_output_file:
global _start
write_output_file:
    ;open file
    mov rax, 85 ;SYS_create
    mov rdi, output_filename
    mov rsi, 00400q ;S_IRUSR
    syscall
    cmp rax, 0
    jl error_open
    mov r12, rax

    ;write file
    mov rax,1 ;SYS_write
    mov rdi, r12
    mov rsi, xor_output
    mov rdx, [buffer_len]
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