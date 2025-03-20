section .text
global remove_newline

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