.model tiny
.data
    alarmWord db "You didn't enter word!$"                                    
    inputString db "Enter string:$" 
    fl db "Don't use space!$" 
    inputWord db "Enter word:$ $"
    result db "Result:$" 
    alarmString db "String is empty!$" 
                   
    
    wordGreaterStringMes db "Word greater than string!$"
    maxStrLen db 200
    actStrLen db ?  
    string db 200 dup ('$') 

    maxLenWord db 200
    actLenWord db ?
    word db 200 dup ('$')

    myEndl db 10,13,'$' 
    next dw ?
.code
    
start:
    mov ah, 9h
    mov dx, offset inputString
    int 21h
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
                 
    mov ah, 0ah
    mov dx, offset maxStrLen   ;input 
    int 21h
                         
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
         
    mov ah, 9h
    mov dx, offset inputWord
    int 21h        
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h    
            
    mov ah, 0ah
    mov dx, offset maxLenWord     
    int 21h       
               
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
                        
    xor di, di
    mov di, offset string
    xor bx, bx
    mov bl, actStrLen     
    mov [di + bx], '$'      
    
 
    
    xor di, di
    mov di, offset word
    xor bx, bx
    mov bl, actLenWord     
    mov [di + bx], '$'   

    jmp CheckIsEmpty
    
isNotEmpty:    
    xor ax, ax
    mov al, actStrLen
    cmp al, actLenWord  
                                 
    jb wordGreaterString
    
    mov si, offset string
    mov next, offset string 
    
whileExistWord: 
   
    mov di, offset word                ;find index
    xor bx, bx 
     
    call findIndex                     ;ax - start index
                                       ;deleting    
    cmp ax, 0FFFFh                     ;no word, -1
    je noMoreWord                      ;if flag null raven 1
    
    xor si, si
    mov si, next
    cmp ax, 0000h                      ;first word with adress
    je firstWord
    jne notFirstWord                   ;if flag null raven 0
    
firstWord:     
    jmp checkEndWord  

notFirstWord:   
    xor cx,cx 
    mov cl, al               
loop2:                   
    add si, 1                          ;si++ si - start adress
    loopne loop2   ;loop, if don't equal 
   
    cmp [si - 1], ' '                  ;check " word"
    jne partOfWord
    
    jmp checkEndWord
    
partOfWord:                            ;if word is part of substring, we skip it

    xor ax, ax
    mov ax, si
    add al, actLenWord 
    mov next, ax
    xor si, si
    mov si, next
    
    jmp whileExistWord
    
     
callDeleting:    
    mov next, si     
    call deleting  
    
    xor si, si
    mov si, next
    
    jmp whileExistWord
    
noMoreWord:
    mov ah, 9h
    mov dx, offset myEndl
    int 21h   
    
    mov ah, 9h
    mov dx, offset result
    int 21h
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h  
    
    mov ah, 9h
    mov dx, offset string
    int 21h  
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
     
    mov ax, 4C00h
    int 21h
    ret    

emptyString:
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
    
    mov ah, 9h
    mov dx, offset alarmString
    int 21h 
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
     
    mov ax, 4C00h
    int 21h
    ret       

emptyWord:
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
    
    mov ah, 9h
    mov dx, offset alarmWord
    int 21h  
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h      
    
    mov ah, 9h
    mov dx, offset string
    int 21h 
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
     
    mov ax, 4C00h
    int 21h
    ret

wordGreaterString:
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
    
    mov ah, 9h
    mov dx, offset wordGreaterStringMes
    int 21h   
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
    
    mov ah, 9h
    mov dx, offset string
    int 21h  
    
    mov ah, 9h
    mov dx, offset myEndl
    int 21h
     
    mov ax, 4C00h
    int 21h
    ret
    
CheckIsEmpty:
xor si,si
check: 
    
    mov al,maxLenWord[si]
    inc si  
    
    cmp al,20h
    je message
    cmp al,0Dh
    je star  
    jmp check
star:    
    xor di, di                         ;check empty
    xor si, si
    mov di, offset word
    mov si, offset string
    cmp [si], '$' 
    je emptyString
    cmp [di], '$'
    je emptyWord
    jmp isNotEmpty
    
checkEndWord:
    xor bx, bx                         ;check "word " || "word"
    mov bl, actLenWord
    cmp [si + bx], ' '
    je callDeleting
    cmp [si + bx], '$' 
    je callDeleting   
    jne partOfWord

deleting proc near 
    xor ax, ax
    mov ax, si
    add al, actLenWord 
    xor di, di
    mov di, ax                         ;if it's last word of string
    cmp [di], '$'
    je end          
    add al, 1                          ;if it is'n last word of string (we need +1 for space)
    xor di, di
    mov di, ax      
while: 
    cmp [di], '$'   
    je end
    xor ax, ax
    mov ax, [di]
    mov [si], al
    
    add si, 1
    add di, 1
    jmp while  
end:
    xor ax, ax
    mov ax, [di]
    mov [si], al 
    ret   
deleting endp

findIndex proc ;near
st:
    inc bl                              
    xor ax, ax                         
    mov ax, si
    add al, actLenWord
    sub al, 1 
    xor cx, cx
    mov cx, offset string
    add cl, actStrlen
    
    sub cl, 1
    
    cmp cx, ax
    jb endOfRange    
    
    xor ax, ax
    mov ax, -1      
    
    cld   ;CLD (ñáðîñ DF â íîëü) è STD (óñòàíîâêà DF â åäèíèöó) îáðàáàòêà ñòðîêè ñëåâà íàïðàâî, àâòîìàòè÷åñêè óâåëè÷èâàÿ èíäåêñíûå ðåãèñòðû
    xor cx, cx  
    mov cl, actLenWord
    repe cmpsb                         ;find difference
    
    je equal                           ;if they equal
    
notequal:
    mov di, offset word
    mov ax, -1
    jmp st 
    
endOfRange:             
    mov ax, -1
    jmp endFind

equal:  
    dec bl
    xor ax, ax                         ;because i use 0..n
    mov al, bl
    jmp endFind
message:
    mov ah, 9h
    mov dx, offset fl
    int 21h

    
endFind:   
    ret      


    
findIndex endp          
    end start  nd start      
