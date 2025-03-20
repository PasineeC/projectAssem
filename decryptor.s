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
    filename resb 255        
    output_filename resb 255
    key resb 4    
    buffer resb 255
    xor_output resb 255   
    buffer_len resq 1
    key_len resq 1

section .text
_start:
get_input_file:

    mov rsi, msg_input_file
    mov rdx, 24
    call Sys_write

    mov rsi, filename
    call Sys_read

    ; Remove newline character (\n) if present
    mov rcx, filename
    call remove_newline

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

get_output_file:
    mov rsi, msg_output_file
    mov rdx, 25
    call Sys_write

    mov rsi, output_filename
    call Sys_read

    mov rcx, output_filename
    call remove_newline

get_key:
    mov rsi, msg_key
    mov rdx, 32
    call Sys_write

    mov rsi, key
    call Sys_read

    mov rcx, key 
    call remove_newline

xor_function:
    mov rsi, buffer
    mov rdi, key         
    mov rdx, xor_output    
    mov rcx, 0
    mov r8, 0

xor_loop:
    cmp rcx, [buffer_len]       
    jge xor_loop_done          

    mov al, [rsi + rcx]    
    cmp r8, 3
    jge reset_key_index    

    mov bl, [rdi + r8]  
    xor al, bl             
    mov [rdx + rcx], al    

    inc rcx                
    inc r8                 
    jmp xor_loop      

reset_key_index:
    mov r8, 0
    jmp xor_loop           

xor_loop_done:

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


generated_success:
    mov rsi, msg_reading_file
    mov rdx, 25
    call Sys_write

    mov rsi, msg_generating_file
    mov rdx, 29
    call Sys_write

    mov rsi, msg_decrypt_generated
    mov rdx, 24
    call Sys_write

exit:
    mov rax, 60 ;SYS_exit 
    mov rdi, 0  
    syscall

Sys_write:
    mov rax, 1 ;SYS_write 
    mov rdi, 1 ;SYSOUT
    syscall
    ret
Sys_read:
    mov rax, 0 ;SYS_read 
    mov rdi, 0 ;STDIN 
    mov rdx, 255  
    syscall
    ret

remove_newline:
    cmp byte [rcx], 10  ; Is last character \n?
    je set_null
    cmp byte [rcx], 0   
    je remove_newline_done
    inc rcx
    jmp remove_newline
set_null:
    mov byte [rcx], 0
remove_newline_done:
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