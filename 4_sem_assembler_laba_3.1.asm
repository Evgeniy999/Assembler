.model	small
.stack	100h
.data
            

MaxColumn equ 6
MaxRow equ 5
MinColumnRow equ 0

Temp_Column db ?
Temp_Row db ?          
            
ArrayLength                 db  ?

Error                       db  0Dh,'Error!',0Ah, '$'                                
ErrorInputStr               db  0Dh,'Input error!',0Ah, '$'

InputColumnStr              db  0Dh,'Input array Column (1-6): $'
InputRowStr                 db  0Dh,'Input array Row (1-5): $'

ErrorColumn                 db  0Dh,'Array Column from 1 to 6.', 0Ah, '$'
ErrorRow                    db  0Dh,'Array Row from 1 to 5.', 0Ah, '$'
                                 
InputInterval               db  0Dh,'Interval -127 to 127.', 0Ah, '$'    
AnswerQuotient              db  3 dup('0'),'$'  
AnswerRemainder             db  3 dup(0),'$'  
AnswerArray                 db  3 dup(0),'$' 

ResultStr                   db  0Dh,'Result: $'      
                                
Buffer                      db  ?
                                           
quotient                    db ?
remainder                   db ?
	
                                                                              
                                
MaxNumLen                   db  5  
Len                         db  ?                         
buff                        db  MaxNumLen dup (0)              
                                
minus                       dw  0 

matr                        dw  0 ,0 ,0 ,0 ,0 ,0
                            dw  0 ,0 ,0 ,0 ,0 ,0                            
                            dw  0 ,0 ,0 ,0 ,0 ,0
                            dw  0 ,0 ,0 ,0 ,0 ,0
                            dw  0 ,0 ,0 ,0 ,0 ,0
                   
ResultStrSum                db  'Sum: $'
correct                     db  0Ah,0Dh, '$'
probel                      db '   $'

str_1                       db 0Dh,'Enter ['
CurrRow                       db '0'
str_2                       db '] ['
CurrColumn                       db '0'
str_3                       db '] - $'

.code
 
main    proc
        mov     ax,     @data
        mov     ds,     ax
        
        call inputInfo
        call correctproc
        xor     bx,bx               
        xor     ax,ax
        mov     bl,Temp_Column       ;ðàçìåð ñòðîêè ðàâåí 12 áàéòàì òê 6 ñòîëáöîâ*2
        mov     al,2
        mul     bl
        mov     bx,ax
        
        xor     cx,cx     
        mov     cl,     Temp_Row     ;ñòðîêè
        lea     si,     matr         ;ñìåùåíèå íà ìàòðèöó
            
        ForI:
                push    cx           ;ñîõðàíÿåì íàøå êîëè÷åñòâî ñòðîê
                mov     cl,  Temp_Column    
                mov     di,     si   ;ñìåùàåìñÿ êàæäûé ðàç íà ïåðâûé ýëåìåíò â ñëåä. ñòðîêå
                mov     ax,     0    ;äëÿ ñóììû ñòðîêè
        ForJ:
                add ax, [di]         ;ñóììèðîâàíèå
                push ax
                mov ax, [di]
                call Show_AColumn
                call probelproc
                pop ax
                jo Trigger           ;åñëè ñðàáîòàë ôëàã ïåðåïîëíåíèÿ                      
                add di, 2            ;ïåðåìåùàåìñÿ íà ñëåä ýë â ñòðîêå               
        loop    ForJ
                
                pop     cx           ;âûòàñêèâàåì íàøå êîëè÷åñòâî íåïðîñóììèðîâàííûõ ñòðîê
                
                call Result                
                call Show_AColumn    ;âûâîä ñóììû òê îíà ìîæåò áûòü è îòðèö
                call correctproc
                
        Next:
                add     si, bx       ; si ñåé÷àñ ñòîèò ó íàñ íà 1-îì ýëåìåíòå ñòðîêè êîòîðóþ ìû ïðîñóììèðîâàëè
                loop    ForI         ;ïðèáàâëÿåì 12 áàéò è ñòîèì óæå íà ñëåä ñòðîêå â ïåðâîì ýëåìåíòå 
        
        Ending:                               
                                                              
                mov     ax,     4C00h   ;End
                int     21h
        
        Trigger:                        ;End
                mov ah,09h
                lea dx,Error
                int     21h
                mov     ax,     4C00h
                int     21h                            
          
main    endp 

Result proc
        push ax
        push dx
        mov ah,09h         ;âûâîä ñîîáùåíèÿ                      
        lea dx, ResultStrSum           
        int 21h
        pop dx
        pop ax
ret
Result endp
    
correctproc proc
        push ax
        push dx
        mov ah,09h                           
        lea dx, correct           
        int 21h
        pop dx
        pop ax    
ret    
correctproc endp

probelproc proc
        push ax
        push dx
        mov ah,09h        ;âûâîä ñîîáùåíèÿ                      
        lea dx, probel           
        int 21h
        pop dx
        pop ax               
ret
probelproc endp


Show_AColumn proc
    
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
Show_AColumn endp


inputInfo proc                        
    call inputArrayRow
    call inputArrayColumn       
    call inputArray                                         
    ret                           
endp 

inputArrayColumn proc   
    mov cx, 1           
    inputColumn:
       call ShowColumn
       call inputElementBuff          
       
       test ah, ah
       jnz inputColumn 
       
       cmp Buffer, MaxColumn
       jg inputColumn_FAIL   
       
       cmp Buffer, MinColumnRow
       jle inputColumn_FAIL   
       
       jmp inputColumn_OK
       
       inputColumn_FAIL:
       
       call ShowErrorColumn 
       jmp inputColumn
       
       inputColumn_OK:
       
       mov bl, Buffer 
       mov Temp_Column, bl                 
    loop inputColumn     
    ret      
endp

inputArrayRow proc   
    mov cx, 1           
    inputRow:
       call ShowRow
       call inputElementBuff          
       
       test ah, ah
       jnz inputRow
       
       cmp Buffer, MaxRow
       jg inputRow_FAIL   
       
       cmp Buffer, MinColumnRow
       jle inputRow_FAIL   
       
       jmp inputRow_OK
       
       inputRow_FAIL:
       
       call ShowErrorRow 
       jmp inputRow
       
       inputRow_OK:
       
       mov bl, Buffer 
       mov Temp_Row, bl                 
    loop inputRow     
    ret      
endp

inputArray proc
    lea di,matr                     
    
    push ax
    push dx
    
    xor ax,ax
    xor dx,dx
    
    mov al,Temp_Row
    mov dl,Temp_Column
    mul dl                                           
    mov cx,ax  ;âû÷èñëåíèå ðàçìåðíîñòè
    
    pop dx
    pop ax
     
    
    lea dx, InputInterval
    mov ah, 09h 
    int 21h   
             
    inputArrayLoop: 
       call ShowInput                    
       call inputElementBuff      
       
       test ah, ah
       jnz inputArrayLoop
       
       mov bx,word ptr Buffer
       cmp bl, 0
       jl Minus_bl 
       mov [di], bx
       add di, 2
       call ColumnRowshow
                            
    loop inputArrayLoop           
    ret
    Minus_bl:
    mov bh, -1
    mov [di], bx
    add di, 2
    call ColumnRowshow
     
    loop inputArrayLoop           
    ret      
endp  

ColumnRowshow proc
    push ax
    push dx
    push cx
    push bx
    push di
    push si
    
    xor dx,dx
    xor ax,ax 
    
    mov dl, [CurrColumn]
    sub dl, 30h                  ;ïåðåâîä â ÷èñëî äëÿ ÷èñåë <10 è íå -
    mov si, offset Temp_Column   ;ýòî è òàê ÷èñëî
    mov al, [si]
    sub al, 1                    ;ïðîñòî êîððåêöèÿ òê ìàêñ ñòðîê ñòîëáîö ïðè ââîäå 6 à ïðè âûâîäå enter[][]ó íàñ îò 0 äî 5
    cmp dl, al
    je minus5
    add CurrColumn,01
       
    jmp endSHOW
    
    minus5:
    sub CurrColumn, al ;ïî àñêè êîäó ïðîñòî
    add CurrRow, 1
    
    endSHOW: 
    pop si
    pop di
    pop bx
    pop cx
    pop dx
    pop ax 
    ret    
ColumnRowshow endp 

resetBuffer proc
    mov Buffer, 0    
    ret
endp    

inputElementBuff proc             
    push cx                       
    inputElMain:                  
        call resetBuffer          
        
        mov ah,0Ah                  
        lea dx, MaxNumLen         
        int 21h                   
                                  
        mov dl,10                 ;Ñèìâîë êîòîðûé íàäî âûâåñòè íà ýêðàí
        mov ah,2                  ;Ôóíêöèÿ DOS âûâîäà ñèìâîëà
        int 21h                   ;Ïðåðûâàíèå äëÿ âûïîëíåíèÿ ô-öèè
                                  
        cmp Len,0                 
        je errInputEl             
                                  
        mov minus,0               ;Reset minus
        xor bx,bx                 ;Reset bx
                                  
        mov bl,Len                
        lea si,Len                
                                  
        add si,bx                 
        mov bl,1                  
                                  
                                  
        xor cx,cx                 
        mov cl,Len                
        inputElLoop:              ;ïðîöåäóðà îáðàáîòêè âûõîäíîãî ôëàãà èç ÷åêñèñòåì        
            std                   ;Óñòàíîâêà ôëàãà íàïðàâëåíèÿ äâèæåíèÿ ïî ìàññèâó
            lodsb                 ;Ñ÷èòàòü áàéò ïî àäðåñó DS:SI â AL
                                  ;Òåïåðü â al íàõîäèòñÿ òåêóùèé ñèìâîë
            call checkSym         ;Ïðîâåðêà ÷èñëî ëè ýòî
                                  ;ah - flag
            cmp ah,1              ;Åñëè ah ñîäåðæèò 1, òî çíà÷èò ñèìâîë íå ïðîøåë êîíòðîëü checkSym è â ïðîöåññå åå âûïîëíåíèÿ ñòàë 1
            je errInputEl         ;Îáðàáàòûâàåì äàííóþ ñèòóàöèþ
                                  ;
            cmp ah,2              ;Åñëè ah ïîñëå âûïîëíåíèÿ checkSym ñîäåðæèò 2, òî çíà÷èò áûë ââåäåí çíàê ìèíóñà, íåîáõîäèìà äàëüøåéíàÿ ïðîâåðêà 
            je nextSym            ;
                                  ;
            sub al,'0'            ;Åñëè ìû íàõîäèìñÿ íà ýòîì øàãó, òî â al ëåæèò ñèìâîë â äèàïàçîíå '0'..'9', îòíèìàåì '0' ÷òîáû ïîëó÷èòü åãî ÷èñëîâîå çíà÷åíèå
            mul bl                ;Óìíîæîåì òåêóùóþ öèôðó íà ðàçðÿä
                                  ;
            test ah,ah            ;Ïîáèòîâîå and ñ èçìåíåíèåì ÒÎËÜÊÎ ôëàãîâ, ðåçóëüòàò íå ñîõðàíÿåòñÿ
                                  ;Ïðîâåðêà çíà÷åíèÿ ðåãèñòðà íà ðàâåíñòâî íóëþ, Åñëè ðàâíî íóëþ -> Îøèáîê íå âûÿâëåíî
            jnz errInputEl        ;Åñëè íå íîëü - îøèáêà ââîäà
                                  
            add Buffer,al         ;Çàïèñûâàåì òåêóùóþ ÷àñòü ÷èñëà â ìàññèâ. Òèï 123 = 3 + 2*10 + 1*100
                                  
            jo errInputEl         ;Åñëè åñòü ïåðåïîíåíèå
            js errInputEl         ;Çíàê ðàâåí 1
                                  
            mov al,bl             ;Â al çàãðóæàåì bl
            mov bl,10             ;Â bl 10
            mul bl                ;Óìíîæàåì al íà 10, ïåðåõîä íà ñëåäóþùèé ðàçðÿä ÷èñëà
                                  
            test ah,ah            ;Ïîáèòîâîå and ñ ôëàãàìè îïÿòü
            jz ElNextCheck        ;Åñëè íóëü èëè ðàâíî
                                   
                                  
            cmp ah,3              ;Åñëè ah !=3 îøèáêà ââîäà
            jne errInputEl        ;Ò.ê. îò 0 äî 2 ìû ïðîâåðèëè, 10^3 â 16ññ = 3xx, òî 10^3 åùå äîïóñòèìà, à èç 10^4+ íåò
                                  
                                  
            ElNextCheck:          
                mov bl,al         
                jmp nextSym       
                                  
                                  
            errInputEl:           
                call ErrorInput   ;Âûâîä ñîîáùåíèÿ îá îøèáêå ââîäà
                jmp exitInputEl   ;Ïîïûòêà ââåñòè ÷èñëî çàíîâî
                                  
            nextSym: 
            xor ah, ah            
        loop inputElLoop          
                                  
    cmp minus,0                   
    je exitInputEl                
    neg Buffer ;äåëàåì ÷èñëî îòðèöàòåëüíûì                    
                                  
    exitInputEl:                  
    pop cx                        ;Âîññòàíàâëèâàåì cx
    ret                           
endp

checkSym proc                     
    cmp al,'-'                    ;Åñëè ýëåìåíò ðàâåí ìèíóñó, òî äåëàåì âûâîä, ÷òî ìû ïûòàåìñÿ ââåñòè îòðèöàòåëüíîå ÷èñëî
    je minusSym                    ; zf=1 ðàâåí
                                  
    cmp al,'9'                    
    ja errCheckSym                ;Åñëè ñèìâîë áîëüøå 9 - îøèáêà ââîäà
                                  
    cmp al,'0'                    
    jb errCheckSym                ;Åñëè ñèìâîë ìåíüøå 0 - îøèáêà ââîäà
                                  
    jmp exitCheckGood             ;Åñëè ñèìâîë - öèôðà - ïåðåõîäèì â exitCheckGood, ãäå ñáðàñûâàåì ìåòêó îøèáêè
                                  
    minusSym:                     
        cmp si,offset Len         
        je exitWithMinus          
                                 
    errCheckSym:                  
        mov ah,1                  ;Incorrect symbol
        jmp exitCheckSym          
                                  
    exitWithMinus:                
        mov ah,2                  
        mov minus, 1              ;Óñòàíàâëèâàåì ìåòêó, ÷òî ÷èñëî îòðèöàòåëüíîå
        cmp Len, 1               
        je errCheckSym            ;Åñëè ÷èñëî ñîñòîèò òîëüêî èç ìèíóñà ëèáî áûëè ââåäåíû 2+ ìèíóñà - îøèáêà ââîäà!
                                  
        jmp exitCheckSym          
                                  
    exitCheckGood:                
        xor ah,ah                 ;Ah = 0 
                                  
    exitCheckSym:                 
        ret                       
endp                              
                                  
ErrorInput proc                   
    lea dx, ErrorInputStr      
    mov ah, 09h                   
    int 21h                       
    ret                           
endp                              

ShowColumn proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, InputColumnStr           
    int 21h  
    
    pop ax
    pop dx 
     
    ret
endp

ShowRow proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, InputRowStr           
    int 21h  
    
    pop ax
    pop dx 
     
    ret
endp 
         
                              
ShowInput proc                   
    mov ax,di                    
    add ax,1                 
    mov bl, 10
    div bl          
              
    push di                              
           
    outputMessage:                      
   
    push ax
    push dx
                                  
    mov ah,09h                   
    lea dx, str_1          
    int 21h 
    
    pop dx
    pop ax
    pop di
                        
    ret                           
endp    


ShowErrorColumn proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, ErrorColumn           
    int 21h  
    
    pop ax
    pop dx 
     
    ret
endp

ShowErrorRow proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, ErrorRow          
    int 21h  
    
    pop ax
    pop dx 
     
    ret
endp
 
end     main






