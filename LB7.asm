.model tiny
.code
org 100h  
                   
jmp start  

emptyError db "Error empty cmd!$"   
badProgramPath db "Bad program path!", '$'
inputError db 'Input error!$'
maxError db 'Error, you entered above the maximum value!!!$'     
minError db 'Error, you entered above the minimal value!!!$' 

nString db 127 + 2 dup(0)
namePath db "example.exe", 0  
cmdSize db ?

maxSize equ 255  
minSize equ 0
n dw 0  
counter dw 0


atoi proc
    xor ax, ax
    xor cx, cx
    mov bx,10  
until_the_end:
    mov cl,[si]          
    cmp cl,0dh  
    jz exit  
    cmp cl,'-'
    je error
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
    jmp until_the_end     
error:   
    outString inputError
    mov ax,4C00h
    int 21h 
exit:
    ret
atoi endp
 
 
 
outString macro string
	push ax
	push dx
	mov ah, 09h
	mov dx, offset string
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


checkPath proc
    pusha
    mov si, offset namePath
whileNotDot:
    cmp ds:[si], '.'
    je endWhileNotDot
    cmp ds:[si], 0
    je badPath
    inc si
    jmp whileNotDot 
endWhileNotDot:    
    call checkExe
    cmp ax, 1
    je endCheckPathProc 
    call checkCom
    cmp ax, 0
    je badPath
    jmp endCheckPathProc
badPath:
    outString badProgramPath 
    mov ax,4C00h
    int 21h
endCheckPathProc: 
    popa
    ret
checkPath endp

checkExe proc
    push si
    push ds
    inc si
    cmp ds:[si], 'e'
    jne badExe
    inc si
    cmp ds:[si], 'x'
    jne badExe
    inc si
    cmp ds:[si], 'e'
    jne badExe
    inc si
    cmp ds:[si], 0
    jne badExe
    mov ax, 1
    jmp endCheckExeProc
badExe:
    mov ax, 0
endCheckExeProc: 
    pop ds
    pop si
    ret
checkExe endp

checkCom proc
    push si
    push ds
    inc si
    cmp ds:[si], 'c'
    jne badCom
    inc si
    cmp ds:[si], 'o'
    jne badCom
    inc si
    cmp ds:[si], 'm'
    jne badCom
    inc si
    cmp ds:[si], 0
    jne badCom
    mov ax, 1
    jmp endCheckComProc
badCom:
    mov ax, 0
endCheckComProc: 
    pop ds
    pop si
    ret
checkCom endp   



start:
    mov ax, @data
	mov es, ax
    pusha
    xor ch, ch   
    mov di, 80h
	mov cl, ds:[di]
	cmp cl, 0             
	jne notEmptyCmd
	outString emptyError      
	mov ax,4C00h
    int 21h
notEmptyCmd:			
	mov cmdSize, cl  
    lea si, nString   
stringSearch:
    inc di
    cmp byte ptr[di], 32 
    je avoidSpaces 
    cmp byte ptr[di], 9
    je avoidSpaces      
setAmount:
    inc di
    mov al, es:[di]
    cmp al, 13     
    je parsingEnd 
    cmp al, 32
    je parsingEnd   
    cmp al, 9
    je parsingEnd   
    mov [si], al   
    inc si 
    jmp setAmount 
avoidSpaces:
    cmp byte ptr[di+1],32
    jne avoidTabulation
    jmp stringSearch 
avoidTabulation:
    cmp byte ptr[di+1],09h 
    je strSearch 
    jmp setAmount
strSearch:
    jmp stringSearch
parsingEnd:  
    lea si,nString
    call atoi
	mov n, ax
checkMinSize:	
	cmp ax, minSize
	jae checkMaxSize
    outString minError
	mov ax,4C00h
    int 21h
checkMaxSize:		
	cmp ax, maxSize
	jbe goodSize
	outString maxError
	mov ax,4C00h
    int 21h
goodSize:
    mov ax, counter
    cmp ax, n
    jae endMain

    mov sp,programLength + 100h + 200h      ;перемещение стека на 200h после конца программы
    mov ah,4Ah                              ;освобождаем всю память после конца программы и стека
    stackShift = programLength + 100h + 200h;размер в параграфах +1
    mov bx,stackShift shr 4 + 1  
    int 21h     
    
    mov ax,cs                               ;заполняем поля epb, содержащие сегменты адреса
    mov word ptr EPB + 4,ax                 ;сегмент командной строки
    mov word ptr EPB + 8,ax                 ;сегмент первого fcb(блок управления файлом)
    mov word ptr EPB + 0Ch,ax               ;сегмент второго fcb
    mov ax,4B00h                            ;вызвать программу
    mov dx,offset namePath                  ;путь к Файлу
    mov bx,offset EPB                       ;блок epb
    int 21h                                 ;запуск программы
    inc counter
    jmp goodSize
endMain:                 
    int 20h      
     
EPB dw 0000                                 ;текущее окружение
    dw offset commandline,0                 ;адрес командной строки
    dw 005Ch,0,006Ch,0                      ;адрес fcb программы
commandline db 125                          ;длина командной строки
    db " /?"                                ;командная строка
commandText db 122 dup (?)                  ;командная строки
programLength equ $-start                   ;длина программы
end start






