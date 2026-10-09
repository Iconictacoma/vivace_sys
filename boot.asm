[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x1000

start:
    cli
    
    mov [BOOT_DRIVE], dl
    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    sti

    mov si, MSG_REAL_MODE
    call print_string_16

    call load_kernel
    call enable_a20

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_32

print_string_16:
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

load_kernel:
    mov si, MSG_LOAD_KERNEL
    call print_string_16

    mov bx, KERNEL_OFFSET
    mov dl, [BOOT_DRIVE]
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov ah, 0x02
    mov al, 15
    int 0x13
    
    jc disk_error
    ret

disk_error:
    mov si, MSG_DISK_ERROR
    call print_string_16
    hlt

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

gdt_start:
gdt_null:
    dd 0x0
    dd 0x0
gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 0x9a
    db 0xcf
    db 0x0
gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 0x92
    db 0xcf
    db 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 32]
init_32:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    jmp KERNEL_OFFSET


BOOT_DRIVE db 0
MSG_REAL_MODE db "Starting bootloader...", 0x0D, 0x0A, 0
MSG_LOAD_KERNEL db "Loading kernel from disk...", 0x0D, 0x0A, 0
MSG_DISK_ERROR db "DISK READ Error!", 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xaa55
