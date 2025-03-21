global _start

section .data
    msg_input_file db "Enter input file name: ", 0
    msg_output_file db "Enter output file name: ", 0
    msg_key db "Enter key (max. 3 characters): ", 0
    msg_reading_file db "Reading input file...OK", 10, 0
    msg_generating_file db "Generating output file...OK", 10, 0
    msg_decrypt_generated db "original.txt generated", 10, 0

section .bss 
    filename resb 255        
    output_filename resb 255
    key resb 4    
    xor_output resb 255   
    key_len resq 1

extern remove_newline
extern xor_loop
extern open_input_file
extern write_output_file
extern buffer, buffer_len

section .text
_start:
global Sys_write
global Sys_read
global output_filename
global xor_output

    ;read file 
    call open_input_file

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

    ; xor function 
xor_function:
    mov rsi, buffer
    mov rdi, key         
    mov rdx, xor_output    
    mov rcx, 0
    mov r8, 0
    
    call xor_loop

    ;write file 
    call write_output_file 

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
