; Boot loader program
; Descripton : load the next 10 sectors to the address 0x1000
; 			   and enable protected mode and jmp to the code loaded
; Date : Oct 8,2014
; Author : Kshitij Burman <kburman6@gmail.com>
; Don't forgot to cat boot_loader.bin kernel.bin


BITS 16
ORG 0x7C00

jmp start16

drive db 0

start16:

	cli		; Disable Interrupts
	
	;
	; Save Drive no.
	;
	
	mov [drive],dl
	
	;
	; Zero out all
	;
	
	xor ax,ax
	mov es,ax
	mov ds,ax
	mov ds,ax
	mov ss,ax	
	
; 
; Reset Floppy 
;
reset:
	mov ah,0x00
	int 0x13
	
	or ah,ah
	jnz reset
	
read:
	xor ax,ax
	mov es,ax
	mov bx,0x1000	; Load at address  0x0:0x1000
					; which is          es:bx
	
	mov ah,0x02		; Read cmd
	mov al,0x22		; No. of sectors = 10 sectos
	mov dl,[drive]	; Load drive no.
	mov ch,0x0		; Cylinder = 0
	mov cl,0x2 		; Sector = 2
	mov dh,0x0 		; Head  = 0
	
	int 0x13		; Call the int
		
	or ah,ah		; Check for error
	jnz reset
	

		
		
inti32:
	
	lgdt [gdt_table]	
	
	mov eax,cr0
	or al,1
	mov cr0,eax ; Enables protecte mode
	
	; CPU prefetch instruction which would be 16bit but
	; we are in 32 bit now so to flush that and reset cs
	; ip at the same time we need to do a far jump
	
	
	jmp gdt_kernel_code:start32

	
	
BITS 32

start32:
	; TODO
	; > set ds,ss,esp
	; > jmp to kernel code loaded
	
	
	mov ax,0x10
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	
	mov ah,0x07
	mov al,'k'
	
	mov word [0xb8000],ax
	mov eax,drive
	hlt
	jmp gdt_kernel_code:0x1000
	
	

		
;*******************************************
; Global Descriptor Table (GDT)
;*******************************************
	
gdt: 

gdt_null:
	dd 0                ; null descriptor
	dd 0 
	
	
gdt_kernel_code equ  $-gdt 
	; gdt code:	    ; code descriptor
	dw 0FFFFh           ; limit low
	dw 0                ; base low
	db 0                ; base middle
	db 10011010b        ; access
	db 11001111b        ; gra0x07ddnularity
	db 0                ; base high
	
	
gdt_kernel_data equ $-gdt
	; gdt data:	    ; data descriptor
	dw 0FFFFh           ; limit low (Same as code)
	dw 0                ; base low
	db 0                ; base middle
	db 10010010b        ; access
	db 11001111b        ; granularity
	db 0                ; base high
	
gdt_end:


gdt_table: 
	dw gdt_end - gdt - 1 	; limit (Size of GDT)
	dd gdt 			; base of GDT

		

times 510 - ($-$$) db 0
dw 0xAA55


times 1024 dw 0xABCD
