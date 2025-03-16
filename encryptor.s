
global _start 

section .data
    msg_input_file db "Enter input file name: ", 0
    msg_output_file db "Enter output file name: ", 0
    msg_key db "Enter key (max. 3 characters): ", 0
    msg_reading_file db "Reading input file...OK", 10, 0
    msg_generating_file db "Generating output file...OK", 10, 0
    msg_encrypt_generated db "encrypt.dat generated", 10, 0

section .bss
    filename resb 100        ; ตัวแปรสำหรับเก็บชื่อไฟล์ input
    output_filename resb 100 ; ตัวแปรสำหรับเก็บชื่อไฟล์ output
    key resb 4               ; ตัวแปรสำหรับเก็บ Key (สูงสุด 3 ตัวอักษร + Null)
    buffer resb 100          ; ตัวแปรสำหรับเก็บข้อมูลที่อ่านจากไฟล์
    bytes_read resq 1        ; ตัวแปรสำหรับเก็บจำนวน bytes ที่อ่านจากไฟล์
    input_encrypt resq 1     ; ตัวแปรสำหรับเก็บค่า file descriptor ของไฟล์ input
    output_encrypt resq 1    ; ตัวแปรสำหรับเก็บค่า file descriptor ของไฟล์ output

section .text
_start:
    ; รับชื่อไฟล์ input
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_input_file
    mov rdx, 24
    syscall   ; แสดงข้อความให้ผู้ใช้ป้อนชื่อไฟล์ input

    ; อ่านชื่อไฟล์ input
read_file_input:
    mov rax, 0
    mov rdi, 0
    mov rsi, filename
    mov rdx, 100
    syscall
    call remove_newline  ; ลบ '\n' ที่ได้จากการป้อนชื่อไฟล์

    ; รับชื่อไฟล์ output
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_output_file
    mov rdx, 25
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, output_filename
    mov rdx, 100
    syscall
    call remove_newline  ; ลบ '\n' ที่ได้จากการป้อนชื่อไฟล์ output

    ; เปิดไฟล์ input และอ่านข้อมูล
    mov rax, 2
    mov rdi, filename
    mov rsi, 0          ; O_RDONLY
    syscall
    mov [input_encrypt], rax

    ; อ่านข้อมูลจากไฟล์ input
    mov rdi, [input_encrypt]
    mov rax, 0
    mov rsi, buffer
    mov rdx, 100
    syscall
    mov [bytes_read], rax

    ; ปิดไฟล์ input
    mov rax, 3
    mov rdi, [input_encrypt]
    syscall

    ; รับ key สำหรับการเข้ารหัส
read_key:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_key
    mov rdx, 30
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, key
    mov rdx, 4
    syscall
    call remove_newline  ; ลบ '\n' ที่ได้จากการป้อน key

    ; แสดงข้อความ "Reading input file...OK"
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_reading_file
    mov rdx, 24
    syscall

    ; ทำการเข้ารหัสโดยใช้ XOR
    call xor_encrypt

    ; สร้างไฟล์ output และเขียนข้อมูลที่เข้ารหัส
write_output_file:
    mov rax, 2
    mov rdi, output_filename
    mov rsi, 577         ; O_CREAT | O_WRONLY | O_TRUNC (0666)
    mov rdx, 0666
    syscall
    mov [output_encrypt], rax

    ; แสดงข้อความ "Generating output file...OK"
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_generating_file
    mov rdx, 29
    syscall

    ; เขียนข้อมูลที่เข้ารหัสลงไฟล์ output
    mov rdi, [output_encrypt]
    mov rax, 1
    mov rsi, buffer
    mov rdx, [bytes_read]
    syscall

    ; แสดงข้อความ "output.dat generated"
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_encrypt_generated
    mov rdx, 23
    syscall

    ; ปิดไฟล์ output
    mov rax, 3
    mov rdi, [output_encrypt]
    syscall

    ; ออกจากโปรแกรม
exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; ฟังก์ชันลบ '\n' ออกจากสตริง
remove_newline:
    mov rdi, rsi
.loop:
    cmp byte [rdi], 10
    je .replace
    cmp byte [rdi], 0
    je .done
    inc rdi
    jmp .loop
.replace:
    mov byte [rdi], 0
.done:
    ret

; ฟังก์ชัน XOR Encryption
xor_encrypt:
    mov rcx, [bytes_read]   ; จำนวน byte ที่ต้องเข้ารหัส
    test rcx, rcx
    jz .done

    mov rsi, buffer         ; ข้อมูลที่อ่านจากไฟล์
    mov rdi, key            ; Key ที่ใช้เข้ารหัส
    xor rbx, rbx            ; ใช้ rbx เป็นตัว index ของ key

.loop:
    mov al, [rsi]           ; โหลด byte จาก buffer
    xor al, [rdi + rbx]     ; XOR กับ key (วนใช้ key)
    mov [rsi], al           ; บันทึกค่าที่เข้ารหัสกลับไปใน buffer

    inc rsi
    inc rbx
    cmp rbx, 3              ; ถ้า key มีแค่ 3 ตัวอักษร ให้ reset index
    jl .next
    xor rbx, rbx
.next:
    loop .loop

.done:
    ret
