extern buffer_len,

section .text
global xor_loop 

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
    ret 
    