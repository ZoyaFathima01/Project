SECTION .data
    msg    db 'HELLO'
    key    db 'world'
    msglen equ 5
    fname  db 'output.txt',0
    label1 db 'Plain text: ',0xA
    label2 db 'Key: ',0xA
    label3 db 'Encrypted text: ',0xA
    label4 db 'Decrypted text: ',0xA
    nl     db 0xA

SECTION .bss
    fd_out     resb 4
    encrypted  resb msglen
    decrypted  resb msglen

SECTION .text
    global _start

_start:
    ; Encrypt
    mov ecx, msglen
    mov esi, 0
encrypt_loop:
    mov al, [msg + esi]
    mov bl, [key + esi]
    xor al, bl
    mov [encrypted + esi], al
    inc esi
    loop encrypt_loop

    ; Decrypt
    mov ecx, msglen
    mov esi, 0
decrypt_loop:
    mov al, [encrypted + esi]
    mov bl, [key + esi]
    xor al, bl
    mov [decrypted + esi], al
    inc esi
    loop decrypt_loop

    ; Create file (sys_creat, eax=8)
    mov eax, 8
    mov ebx, fname
    mov ecx, 0777o
    int 0x80
    mov [fd_out], eax

    ; Write label1 and msg
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, label1
    mov edx, 13
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, msg
    mov edx, msglen
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, nl
    mov edx, 1
    int 0x80

    ; Write label2 and key
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, label2
    mov edx, 6
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, key
    mov edx, msglen
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, nl
    mov edx, 1
    int 0x80

    ; Write label3 and encrypted
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, label3
    mov edx, 16
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, encrypted
    mov edx, msglen
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, nl
    mov edx, 1
    int 0x80

    ; Write label4 and decrypted
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, label4
    mov edx, 16
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, decrypted
    mov edx, msglen
    int 0x80
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, nl
    mov edx, 1
    int 0x80

    ; Exit
    mov eax, 1
    int 0x80
