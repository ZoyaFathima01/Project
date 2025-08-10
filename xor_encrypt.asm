section .data
    ; Secret message and key (same length)
    plaintext   db 'HELLO'
    key         db 'world'

    len         equ 5               ; length of both strings

    encrypted   db len dup(0)        ; buffer for encrypted result
    decrypted   db len dup(0)        ; buffer for decrypted result

    ; Labels for file output with newlines
    plain_label db 'Plain text: ',0xA
    plain_label_end:

    key_label   db 'Key: ',0xA
    key_label_end:

    enc_label   db 'Encrypted text: ',0xA
    enc_label_end:

    dec_label   db 'Decrypted text: ',0xA
    dec_label_end:

    newline     db 0xA

    filename    db 'output.txt',0    ; file name

section .text
    global _start

_start:
    ; === Encrypt ===
    mov ecx, len
    mov esi, plaintext
    mov edi, key
    mov ebx, encrypted
    call xor_loop

    ; === Decrypt ===
    mov ecx, len
    mov esi, encrypted
    mov edi, key
    mov ebx, decrypted
    call xor_loop

    ; === Open file (O_CREAT | O_WRONLY | O_TRUNC) ===
    mov eax, 5
    mov ebx, filename
    mov ecx, 0x241
    mov edx, 0644o
    int 0x80
    mov ebp, eax    ; save file descriptor

    ; === Write Plain text label + data ===
    mov eax, 4
    mov ebx, ebp
    mov ecx, plain_label
    mov edx, plain_label_end - plain_label
    int 0x80

    mov eax, 4
    mov ebx, ebp
    mov ecx, plaintext
    mov edx, len
    int 0x80

    ; newline
    mov eax, 4
    mov ebx, ebp
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; === Write Key label + data ===
    mov eax, 4
    mov ebx, ebp
    mov ecx, key_label
    mov edx, key_label_end - key_label
    int 0x80

    mov eax, 4
    mov ebx, ebp
    mov ecx, key
    mov edx, len
    int 0x80

    ; newline
    mov eax, 4
    mov ebx, ebp
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; === Write Encrypted label + data ===
    mov eax, 4
    mov ebx, ebp
    mov ecx, enc_label
    mov edx, enc_label_end - enc_label
    int 0x80

    mov eax, 4
    mov ebx, ebp
    mov ecx, encrypted
    mov edx, len
    int 0x80

    ; newline
    mov eax, 4
    mov ebx, ebp
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; === Write Decrypted label + data ===
    mov eax, 4
    mov ebx, ebp
    mov ecx, dec_label
    mov edx, dec_label_end - dec_label
    int 0x80

    mov eax, 4
    mov ebx, ebp
    mov ecx, decrypted
    mov edx, len
    int 0x80

    ; newline
    mov eax, 4
    mov ebx, ebp
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; === Close file ===
    mov eax, 6
    mov ebx, ebp
    int 0x80

    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80

; === XOR loop procedure ===
xor_loop:
    xor eax, eax
.loop:
    mov al, [esi]      ; load plaintext/encrypted
    mov dl, [edi]      ; load key
    xor al, dl         ; XOR them
    mov [ebx], al      ; store result
    inc esi
    inc edi
    inc ebx
    loop .loop
    ret
