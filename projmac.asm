	 
		;Get The Length Of user input in cx
		 macro String_Length    
				local lengthh
                mov si,offset user
                inc si				;Si points to the first letter
                xor cx,cx
                dec cx				;cx hold the length of word
                lengthh:
                        inc cx		;inc the length
                        inc si		;inc the pointer to the next letter
                        cmp [byte ptr si],0		;check if we got to the end of the word
                        jne lengthh
        endm String_Length
		
		;Get Position Of Squad And Print (erase=black or print new squad=14)
		macro printtail color
		;mov the x1,x2,y1,y2 all the squad information about each position on screen
			mov ax,[si]
			mov [x1],ax
			mov ax,[si+2]
			mov [y1],ax
			mov ax,[si+4]
			mov [x2],ax
			mov ax,[si+6]
			mov [y2],ax
			PrintSnake [x1],[y1],[x2],[y2],color
		endm printtail
		
		;Paint the strings in colors
        macro String_Color color,v1,v2,v3,v4
                xor al,al
                mov bh, color
                mov ch,v1
                mov cl,v2
                mov dh,v3
                mov dl,v4
                mov ah,6h
                int 10h
        endm String_Color
       
	   ;Clean The Buffer
        macro Clean_Buffer
                mov ah,0Ch
                xor al,al
                int 21h
        endm Clean_Buffer
       
	   ;Push Registers
        macro Pushing  r1,r2,r3,r4
			irp register,<r1,r2,r3,r4>
                ifnb <register>
                        push register
                endif
			endm
        endm Pushing
       
	   ;Pop Registers
        macro Popping  r1,r2,r3,r4
			irp register,<r1,r2,r3,r4>
               ifnb <register>
                       pop register
               endif
           endm
        endm Popping
		
		;Put in endRandX and endRandY their values correctly
        Macro Random_Into_Variables
                mov ax,[randX]
                add ax,5		
                mov [endRandX],ax	;end randx is randx +5 because squad is 5 on 5 pixels
                mov bx,[randY]
                add bx,5
                mov [endRandY],bx	;same explanation as above 
        endm Random_Into_Variables
 
		;put in al the pixel color of position in arguments
        macro GetPixelColor cxValue,dxValue
                mov cx,cxValue
                mov dx,dxValue
                mov ah,0Dh
                int 10h
        endm GetPixelColor
		
		;Print Square
        macro PrintSnake sX,sY,eX,eY,color
                local lop
                xor bh,bh
                mov ah,0Ch
                mov cx,sX		;get starting x
                mov dx,sY		;get starting y
                mov al,color	;get color
                lop:
                        int 10h
                        inc cx	;print all the x line
                        cmp cx,eX	;check if we got to the end of line
                        jne lop
                inc dx			;go to the next column
                mov cx,sX		;get again starting line
                cmp dx,eY		;check if we got to the end of columns to print
                jne lop			;if not,lets continue
        endm PrintSnake
         
		;Generate Random Values in al
        MACRO Random_Generate maxval
				mov ax,40h
				mov es,ax               ;For Timer
                mov ax,[Clock]
                mov ah,[byte cs:bx]
                xor al,ah
                xor ah,ah				;make zero ah
                and al,maxval   ;Leave The Random Number Between 0-maxval 
        endm Random_Generate
       
	   ;Loop Till timer get change to see the movement of snake
        MACRO Movement_Loop
            local LoopM
            local change
            LoopM:
                mov ah,2ch
                int 21h
                mov [prevMil],dl		;get first tick
                change:
                mov ah,2ch
                int 21h
                cmp dl,[prevMil]		;check if we got a change in timer
                je change				;if we are not, lets go and check again
        endm Movement_Loop
       
	   ;make bx point to the new squad and si the last squad
		macro Lastsquad
			local look
			local outlook
			mov bx,offset arr.x		;point to starting squad x point
			look:
				cmp [byte ptr bx],0	;check if x point of squad is 0
				je outlook			;if it is, so there is no squads anymore
				add bx,11			;if not, lets go and check the next squad if it accessed
				jmp look
			outlook:
				mov si,bx			;bx point to the squad after the last snake squads
				sub si,11			;si point to the last squad of snake
		endm Lastsquad
	 
	 ;macro to set the cursor position in screen
		macro set_Cursor_Position Row,Column
                pushing ax,bx,dx
				xor bh,bh
				mov ah,02h
				mov dh,Row
				mov dl,Column
				int 10h
        popping dx,bx,ax
		endm set_Cursor_Position
		
      ;macro printing strings to the screen 
		macro Print_String string
               pushing ax,dx
                mov dx,offset string
                mov ah,9h
                int 21h
                popping dx,ax
        endm Print_String
		
		macro CopyNewName offsetplyer,offsetscore
			local Copy
			mov si,offset user
			inc si
			mov di,offsetplyer	;struct start where?
			Copy:
				mov al,[si]		;get letter from name
				mov [di],al		;put letter in struct
				inc si			
				inc di
				cmp [byte ptr si],00	;check if we got to the end of the name
				jne Copy
				mov [byte ptr di-1],00	;delete the enter ascii code
			mov ax,[Score_Number]		;bh hold the number
			mov bl,10
			div bl						;this is a number and we need to lefarek to digits
			mov bx,offsetscore
			mov [bx],al					;so al get the asarot number and get in first
			mov [bx+1],ah				; ah get the ahadot number and get second to the struct
		endm CopyNewName
		
		macro CopySecondName offsetPlayer1,offsetPlayer2
			local Copy4
			mov si,offsetPlayer1		;from where to get letter (struct position to start?)
			mov di,offsetPlayer2		;to where i need to put
			Copy4:
				mov al,[si]				;get letter 
				mov [di],al				;put letter in the position
				inc si
				inc di
				cmp si,offsetPlayer2	;check if it is the end of number score in struct
				jne Copy4				
		endm CopySecondName
		
		macro touchapple_add v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
		;just copying all the information to build a new s
			Lastsquad
			mov ax,v1
			mov v2,ax
			mov ax,v3
			mov v4,ax
			mov ax,v5
			add ax,5
			mov v6,ax
			mov ax,v7
			add ax,5
			mov v8,ax
			mov al,v9
			mov v10,al
			mov v11,al
		endm touchapple_add
		
		macro touchapple_sub v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
		;just copying all the information to build a new struct
			Lastsquad
			mov ax,v1
			mov v2,ax
			mov ax,v3
			mov v4,ax
			mov ax,v5
			sub ax,5
			mov v6,ax
			mov ax,v7
			sub ax,5
			mov v8,ax
			mov al,v9
			mov v10,al
			mov v11,al
		endm touchapple_sub