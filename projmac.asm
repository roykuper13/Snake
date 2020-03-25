     
        ; Store in CX the given string's length
         macro strlen    
            local len
            mov si,offset user
            inc si                      ;SI iterates the string's characters
            xor cx,cx
            dec cx
            len:
                inc cx                  ;inc the length
                inc si                  ;inc SI to point to the next character
                cmp [byte ptr si],0     ;check if we reached the end of the string
                jne len
        endm strlen
        
        ;Print the tail of the snake, using the given positions of the snake's node
        ;and the given color.
        macro print_tail color
            mov ax,[si]
            mov [x1],ax
            mov ax,[si+2]
            mov [y1],ax
            mov ax,[si+4]
            mov [x2],ax
            mov ax,[si+6]
            mov [y2],ax
            print_snake_node [x1],[y1],[x2],[y2],color
        endm print_tail
        
        ;Paint the characters of a string
        macro paint_characters color,v1,v2,v3,v4
            xor al,al
            mov bh, color
            mov ch,v1
            mov cl,v2
            mov dh,v3
            mov dl,v4
            mov ah,6h
            int 10h
        endm paint_characters
       
        macro flush_buffer
            mov ah,0Ch
            xor al,al
            int 21h
        endm flush_buffer
       
       ;A nice helper macro which pushes registers to the stack
        macro push_regs  r1,r2,r3,r4
            irp register,<r1,r2,r3,r4>
                ifnb <register>
                        push register
                endif
            endm
        endm push_regs
       
       ;A nice helper macro which pops registers off the stack
        macro pop_regs  r1,r2,r3,r4
            irp register,<r1,r2,r3,r4>
               ifnb <register>
                       pop register
               endif
           endm
        endm pop_regs
        
        ; Using the given [randX] and [randY], the macro sets
        ; the values of the snake node's edges (endRandX and endRandY)
        ; Note that each node is 5x5 pixels, and therefore we add 5 to randX and Y
        Macro set_node_edges
            mov ax,[randX]
            add ax,5        
            mov [endRandX],ax
            mov bx,[randY]
            add bx,5
            mov [endRandY],bx
        endm set_node_edges
 
        ;put in al the pixel color of the positions, given in cx_value and dx_value.
        macro get_pixel_color_by_pos cx_value,dx_value
            mov cx,cx_value
            mov dx,dx_value
            mov ah,0Dh
            int 10h
        endm get_pixel_color_by_pos
        
        ;Print a node of snake, using the 4-tuple position values and color
        macro print_snake_node sX,sY,eX,eY,color
            local line
            xor bh,bh
            mov ah,0Ch
            mov cx,sX               ;get starting x
            mov dx,sY               ;get starting y
            mov al,color            ;get color
            line:
                int 10h
                inc cx              ;print all the x line
                cmp cx,eX           ;check if we got to the end of line
                jne line
            inc dx                  ;go to the next column
            mov cx,sX               ;get again starting line
            cmp dx,eY               ;check if we got to the end of columns to print
            jne line                ;if not,let'ss continue
        endm print_snake_node
         
        ;Generate random value (which can be at most max_value), using the timer.
        macro random_get max_value
            mov ax,40h
            mov es,ax               ;For Timer
            mov ax,[Clock]
            mov ah,[byte cs:bx]
            xor al,ah
            xor ah,ah               
            and al,max_value        ;Leave The Random Number Between 0-max_value 
        endm random_get
       
       ;Loop until the timer changes its value (Mostly use to wait for the snake's movement)
        macro timer_wait
            local wait_loop
            local change
            wait_loop:
                mov ah,2ch
                int 21h
                mov [prevMil],dl            ;get first tick
                change:
                    mov ah,2ch
                    int 21h
                    cmp dl,[prevMil]        ;check if we got a change in timer
                    je change               ;if we are not, lets go and check again
        endm timer_wait
       
       ; Make SI point to the snake's last node, and BX to the following potentional node
        macro get_tail_pos
            local look
            local outlook
            mov bx,offset arr.x     ;point to starting squad x point
            look:
                cmp [byte ptr bx],0 ;check if x point of squad is 0
                je outlook          ;if it is, so there is no squads anymore
                add bx,11           ;if not, lets go and check the next squad if it accessed
                jmp look
            outlook:
                mov si,bx           ;bx point to the squad after the last snake squads
                sub si,11           ;si point to the last squad of snake
        endm get_tail_pos
     
        ;Sets the cursor position using the given row and column values
        macro set_cursor_pos row,column
                push_regs ax,bx,dx
                xor bh,bh
                mov ah,02h
                mov dh,row
                mov dl,column
                int 10h
        pop_regs dx,bx,ax
        endm set_cursor_pos
        
      ;macro printing strings to the screen 
        macro print_str string
               push_regs ax,dx
                mov dx,offset string
                mov ah,9h
                int 21h
                pop_regs dx,ax
        endm print_str
        
        macro CopyNewName offsetplyer,offsetscore
            local Copy
            mov si,offset user
            inc si
            mov di,offsetplyer  ;struct start where?
            Copy:
                mov al,[si]     ;get letter from name
                mov [di],al     ;put letter in struct
                inc si          
                inc di
                cmp [byte ptr si],00    ;check if we got to the end of the name
                jne Copy
                mov [byte ptr di-1],00  ;delete the enter ascii code
            mov ax,[Score_Number]       ;bh hold the number
            mov bl,10
            div bl                      ;this is a number and we need to lefarek to digits
            mov bx,offsetscore
            mov [bx],al                 ;so al get the asarot number and get in first
            mov [bx+1],ah               ; ah get the ahadot number and get second to the struct
        endm CopyNewName
        
        macro CopySecondName offsetPlayer1,offsetPlayer2
            local Copy4
            mov si,offsetPlayer1        ;from where to get letter (struct position to start?)
            mov di,offsetPlayer2        ;to where i need to put
            Copy4:
                mov al,[si]             ;get letter 
                mov [di],al             ;put letter in the position
                inc si
                inc di
                cmp si,offsetPlayer2    ;check if it is the end of number score in struct
                jne Copy4               
        endm CopySecondName
        
        macro touchapple_add v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
        ;just copying all the information to build a new s
            get_tail_pos
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
            get_tail_pos
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