.model tiny
.data    

errorArgs db "You don't write coordinates or other Error", '$'
inputError db 'Input error$'
errorY db 'Error maximal value y$' 
errorX db 'Error maximal value x$'
stringX db 127 dup(0)
stringY db 127 dup(0)
buffer db 20 dup(0)
sizeCmd db ?
stringCmd db 127 dup(0) 


size equ 160
maxSizeY equ 24     ;границы видимости
maxSizeX equ 70

x dw 0
y dw 0  

time dw 0  

.code



start:                  

 jmp get_name 


outString macro str
	push ax
	push dx
	mov ah, 09h
	mov dx, offset str
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	mov ah, 02h
	int 21h
	pop dx
	pop ax
endm

strlen proc
	push bx si
	xor ax, ax
count:
	mov bl, ds:[si] 
	cmp bl, 0
	je end_count
	inc si
	inc ax
	jmp count 
	
end_count:
	pop si bx
	ret
endp

compare macro str, metka
	push si
	mov si, offset str
	call strlen
	pop si
	cmp ax, 0
	je metka
endm

readCmd proc
	push bx
	push cx
	push dx
	mov cl, sizeCmd
	xor ch, ch
	mov si, offset stringCmd
	mov di, offset buffer
	call next_word
	dec si        
	
thenX:
    inc si
    mov al, ds:[si]
    cmp al, 32
    je thenX      ; если равно
    cmp al, 9
    je thenX  
	mov di, offset stringX
	call next_word
	compare stringX, poorArgs 
	dec si   
	
thenY:
    inc si
    mov al, ds:[si]
    cmp al, 32
    je thenY
    cmp al, 9
    je thenY 
	mov di, offset stringY
	call next_word
	compare stringY, poorArgs
	mov di, offset buffer
	call next_word
	compare buffer, goodArgs 
	
poorArgs:
	outString errorArgs
	mov ax, 1
	jmp end_proc  
	
goodArgs:
	mov ax, 0    
	
end_proc:
	pop dx
	pop cx
	pop bx
	ret	
endp
           
           
next_word proc
	push ax
	push cx
	push di      
while: 
	mov al, ds:[si]
	cmp al, 32
	je whereSymbolStop
	cmp al, 13
	je whereSymbolStop
	cmp al, 9
	je whereSymbolStop
	cmp al, 10
	je whereSymbolStop
	cmp al, 0
	je whereSymbolStop
	mov es:[di], al
	inc di
	inc si
	loop while
whereSymbolStop:
	mov al, 0
	mov es:[di], al
	inc si
	pop di
	pop cx
	pop ax
	ret
endp
           
           
macro exit_app
   mov ax,4C00h
   int 21h  
endm

atoi proc
    xor ax, ax
    xor cx, cx
    mov bx,10     
whileEnd:
    mov cl,[si]          
    cmp cl,0dh  
    jz exit
    cmp cl,0
    jz exit
    cmp cl,'0'  
    jb error
    cmp cl,'9'  
    ja error
    sub cl,'0' 
    mul bx
    jo error
    jc error    
    add ax, cx  
    inc si     
    jmp whileEnd 
error:   
    outString inputError
    exit_app     
exit:
    ret      
atoi endp
            
            
check_number proc
    pusha
    xor bx, bx    
check_start:
    mov cl, [si]
    cmp cl, 0
    je check_exit
    inc si
    inc bx
    jmp check_start      
check_exit:
    mov ax, bx
    mov bl, 2
    div bl
    mov ah, 0
    sub si, ax
    mov [si], 0
    popa
    ret
check_number endp

;это типо команды aam , она делит содержимое регистра al на 10 и записывает частное в регистр ah, а остаток в al
decode proc
    db 0D4h,10h                      ; распаковываем BCD-число
    add ax,'00'                      ; превращаем неупакованное BCD-число в ASCII-символ
    cmp dx, 1
    jne next
    mov word ptr es:[di],0F00h + ":" ; двоеточие - разделитель часов, минут, секунд 
next:
    mov es:[di + 2],ah               ; выводим на экран первую цифру
    mov byte ptr es:[di+3],0Fh       ; атрибут символа(€рко-белое на черном фоне)
    mov es:[di + 4],al               ; выводим на экран вторую цифру
    mov byte ptr es:[di+5],0Fh       ; атрибут символа(€рко-булый на черном фоне)
    add di,6
    ret               
decode endp
        
        
clock proc                  ; процедура обработчика прерываний от таймера
    push es                 ; сохранение модифицируемемых регистров
  pusha
    push 0B800h             ; 0B800h - начало сегмента видеобуфера
    pop es
    mov ax, @data
    mov ds, ax
    mov ax, size
    mov bx, ds:[y] 
    mul bx 
 
    add ax, ds:[x]
    add ax, ds:[x]
                            ; size * y + x * 2 
    mov time, ax            ; смещение 
    mov di,time   
    mov al,4
    out 70h,al              ; запись данных из регистра в порт 
    in al,71h               ; получить текущее значение, в al - часы
    mov dx, 0     
    call decode
    mov al,2
    out 70h,al
    in al,71h               ; в al - минуты
    mov dx, 1    
    call decode
    mov al,0
    out 70h,al
    in al,71h               ; в al - секунды
    mov dx, 1    
    call decode
  popa
    pop es                  ; восстановление модифицируемов регистров       
    db 0EAh                 ; начало кода команды
    old_int_1Ch dd ?        ; вызов старого обработчика 1Ch прерываний и возврат из обработчика
clock endp
        
        
get_name:
    mov ax, @data
	mov es, ax
    pusha
    xor ch, ch
	mov cl, ds:[80h]			
	mov sizeCmd, cl 		
	mov si, 81h
	mov di, offset stringCmd
	rep movsb
	mov ds, ax
    call readCmd
	cmp ax, 0
	jne end_main
	popa
	mov si,offset stringX
	call check_number
	call atoi
	mov x, ax
	cmp ax, maxSizeX
	jbe workWithX
	outString errorX
	exit_app
	 
workWithX:
	mov si,offset stringY
	call check_number
	call atoi
	mov bl, 2
	div bl
	mul bl
    mov y, ax
    cmp ax, maxSizeY
	jbe workWithY
	outString errorY
	exit_app
	
workWithY:	
    xor ax, ax   
    mov al,3     
    int 10h
    pop dx      
    mov ax,351Ch                          ; получение адреса старого обработчика
    int 21h       
    mov word ptr old_int_1Ch,bx           ; сохранение смещени€ обработчика
    mov word ptr old_int_1Ch + 2,es       ; сохранение сегмента обработчика
    mov ax,251Ch                          ; установка адреса нашего обработчика ‘ункци€ 25h, вектор 1Ch
    mov dx,offset clock                   ; указание адреса нашего обработчика
    int 21h
    mov ax,3100h                          ; функци€ DOS завершени€ резидентной программы
    mov dx,(get_name - start + 10Fh) / 16 ; определение размера резидетной части программы в параграфах
    int 21h 
end_main:
    exit_app
end start


                 




