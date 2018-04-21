.model small
.stack 100h
.data
fileName db 128 dup(0)

buffer db 128 dup(0)
buf db 0       

inputStr db "Enter word: $"
countLines db "Lines: $"
infoLines db 0Dh,0ah,"Lines without word: $"
Error db "Error",0Dh,0ah, '$'
ErrorFileNotFound db "File not found",0Dh,0ah, '$'
ErrorPathNotFound db "Path not found",0Dh,0ah, '$' 
ErrorFiles db "Many open files",0Dh,0ah, '$' 
ErrorAccess db "Access denied",0Dh,0ah, '$'
ErrorAccessInvalid db "Invalid access mode",,0Dh,0ah, '$'
ErrorEmptyName db "Empty name of file",,0Dh,0ah, '$'
ErrorString db 0Dh,0ah,"Empty String",0Dh,0ah, '$'
   
str db 80 dup('$')
str2 db 81 dup('$')

descript dw 0            
counter dw 0
counterR dw 0 
c dw 0
f db 0 
 
.code

ShowAx  proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
        mov     cx, 10          
        xor     di, di         
        or      ax, ax
        jns     Conv
        push    ax
        mov     dx, '-'
        mov     ah, 2           
        int     21h
        pop     ax
        neg     ax
Conv:
        xor     dx, dx
        div     cx             
        add     dl, '0'         
        inc     di
        push    dx              
        or      ax, ax
        jnz     Conv
Show:
        pop     dx              
        mov     ah, 2          
        int     21h
        dec     di              
        jnz     Show
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
ShowAx endp
         
              
newline proc           ;������� �� ������ ������
    push dx
    push ax
    mov dl, 0Dh 
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    pop ax
    pop dx
    ret
newline endp  


outString macro str    ;����� ������
    mov ah, 09h
    lea dx, str
    int 21h
endm  


inputString macro str  ;���� ������
    lea dx, str
    mov ah, 10
    int 21h  
    push a
    xor si,si
    xor ax,ax
proverka:
    mov al,str[si+2]
    cmp al,20h
    je Error_6
    cmp al,0Dh
    je set
    jmp proverka    
set:
    xor si,si
    xor ax,ax
    pop a    
endm 

 
get_name proc          ; ��� ����� ��� ��������
    push ax
    push cx
    push di
    push si
    xor cx, cx
    mov cl, es:[80h]   ; ���������� �������� � ��������� ������
    cmp cl, 0
    je show_Error_name
    mov di, 82h        ; �������� ��������� ������ � ����� PSP
    lea si, fileName   
    
while:
    mov al, es:[di]
    cmp al, 0Dh
    je end_get_name
    mov [si], al
    inc di
    inc si
    jmp while
     
end_get_name:
    pop si
    pop di
    pop cx
    pop ax 
    ret
get_name endp


macro fileOpen         ; ��������� ���� ��� ������ � ������
   mov ah, 3dh         ; ����� �������
   mov al, 2           ; �������� ��� ������ � ������
   lea dx, fileName    ; DS:DX ��������� �� ����
   int 21h             ; ��������� ����
   jc show_Error       ; ���� �� ��������� ������, ���� CF = 1
   mov descript, ax      ; ��������� ���������� �����
   mov bx, ax          ; �������� ������������� ����� � BX
   mov di, 01          ; ������������� stdout
endm


macro fileClose        ; ��������� ����
   mov ah, 3eh         ; ����� �������
   mov bx, descript    ; ����� �����
   int 21h             ; ��������� ����
   jc show_Error       ; ���� �� ��������� ������
endm  


readnwrite proc        ; ������ ������ �� ����� � ������ �� � stdout       
    
read_data:
    mov cx, 128        ; ������ ����� ��� ������ �����
    lea dx, buffer
    mov ah, 3fh
    int 21h            ; ��������� �� ���� �� �����
    jc close           ; ���� ������, �� ������� ����
    mov cx, ax         ; CX = ����� ����������� ����
    jcxz close         ; ���� CX = 0 - ������� ����
    mov ah, 40h
    xchg bx, di        ; BX = 1 - STDOUT
    int 21h            ; ����� ������ � STDOUT
    xchg di, bx        ; BX = ������������� �����
    jc close           ; ���� ������ - ������� ����
jmp read_data          ; ����� ��������� CX ����
endp  


proc count             ; ������� �����, � ������� ��� ��������� �����
    i:     
    mov cx, 128        ; � cx - ���������� ���� ��� ������
    mov bx, descript
    lea dx, buffer     ; � dx - ����� ������ ��� ����������
    mov ah, 3fh     
    int 21h
    jc close           ; ���� ������ - �� �����
    mov cx, ax         ; � cx � ax - ���������� ������� ��������� ����
    jcxz close         ; ���� ����� �� ����� ����� - �����
    
    mov c, 0           ; ������� ���������� ��������
    lea si, buffer     ; ����� ������
    jmp k       
    
    j:   
        lea di, str2   ;di ����� +2     
        k:             ;si ������
            mov al, [di]
            mov bl, [si]    
            cmp bl, al ; ���������� ������� �����
            je Equal   ; ���� �����
            jne NotEqual ; ���� �� �����
    jmp k
    jmp j
    jmp i
 
Equal:
    mov al, [di]
    mov bl, [si]  
    cmp [di], ' '
    je FindSpaceDI
    cmp [di], 13
    je FindEndDI
    cmp [si], ' '
    je FindSpaceSI
    cmp [si], 13
    je FindEndSI
        
    cmp bl, al               ; ���������� ������� �����
    jne NotEqual             ; e��� �� �����
    
    inc c
    inc si
    inc di
    cmp cx, c
    je i
    
    jmp Equal
FindSpaceDI:
    cmp [si], ' '
    je  Find
    cmp [si], 13
    je  Find_inc2
    jmp j

FindSpaceSI:  
    cmp [di], ' '
    je  Find_inc2
    cmp [di], ' '
    je  Find
    cmp [di], 13
    je  Find
    jmp j

FindEndDI:
    cmp [si], 0
    je  Find_help
    cmp [si], ' '
    je  Find
    cmp [si], 13
    je  Find_inc2
    jmp j

FindEndSI:  

    cmp [di], 13
    je  Find_inc2
    jmp controller

Find:
    mov f,1
    inc c
    inc si
    cmp cx, c
    je i
    jmp j

Find_help:
    lea di, str2                ;di ����� +2
    inc counter
    mov f, 0
    jmp inc2

Find_inc2:
    inc counter
    inc counterR
    mov f, 0
    jmp inc2
     
controller:
    cmp f,1
    je countCounter
    inc counterR
    jmp inc2
 
 
NotEqual:                       ;���� �� ����� ������ ���������� �� ������� ��� 0dh
    cmp [si], ' '
    je inc1
    cmp [si], 13
    je endString
    
    inc c
    inc si
    cmp cx, c
    je i
    jmp NotEqual
    
    
endString:                         ;����� �� ����� �� ����� ������(����� ����� + ������� �� ����� ��)
    cmp f, 1
    je countCounter
    inc counterR
    jmp inc2
    
inc1:

    inc c
    inc si    
    cmp cx, c
    je i
    jmp j
    
inc2:
    inc c   
    inc si
    cmp cx, c   
    je i
    
    inc c    
    inc si
    cmp cx, c
    je i
    jmp j

            
countCounter:
    inc counter
    inc counterR
    mov f, 0
    jmp inc2     
    
endp

proc check
    lea di,str2
    lea si,str+2
    cmp [si],13
    je exit_empty
    cmp [si], ' '
    je loop_parse
    jne begin_print
    
begin_print:
   mov dx, [si]
   mov [di],dx
   inc si
   inc di
   cmp [si], ' '
   je end_printf
   jne check_end

check_end:
    cmp [si],13
    je end_printf
    jne begin_print
   
end_printf:
    mov [di],13
    ret
    
loop_parse:
    inc si
    cmp [si], ' '
    je loop_parse
    jne check_13         
check_13:
    cmp [si], 13
    je exit_empty
    jne begin_print        
exit_empty:
    outString ErrorString
    mov ah, 4ch
    int 21h 
endp
               
begin:         
    mov ax, @data
    mov ds, ax
    call get_name
    fileOpen               ; ��������� ����
    outString inputStr
    inputString str        ; ���� ��������� ��� ������ 
    push dx
    lea di, str2
    call check
    lea di, str2
    chek_loop1:
    mov dx,[di]
    inc di
    cmp [di],13
    jne chek_loop1
    pop dx
    call count
                           ; �������� �������
close:        
    fileClose              ; ��������� ����
    cmp [di], 13
    je addCounter
    jne exit
    
    
addCounter:
    inc counter
    
exit:
    call newline    
    inc counterR
    cmp f,0
    je exit_0
    inc counter
    outString countLines
    mov ax, counterR 
    mov ax, counter 
    call ShowAx          ; ������� ���������� AX
    mov ax, counterR
    sub ax, counter
    push ax
    outString infoLines
    pop ax
    call ShowAx          ; ������� ���������� AX
    mov ah, 4ch
    int 21h                                     
    
    
exit_0:
    outString countLines
    mov ax, counterR 
    call ShowAx          ; ������� ���������� AX
    mov ax, counterR
    sub ax, counter
    push ax
    outString infoLines
    pop ax  
    call ShowAx          ; ������� ���������� AX
    mov ah, 4ch
    int 21h
    jmp exit

show_Error:
    push ax
    lea dx, Error
    mov ah, 09
    int 21h
    pop ax
    cmp ax,02h
    je Error_1    
    cmp ax,03h
    je Error_2
    cmp ax,03h
    je Error_3
    cmp ax,04h
    je Error_4
    cmp ax,05h
    je Error_5
    mov ah, 4ch
    int 21h
    
show_Error_name:
    lea dx, Error
    mov ah, 09
    int 21h
    outString ErrorEmptyName
    mov ah, 4ch
    int 21h

Error_1:
    outString ErrorFileNotFound
    jmp exit_with_errors
Error_2:
    outString ErrorPathNotFound
    jmp exit_with_errors
Error_3:
    outString ErrorFiles
    jmp exit_with_errors
Error_4:
    outString ErrorAccess
    jmp exit_with_errors
Error_5:
    outString ErrorAccessInvalid
    jmp exit_with_errors
Error_6:
    outString TwoWords
    jmp exit_with_errors
        
exit_with_errors:
    mov ah, 4ch
    int 21h                            
end begin






