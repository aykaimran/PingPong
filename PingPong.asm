[org 0x100]
call clrscr
xor ax, ax 
mov es, ax  

;save old isr and timer to change it when it terminates
mov ax, [es:9*4] 
mov [oldisr], ax  
mov ax, [es:9*4+2] 
mov [oldisr+2], ax 

mov ax, [es:8*4] 
mov [oldtimer], ax  
mov ax, [es:8*4+2] 
mov [oldtimer+2], ax 

cli  
mov word [es:8*4], timer  
mov [es:8*4+2], cs 
mov word [es:9*4], kbisr  
mov [es:9*4+2], cs  
sti  

loop1: 
cmp word[cs:moveflag], 1  ;if moveflag 1 then moveflag ball
jne loop1 

call erasefunc  
call movingfunc 
call print 

mov word[cs:moveflag], 0  ;make moveflag false
cmp word[cs:ScoreB],5  ;game finish 
je terminate 
cmp word[cs:ScoreA],5 
je terminate 
skipMove:    
jmp loop1 
      
terminate:  ;game ended
xor ax, ax 
mov es, ax 
                   
cli  ;resoring 
mov ax, [cs:oldisr]       
mov bx, [cs:oldisr+2]         
mov [es:9*4], ax       
mov [es:9*4+2], bx   
mov ax, [cs:oldtimer]       
mov bx, [cs:oldtimer+2]         
mov [es:9*4], ax       
mov [es:9*4+2], bx             
sti               
mov ax, 0x4c00        
int 0x21
   
rowposition: dw 22  
colposition: dw 39   
moveflag: dw 0 
oldisr: dd 0
oldtimer:dd 0  
turn: dw 0  ;0 =A and 1=B
ScoreB: dw 0 
ScoreA:dw 0
tickcount: dw 0 
direction: dw 0 

;-------------------------------------------------------------------
clrscr:
pusha
mov ax, 0xb800 
mov es, ax 
xor di, di 
mov ax, 0x0720 
mov cx, 2000 
cld 
rep stosw 
  
printpaddle1:
mov di, 30*2  ;row 0 ,col 30
mov al, ' '  
mov ah, 0x77 
mov cx, 20  
cld 
rep stosw 

printpaddle2:
mov di, ((23*80)+30)*2  ;row 23 ,col 30
mov al, ' ' 
mov ah, 0x77 
mov cx, 20   
cld 
rep stosw 

;this code is for restarting game
cmp word [cs:turn],0 
jne playerAturn
mov word[cs:rowposition],22  
mov word[cs:colposition],40 
jmp printend
playerAturn:
mov word[cs:rowposition],1  ;original position of ball
mov word[cs:colposition],40 
printend:
call print  ;print ball 
popa
ret 
;-------------------print scores--------------------
printingscores:
pusha
mov ax, 0xb800         
mov es, ax
mov ax, 80         
mov bl,12
mul bl            
shl ax, 1               
mov di, ax            ;location calculated  
mov ax, [cs:ScoreA]     
add al, '0'             ; convert to ASCII
mov ah, 0x07           
mov [es:di], ax        
add di, 2              

mov al, ':'             
mov ah, 0x07           
mov [es:di], ax        
add di, 2             
mov ax, [cs:ScoreB]    
add al, '0'        ;converting ascii to num  
mov ah, 0x07            
mov [es:di], ax         
popa
ret

;------------------- printing * --------------------------- 
print: 
pusha   
mov al, 80     
mul byte [cs:rowposition]  
add ax, [cs:colposition]   
shl ax, 1    
mov di, ax    
mov bl, '*' 
mov bh, 0x07   
mov ax, 0xb800 
mov es, ax 
mov [es:di], bx  
popa 
ret  

;----------------- moving ball here---------------------
movingfunc: 
;right and up = 0   right and down = 1   left and down = 2    left and up = 3
pusha   
cmp word [cs:direction], 0 
je rightandup 
cmp word [cs:direction], 1 
je rightanddown 
cmp word [cs:direction], 2 
je leftanddown 
cmp word [cs:direction], 3 
je leftandup
jmp endfunc ;no match. ik there is no reason to do this but i still wrote this line
 
rightandup: 
cmp word[cs:rowposition], 1  ;upper boundry
je ruskip
cmp word[cs:colposition], 79  ;right boundry
je ruskip2
dec byte [cs:rowposition] 
inc byte [cs:colposition] 
jmp endfunc 
 
ruskip: 
mov word [cs:direction], 1 
jmp endfunc 
 
ruskip2:
mov word [cs:direction], 3 
jmp endfunc
 
rightanddown: 
cmp word[cs:colposition], 79 ;right boundary
je rdskip 
cmp word[cs:rowposition], 22  ;down boundary
je rdskip2
inc byte [cs:rowposition] 
inc byte [cs:colposition] 
jmp endfunc 
   
rdskip: 
mov word [cs:direction], 2  
jmp endfunc 
  
rdskip2:
mov word [cs:direction], 0  
jmp endfunc 
 
leftanddown: 
cmp word[cs:rowposition], 22 ;down 
je ldskip 
cmp word[cs:colposition], 0  ;left boundary
je ldskip2 
 
inc byte [cs:rowposition] 
dec byte [cs:colposition] 
jmp endfunc
 
ldskip: 
mov word [cs:direction], 3 
jmp endfunc 
 
ldskip2:
mov word [cs:direction], 1 
jmp endfunc 

leftandup:
cmp word[cs:rowposition], 1    ;up 
je luskip 
cmp word[cs:colposition], 0    ;left 
je luskip2 
dec byte [cs:rowposition] 
dec byte [cs:colposition] 
jmp endfunc 
 
luskip: 
mov word [cs:direction], 2 
jmp endfunc
 
luskip2:
mov word [cs:direction], 0 
jmp endfunc

endfunc:
 
call changeturns  
call checkscore 
call printingscores

popa 
ret 
;---------------removing * ------------
erasefunc: 
pusha  
mov al, 80     
mul byte [cs:rowposition]   
add ax, [cs:colposition]    
shl ax, 1     
mov di, ax     
mov ax, 0xb800 
mov es, ax 
mov ax,0x0720 ; replace with space
mov [es:di], ax 
popa 
ret 
;----------------- changing turns  ----------------------
changeturns: 
pusha  
cmp word[cs:rowposition], 1 
jne skipturn 
mov word[cs:turn], 1  ; bottom paddle turn
jmp rt 
 
skipturn: 
cmp word[cs:rowposition], 22 
jne rt 
mov word[cs:turn], 0  ;top paddle turn 
rt: 
popa 
ret 

;-------------- check if fall hits the paddle or not --------------------- 
checkscore: 
pusha 
cmp word[cs:rowposition], 1 ;not close to paddle A
jne secondcomparison 

mov bx,0xb800 
mov es,bx 
mov ax,0 
mov al, 80    
mul byte [cs:rowposition]  
add ax, [cs:colposition]   
shl ax, 1   
mov di, ax 
  
sub di, 160 
mov ax, [es:di] 
cmp ax, 0x0720  ;if it is paddle 
jne finish  ;if not paddle then player lost this round
inc word[cs:ScoreB] 
mov word [cs:turn],0
call clrscr
jmp finish

secondcomparison:
cmp word[cs:rowposition], 22  ;not close to paddle B
jne finish   ; paddle ke pass hai hi nahi ball. its somewhere in screen 

mov bx,0xb800 
mov es,bx 
mov ax,0 
mov al, 80   
mul byte [cs:rowposition] 
add ax, [cs:colposition]
shl ax, 1  
mov di, ax 
  
add di, 160 
mov ax, [es:di] 
cmp ax, 0x0720 ;if it is paddle 
jne finish
inc word[cs:ScoreA] 
mov word [cs:turn],1
call clrscr
jmp finish
 
finish:
popa 
ret 
;---------------------timer----------------------------- 
timer: 
push ax 
inc word [cs:tickcount]
cmp word [cs:tickcount], 2  ;this can be changed. it changes speed of ball movement
jne endtimer  
mov word[cs:moveflag], 1 
mov word[cs:tickcount], 0 

endtimer: 
mov al, 0x20 
out 0x20, al 
pop ax 
iret  

;-------------------keyboard interrupt--------------------------- 
kbisr:  
pusha 
in al, 0x60  
cmp al, 0x4d  ;scan code of right key
je rightpressed  
cmp al, 0x4b  ;scan code of left key
je leftpressed   
jmp nomatch  ;nothing pressed 
    
rightpressed: 
cmp word[cs:turn], 0 
jne playerBturnn 

push 0    ;push 0 if player A turn, row 0
jmp playerAturnn 
playerBturnn: 
push 23   ;push 23 becz player B paddle is in row 23
playerAturnn: 
call rightmove 
jmp exit 

leftpressed: 
cmp word[cs:turn], 0 
jne PlayerBturn2
push 0 
jmp PlayerAturn2  
PlayerBturn2: 
push 23 
PlayerAturn2: 
call leftmove 
jmp exit  
   
exit:   
mov al, 0x20 
out 0x20, al     
popa 
iret     
nomatch:
popa 
jmp far [cs:oldisr] 
;-------------------moving paddle = right----------------------------- 
rightmove: 
push bp 
mov bp, sp 
pusha 
mov ax, 0xb800 
mov es, ax 
mov ds, ax 
mov ax, 80  
mul byte [bp+4]   
shl ax, 1   
mov si, ax 
add si,156 
mov di, si  ;position calculated
add di,2 

std 
mov cx, 79 
rep movsw 
mov word[es:di],0x0720 
popa 
pop bp 
ret 2 
;-------------------moving paddle= left--------------------------------- 
leftmove: 
push bp 
mov bp, sp 
pusha 
mov ax, 0xb800 
mov es, ax 
mov ds, ax 
mov ax, 80  
mul byte [bp+4]  
shl ax, 1  
mov di, ax  ;location calculated
mov si,di 
add si,2 
cld 
mov cx, 79 
rep movsw 
mov word[es:di],0x0720 

popa 
pop bp 
ret 2   
