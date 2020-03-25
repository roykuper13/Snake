;=================================================================
  ;Main Board Procedure - Drawing Board And Call Game Functions
;=================================================================          
        
        proc MainBoard
                push_regs ax,bx,cx,dx
            ;Text Mode
                mov ax,0002h
                int 10h
            
            ;Set Level Stuff:
                call setSnakeColor
            
            ;Graphic Mode
                mov ax,13h
                int 10h
            
            ;Print Score Text And Time Text
                set_cursor_pos 23,16
                print_str Score_Text
                mov [word ptr Score_Number],0
                call PRINT_NUMBER           ;Print Score 0
            
            
            ;Drawing Border Of Game
                call draw_borders
                                
            ;Put First Apple
                call Random_Values
                set_node_edges
                print_snake_node [randX],[randY],[endRandX],[endRandY],4
            ;Ipus All The Array Of Structures of snake
                mov bx,offset arr.x
                Zero:
                    mov [byte ptr bx],00
                    inc bx
                    cmp bx,offset plyr.l1
                    jne Zero
            ;First Squads Of Snake 
                mov [byte ptr arr.x],100
                mov [byte ptr arr.endx],105
                mov [byte ptr arr.y],160
                mov [byte ptr arr.endy],165
                mov [byte ptr arr.direcN],4
                mov [byte ptr arr.direcB],4
                ;=============
                mov bx,offset arr.x
                mov [byte ptr bx+11],95
                mov bx,offset arr.endx
                mov [byte ptr bx+11],100
                mov bx,offset arr.y
                mov [byte ptr bx+11],160
                mov bx,offset arr.endy
                mov [byte ptr bx+11],165
                mov bx,offset arr.direcN
                mov [byte ptr bx+11],4
                mov bx,offset arr.direcB
                mov [byte ptr bx+11],4
            ;Play   
                call PlaySnake 
                call stopnoise
            ;Back To Text Mode
                mov ax,0002h
                int 10h
            ;After Game Screen
                mov si,offset plyr.scorep
                mov bl,[si+22]
                mov al,10
                mul bl
                xor bh,bh
                mov bl,[si+23]
                add ax,bx       ;ax hold the last number in scorelist
                cmp ax,[Score_Number]   ;check if the newscore need to add to the scorelist
                jae nothigh
                call display_GameOver 
                jmp end_MainBoard
            nothigh:
                call Display_NotHigh
            end_MainBoard:
                pop_regs dx,cx,bx,ax
                ret
        endp MainBoard
        
        proc setSnakeColor
            mov ax,13h
            int 10h
            set_cursor_pos 4,2
            print_str Example
            set_cursor_pos 4,107
            print_str instruc_design
            set_cursor_pos 21,45
            print_str Press_Enter
        ;Draw Snake for showing examples for user
            mov [x1],40
            mov [x2],45
            mov [y1],60 
            mov [y2],140 
            print_snake_node [x1],[y1],[x2],[y2],[colorsnake]
        ;Drawing Palette of colors to user
            mov si,offset ColorsOptions
            mov [y1],50
            mov [y2],60
            mov [x1],260
            mov [x2],270
            DrawingPalette:
                print_snake_node [x1],[y1],[x2],[y2],[si]
                inc si
                add [y1],11
                add [y2],11
                cmp si,offset flagsc
                jne DrawingPalette
                
            tempMouse:
                mov ax,1
                int 33h
                WaitForKeyPressed3:
                    in al,64h       ;check keyboard status
                    cmp al,10b
                    je WaitForKeyPressed3
                    in al,60h       ;al hold the scan code  
                    cmp al,1Ch
                    je exitsetsnake
            ;Loop until mouse click
            MouseLp:
                mov ax,3h ;getting mouse status
                int 33h
                and bx,01h      ;check if left mouse clicked
                jz tempMouse ;00 in right bits means that no click
                   
                ;hide mouse
                mov ax,02h
                int 33h
                    
                shr cx,1        ;adjust cx to range 0-319 (before it was 639)
                sub dx,1        ;move back a little
                mov ah,0Dh      ;get Pixel Color
                int 10h
                cmp al,0        ;if it is not in the palette, so dont paint the snake
                je jmpmuose
                cmp al,15
                je jmpmuose
            ;Drawing New Snake with new color that have been chosen
                mov [colorsnake],al
                mov [x1],40
                mov [x2],45
                mov [y1],60 
                mov [y2],140 
                print_snake_node [x1],[y1],[x2],[y2],[colorsnake]
            jmpmuose:
                jmp MouseLp
            exitsetsnake:
                ret
        endp setSnakeColor
;=================================================================
                ;draw_borders Procedure - Drawing Game Borders   
;=================================================================
        proc draw_borders
            push_regs ax,bx,cx,dx
        ;Set Settings
            xor bl,bl
            mov al,15
            xor bh,bh
            mov ah,0Ch
        ;Settings For Lines Top And Bottom
            xor cx,cx
            xor dx,dx       ;For Top Line
            jmp Linee
            BottomLine_Settings:
                mov dx,170      ;For Bottom Line
                Linee:
                    int 10h
                    inc cx
                    cmp cx,320
                    jne Linee
                    inc dx
                    xor cx,cx
                    cmp bl,1        ;Check If We Are In Bottom Line
                    je Check_BottomLine
                ;Checking Top Line
                    cmp dx,5
                    jne Linee
                    mov bl,1
                    jmp BottomLine_Settings
                Check_BottomLine:
                    cmp dx,175
                    jne Linee
                ;Settings For Right And Left lines
                        xor bl,bl
                        xor cx,cx
                        xor dx,dx
                        jmp Line2
                RightLine_Settings:
                        mov cx,315
                Line2:
                    int 10h
                    inc dx
                    cmp dx,175
                    jne Line2
                        inc cx
                        xor dx,dx
                        cmp bl,1
                        je Check_RightLine
                        cmp cx,5
                        jne Line2
                        mov bl,1
                        jmp RightLine_Settings
                Check_RightLine:
                        cmp cx,320
                        jne Line2
                pop_regs dx,cx,bx,ax
                ret
        endp draw_borders
;=================================================================
                ;PlaySnake Procedure - The Game Itself
;=================================================================
        proc PlaySnake
            push_regs ax,bx,cx,dx
            Main_Loop:
                set_cursor_pos 23,22
            ;Check If The Snake Touch The Gvolut
                call stopnoise
                oo:
            ;Check If Snake Touch The Borders
                    cmp [arr.endy],170
                    jae beforeOutlop
                    cmp [arr.endx],312
                    jae beforeOutlop
                    cmp [arr.x],7
                    jle beforeOutlop
                    cmp [arr.y],7
                    jle beforeOutlop
                    mov ax,[arr.x]
                    cmp [arr.endx],ax
                    je beforeOutlop
                    mov bx,offset arr.direcN
                    
                   WaitForKeyPressed:
                        in al,64h       ;check keyboard status
                        cmp al,10b
                        je WaitForKeyPressed
                        in al,60h       ;al hold the scan code  
                        jmp checkKey
                    beforeOutlop:   ;because the jump was out of range
                        jmp outlop
                               
                    checkKey:  
                        ;Check Which key Is Pressed
                            cmp al,1Eh
                            je left_Key
                            cmp al,1Fh
                            je down_Key
                            cmp al,20h
                            je right_Key
                            cmp al,11h
                            je up_Key
                            cmp [arr.direcB],1
                            je up_Key
                            cmp [arr.direcB],2
                            je down_Key
                            cmp [arr.direcB],3
                            je left_Key
                            cmp [arr.direcB],4
                            je right_Key
                    ;Those Labels Make Sure That The Snake Can Move To The Direction The User wanted to
                    ;and call the move  and set the direction 
                    left_Key:   
                            cmp [arr.direcB],4
                            je Move_Snake
                            mov [byte ptr bx],3
                            jmp Move_Snake
                    right_Key:
                            cmp [arr.direcB],3
                            je Move_Snake
                            mov [byte ptr bx],4
                            jmp Move_Snake
                    down_Key:
                            cmp [arr.direcB],1
                            je Move_Snake
                            mov [byte ptr bx],2
                            jmp Move_Snake
                    up_Key:
                            cmp [arr.direcB],2
                            je Move_Snake
                            mov [byte ptr bx],1
                                
                ;Loop To Make The Snake Move
                Move_Snake:
                    flush_buffer
                    call Settings_tomove
                    cmp [flagout],1
                    je outlop
                    jmp Main_Loop
                outlop:
                        pop_regs dx,cx,bx,ax
                        ret
        endp PlaySnake 
;=================================================================
        ;Keys Functions - Called When Key Pressed In The Game
;=================================================================
        proc Settings_tomove
        ;looking for last squad to "erase=black" it
            mov si,offset arr.x
            lophh:
                add si,11
                cmp [byte ptr si],0
                jne lophh
                sub si,11
                print_tail 0                    ;Erase snake's tail
            ;check if touch an apple or itself && and move the snake procedure
                call Touching_Apple_Check
                call MoveTheSnake
                mov [flagout],0         ;flagout = 0 = not touch itself
                call Touching_Himself
                cmp [flagout],1     ;if flag=1 so the procedure find the snake touching himslef
                je exitset
            ;Print New Position of all the squad of the snake
                mov si,offset arr.x
                print_snake_node_Loop:
                    print_tail [colorsnake]
                    add si,11
                    cmp [byte ptr si],0
                    jne print_snake_node_Loop
            ;make the movement
                timer_wait
            ;put in all the direcB the direcN so the squad know what the squad in front of him made 
                mov bx,offset arr.direcB
                copy:
                    mov al,[bx+1]
                    mov [bx],al
                    add bx,11
                    cmp [byte ptr bx],0
                    jne copy
                exitset:
                    ret
        endp Settings_tomove
        
        proc MoveTheSnake
        ;Set in all the squads the direction of the last move of the squad in front of him
            mov bx,offset arr.direcB
            setDirecB:
                mov al,[bx]         ;get DirecB
                mov [bx+12],al      ;put DirecB in DirecN of the one before
                cmp [word ptr bx+23],0      ;Check if there isnt squad anymore
                je outDirecB
                add bx,11
                jmp setDirecB
            outDirecB:
            ;Settings:
                mov bx,offset arr.direcN
                mov di,2
                xor cx,cx
                xor ax,ax
                mov dx,2
        ;Check which direction the squad need to move
            MovDirecN:
                mov si,offset arr.x
                cmp [byte ptr bx],1
                je callup
                cmp [byte ptr bx],2
                je calldown
                cmp [byte ptr bx],3
                je callleft
        ;Next Labels: set New position of snake 
                push bx         ;Saving bx value
                mov bx,cx
                add [word ptr si+bx],5      ;change position to the next spot
                add [word ptr si+bx+4],5    ;change position to the next spot
                pop bx
                jmp checkmov
            callup:
                push bx
                mov bx,di
                sub [word ptr si+bx],5      ;change position to the next spot       
                sub [word ptr si+bx+4],5    ;change position to the next spot
                pop bx
                jmp checkmov
            calldown:
                push bx
                mov bx,dx
                add [word ptr si+bx],5      ;change position to the next spot
                add [word ptr si+bx+4],5    ;change position to the next spot
                pop bx
                jmp checkmov
            callleft:
                push bx
                mov bx,aX
                sub [word ptr si+bx],5      ;change position to the next spot
                sub [word ptr si+bx+4],5    ;change position to the next spot
                pop bx
            checkmov:
        ;Next Squad inc:
                add bx,11
                add di,11
                add ax,11
                add cx,11
                add dx,11
                cmp [byte ptr bx],0
                jne MovDirecN
            ret
        endp MoveTheSnake
;=============================================================================
;Random_Values Procedure - Generate Random Values And Put In Correct Variables
;=============================================================================
        proc Random_Values
        ;The random number from the macro is the index to the array of value of points to put apples
        ;Randx twice because he has a longer one
        Again:
             random_get 29d
             mov bx,offset pointapple
             add bx,ax
             mov al,[bx]
             mov [randX],ax
             random_get 29d
             mov bx,offset pointapple
             add bx,ax
             mov al,[bx]
             add [randX],ax
             random_get 29d
             mov bx,offset pointapple
             add bx,ax
             mov al,[bx]
             mov [randY],ax
             mov [flagrand],0       ;means that the random number isnt on the squads        
             call CheckRandom
             cmp [flagrand],1
             je Again
            ret
         endp Random_Values
         
         proc CheckRandom
                get_tail_pos            ;get last squad pointer
                mov bx,offset arr.x
                sub bx,11
            checkrand:
                    add bx,11
                    mov ax,[randX]
                    cmp ax,[bx]     ;check if x of squad equal to randx
                    je notgood      ;if it is we get out, it is not good..
                    mov ax,[randY]
                    cmp ax,[bx+1]   ;check if y of squad equal to randy
                    je notgood      ;if it is we get out, it is not good
                    cmp si,bx       ;check if we got to the end of snake
                    jae notgood     
                    jmp checkrand
            notgood:
                    cmp si,bx       ;if the pointer equal to the last squad, so everything ok
                    jae outcheckrand
                    mov [flagrand],1;if its not, we need a random number 
            outcheckrand:
            ret
         endp CheckRandom
;=============================================================================
;                           ;Game Options And Settings
;=============================================================================
        proc Touching_Himself
        ;Check Which Point of the snake we need to check
            cmp [arr.direcN],1
            je CheckUp
            cmp [arr.direcN],2
            je CheckDown
            cmp [arr.direcN],3
            je CheckLeft
        ;Next Labels: check the point that the snake should not be yellow (touch himslef)
            ;Check Right:
                mov ax,[arr.y]
                mov [y1],ax
                add [y1],3      ;Middle Point
                mov ax,[arr.endx]
                inc ax          ;One Pixel next 
                mov [x1],ax     
                get_pixel_color_by_pos [x1],[y1]
                cmp al,[colorsnake]
                je touchhimslef
                jmp outhimself
        ;--------Same As Above:----------;
            CheckUp:
                mov ax,[arr.x]
                mov [y1],ax
                add [y1],3
                mov ax,[arr.y]
                inc ax
                mov [x1],ax
                get_pixel_color_by_pos [y1],[x1]
                cmp al,[colorsnake]
                je touchhimslef
                jmp outhimself
            CheckDown:
                mov ax,[arr.x]
                mov [y1],ax
                add [y1],3
                mov ax,[arr.endy]
                inc ax
                mov [x1],ax
                get_pixel_color_by_pos [y1],[x1]
                cmp al,[colorsnake]
                je touchhimslef
                jmp outhimself
            CheckLeft:
                mov ax,[arr.y]
                mov [y1],ax
                add [y1],3
                mov ax,[arr.x]
                inc ax
                mov [x1],ax
                get_pixel_color_by_pos [x1],[y1]
                cmp al,[colorsnake]
                je touchhimslef
                jmp outhimself
            touchhimslef:
                mov [flagout],1     ;flag=1 says that he touch him self so the main procedure will know to exit game
            outhimself:
            ret
        endp Touching_Himself
        
        proc Touching_Apple_Check
        ;Check if the apple was touched by the snake
            add [randX],3
            add [randY],3
            get_pixel_color_by_pos [randX],[randY]      ;get color of the middle of the apple
            sub [randX],3
            sub [randY],3
            cmp al,[colorsnake]
            je Apple_Touch
            jmp Exit_AppleTouch
            Apple_Touch:
                inc [Score_Number]      ;Score inc
                call PRINT_NUMBER       ;Presend new Score
                call noise              ;Make a nice noise
            ;Check Which direction, so ill know where to add a squad
                cmp [byte ptr si+9],2
                je is_down
                cmp [byte ptr si+9],3
                je is_left
                cmp [byte ptr si+9],1
                je bis_up
                cmp [byte ptr si+9],4
                je is_right
        ;Print A Tail For Snake By set the settings of new squad betehem lsquad akodem
            is_left:
                touchapple_add [si+2],[bx+2],[si+6],[bx+6],[si],[bx],[si+4],[bx+4],[si+8],[bx+8],[bx+9]
                jmp con
            is_down:
                touchapple_sub [si],[bx],[si+4],[bx+4],[si+2],[bx+2],[si+6],[bx+6],[si+8],[bx+8],[bx+9]
                jmp con
            bis_up:
                jmp is_up
            is_right:
                touchapple_sub [si+2],[bx+2],[si+6],[bx+6],[si],[bx],[si+4],[bx+4],[si+8],[bx+8],[bx+9]
                jmp con
            is_up:
                touchapple_add [si],[bx],[si+4],[bx+4],[si+2],[bx+2],[si+6],[bx+6],[si+8],[bx+8],[bx+9]
            con:
                ;Delete last Apple
                sub [randX],3
                sub [randY],3
                add [endRandX],3
                add [endRandY],3
                print_snake_node [randX],[randY],[endRandX],[endRandY],0 
            ;Put NEW Apple
                call Random_Values
                set_node_edges
                print_snake_node [randX],[randY],[endRandX],[endRandY],4  
            Exit_AppleTouch:
                ret
        endp Touching_Apple_Check   
;=============================================================================
;                           ;BMP Files Stuff && Score List File
;=============================================================================
        proc Open_File 
                mov ah,3Dh
                xor al,al
                mov dx,offset File_Name
                int 21h
                jc outopenfile ;if the file didnt open
                mov [File_Handle],ax  ;Pointer To File Goes To The Variable
            outopenfile:
                ret
        endp Open_File
                
        proc Read_File
        ;Read File Settings:
            mov ah,3Fh
            mov bx,[File_Handle]
            mov cx,100
            mov dx,offset Buffer    ;The Info Goes To 'Buffer'
            int 21h                   
            ret
        endp Read_File
                  
        proc CloseFile
            mov ah,3Eh
            mov bx, [File_Handle]
            int 21h
            ret
        endp CloseFile
            
        proc Get_Information
        ;Set IN array struct the information from buffer
            xor dx,dx
            mov si,offset Buffer
            mov di,offset plyr.l1
            Get_Info:
                mov al,[si]     ;copy from buffer
                mov [di],al     ;to the struct
                mov ah,'^'      ;check if we are in the end of buffer
                cmp [si],ah
                je outGetInfo   ;if we are, jump out of loop because we are in the end of buffer
                inc si
                inc di  
                mov ah,' '      
                cmp [si],ah     ;check if we close one step from the number
                jne Get_Info                
                mov cl,[byte ptr si+1]
                sub cl,30h          ;first digit in his original value (not ascii)
                mov ch,[si+2]       
                sub ch,30h          ;second digit  in his original value (not ascii)
                add si,2
        ;After cl and ch hold the digits, we put in the right position of struct the digits
                mov di,offset plyr.scorep
                add di,dx
                mov [di],cl         ;put first digit
                mov [di+1],ch       ;put second digit
                add dx,11
        ;Go to the next name
                mov di,offset plyr.l1
                add di,dx
                inc si
                jmp Get_Info
            outGetInfo:
                    ret
        endp Get_Information
                
        proc show_Information
        ;Function that present the score list
            mov di,offset plyr.scorep
        ;Set all the numbers to their ascii code to present them 
            add [byte ptr di],30h
            add [byte ptr di+11],30h
            add [byte ptr di+22],30h
            add [byte ptr di+1],30h
            add [byte ptr di+11+1],30h
            add [byte ptr di+22+1],30h
            mov si,offset plyr.l1
            mov [squad],11      ;Start position
            set_cursor_pos [squad],23
            Displayy:
                mov ah,'^'          ;Check if we are in the end of the buffer
                cmp [si],ah
                je outDis           ;if we are, jump out
            ;Compare if si point the spot after the numbers
                cmp si,offset plyr.scorep+2
                je downline
                cmp si,offset plyr.scorep+11+2
                je downline
                cmp si,offset plyr.scorep+22+2
                je downline
            ;compare if si point to the first digit
                cmp si,offset plyr.scorep
                je printspace
                cmp si,offset plyr.scorep+11
                je printspace
                cmp si,offset plyr.scorep+22
                je printspace
                jmp condis
                printspace:
                    set_cursor_pos [squad], 30  ;set new position to cursor
                    mov dx,offset space             ;print space
                    mov ah,09h
                    int 21h
                    jmp condis
                downline:
                    add [squad],2
                    set_cursor_pos [squad],23   ;cursor down one line
                condis:
                    cmp [byte ptr si],00    ;no letters or no digit-no need to print
                    je noprint
                    mov dl,[si]             ;print letter\digit interrupt
                    mov ah,2h
                    int 21h
                noprint:
                    inc si
                    jmp Displayy
                outDis:
            ;Switch all the numbers back to their original value(not ascii)
                mov di,offset plyr.scorep
                sub [byte ptr di],30h
                sub [byte ptr di+11],30h
                sub [byte ptr di+22],30h
                sub [byte ptr di+1],30h
                sub [byte ptr di+11+1],30h
                sub [byte ptr di+22+1],30h
                ret
        endp show_Information
                
        proc Update_List
        ;Check The Biggest Number in the list and the new score
            mov bl,[plyr.scorep]
            xor ah,ah
            mov al,10
            mul bl
            add al,[plyr.scorep2]
            cmp [Score_Number],ax
            ja FirstOp
        ;Check The Middle Number in the list and the new score
            mov si,offset plyr.scorep
            mov bl,[si+11]
            mov al,10
            mul bl
            add ax,[si+12]
            cmp [Score_Number],ax
            ja SecondOp
        ;Check The Smallest Number In the list and the new score
            mov bl,[si+22]
            mov al,10
            mul bl
            add ax,[si+23]
            cmp [Score_Number],ax
            ja bthird
        ;else: No need to change the list
            jmp exit_UpdateList
            FirstOp:
            ;put first place in second place
                mov si,offset plyr.l1+11
                mov di,offset plyr.l1+22
                Copy1:
                    mov al,[si]     ;get the letter
                    mov [di],al     ;put the letter in second place
                    inc si
                    inc di
                    cmp si,offset plyr.l1+22    ;check if we got to the end of first place
                    jne Copy1
            ;put second place in third place
                    mov [x1],offset plyr.l1
                    mov [y1],offset plyr.l1+11
                    CopySecondName [x1],[y1]
            ;put the new name and his score in first place
                    mov [y1],offset plyr.scorep
                    CopyNewName [x1],[y1]
                    jmp exit_UpdateList
            bthird:
            ;relative jump out of range
                jmp ThirdOp
            SecondOp:
            ;put the second place in third place
                mov [x1],offset plyr+11
                mov [y1],offset plyr+22
                CopySecondName [x1],[y1]
            ;put the new name and score in second place
                mov [y1],offset plyr.scorep+11
                CopyNewName [x1],[y1]
                jmp exit_UpdateList
            ThirdOp:
            ;just put the name and his score bimkom the last one
                mov [x1],offset plyr.l1+22
                mov [y1],offset plyr.scorep+22
                CopyNewName [x1],[y1]
            exit_UpdateList:
                ret
        endp Update_List
;=============================================================================
;                   ;After\Open Game Procedures
;=============================================================================
 
        proc display_GameOver
        ;Back to Text Mode
            mov ax,0002h
            int 10h
        ;Displaying score and title
            paint_characters 14,1,0,4,70
            paint_characters 6,5,0,8,70
            set_cursor_pos 1,0
            print_str g
            paint_characters 00000100b,8,29,9,70
            set_cursor_pos 8,29
            print_str Present_Score
            call PRINT_NUMBER                   ;Print Score Itself
        ;Displaying all the get name stuff
            paint_characters 01111111b,11,33,11,48
            set_cursor_pos 11,16
            print_str Enter_Name
            paint_characters 14,18,2,24,70
            set_cursor_pos 18,2
            print_str GameOver_Instructions
            set_cursor_pos 11,34
            mov [squad],0               ;Paint In Black 
            mov [postemp],34            ;Use For Position the cursor
        ;clean last name wrote
            ZeroName:
                mov bx,offset user
                inc bx
                lz:
                    mov [byte ptr bx],?
                    inc bx
                    cmp bx,offset Score_Text
                    jne lz
        ;Get Input - username
            writename:
                set_cursor_pos 13,16
                paint_characters [squad],13,16,14,70
                print_str notelength
                set_cursor_pos 11,[postemp] 
                mov dx,offset username      
                mov ah,0Ah
                int 21h         ;get the input
                in al,60h       ;al hold the scan code
                cmp al,1Ch      ;check if enter pressed
                jne writename   ;if its not, we still wait, he didnt finish
                strlen          ;get name's length
                cmp cx,0        
                je iszero       ;if length=0 so he dont want to get to the score list so get out of it
                cmp cx,2        ;if the length < 2 it is too short, we will present the user an alert
                jle note                
                jmp out_Display_GameOver
            note:   
                mov [squad],12      ;change the black text to a red text so we can see it
                jmp writename
            out_Display_GameOver:
                call display_scroelist
            iszero:
                ret
        endp display_GameOver
        
        proc Display_NotHigh
        ;Back to Text Mode
            mov ax,0002h
            int 10h
        ;Displaying score and title
            paint_characters 14,1,0,4,70
            paint_characters 6,5,0,8,70
            set_cursor_pos 1,0
            print_str g
            paint_characters 00000100b,8,29,9,70
            set_cursor_pos 8,29
            print_str Present_Score
            call PRINT_NUMBER               ;Print Score Itself
            set_cursor_pos 17,22
            paint_characters 15,17,22,25,70
            print_str PressAny
        ;wait for key pressed
            mov ah,1
            int 21h
            ret
        endp Display_NotHigh
        
        proc display_scroelist
        ;Back to Text Mode
            mov ax,0002h
            int 10h
        ;Print Name,Score,and title
            paint_characters 11,1,0,4,70
            paint_characters 15,5,0,7,70
            set_cursor_pos 1,0
            print_str s
               
            paint_characters 5,8,23,9,70
            set_cursor_pos 8,23
            print_str Name_String
            paint_characters 5,8,50,9,70
            set_cursor_pos 8,50
            print_str Score_String
        ;Check If We need to update the list (yes=come from a game, no=come from the openscreen)
            cmp [flagsc],1
            je dilug_update
            call Update_List        ;update the list if we need to
        dilug_update:
            call show_Information
            call CloseFile
            print_str PressAny
        ;Wait For Key Press
            mov ah,1
            int 21h
            ret
        endp display_scroelist
        
        proc InstructionBoard
            ;Clean The Last Screen
            mov ax,0002h
            int 10h
            ;printing title instructions
            paint_characters 14,1,0,4,78
            paint_characters 15,4,0,6,78
            set_cursor_pos 1,0
            print_str i
            set_cursor_pos 8,6
            paint_characters 15,8,6,23,70
            print_str Instruction_Text
        ;Wait For Key To Pressed
            mov ah,1
            int 21h         
            ret
        endp InstructionBoard
        
        proc OpenScreen
            openit:
        ;Change Back To TextMode
            mov ax,0002h
            int 10h
        ;Displaying options to the user
            set_cursor_pos 2,0
            paint_characters 15,2,0,4,70
            paint_characters 10,5,0,9,70
            print_str o
            paint_characters 15,10,26,12,70
            set_cursor_pos 13,26
            paint_characters 15,13,26,24,70
            print_str OpenScreen_Instruction
        ;Check which option the user choose
            getkey:
                mov ah,07h
                int 21h
                cmp al,'s'
                je startg
                cmp al,'S'
                je startg
                cmp al,'i'
                je starti
                cmp al,'I'
                je starti
                cmp al,'e'
                je starte
                cmp al,'E'
                je starte
                cmp al,'L'
                je startl
                cmp al,'l'
                je startl
                jmp getkey
            startl:
            ;To Go To ScoreList
                mov [flagsc],1
                call display_scroelist
                mov [flagsc],0
                jmp openit
            startg:
            ;To Go To MainBoard
                call MainBoard
                jmp openit
            starti:
            ;To Go To Instruction Board
                call InstructionBoard
                jmp openit
            starte:
            ;To Get Out Of Program
                mov ax,0002h
                int 10h
                ret
        endp OpenScreen
        
;=============================================================================
;            ;Sound Procedures
;=============================================================================
        proc noise
                ; make a sound
                in      al, 61h
                or      al, 00000011b
                out     61h, al
                mov     al, 0b6h
                out     43h, al
                mov     ax, 1000h
                out     42h, al
                mov     al, ah
                out     42h, al
                ret
        endp noise
        proc stopnoise
                ;Stop The Sound
                in      al, 61h
                and     al, 11111100b
                out 61h, al
                ret
        endp stopnoise
;=============================================================================
;                        ;Help Procedures                    
;=============================================================================      
    PROC PRINT_NUMBER   ; Outputs integer word number stored in AX registry. Requires CPU
        ; Save state of registers.
     ;   PUSHA       ; Save all general purpose registers
        PUSH BP     ; We're going to change that.

        ; we need variables

        ; word number;      2 bytes
        ; byte digitsCount; 1 byte

        ; reserving space for variables on stack (3 bytes)
        mov bp, sp; ; bp := address of the top of a stack
        sub sp, 3*8 ; allocate 3 bytes on stack. Addresses of variables will be
                ; number:   WORD PTR [rbp - 2*8]
                ; digitsCount:  BYTE PTR [rbp - 3*8]

        ; Getting digits
        ; number = ax;
        ; digitsCount = 0;
        ; do
        ; {
        ;   push number%10;
        ;   digitsCount++;
        ;   number = number / 10;
        ; }
        ; while (number > 0)
        mov ax,[Score_Number]
        mov [WORD PTR bp - 2*8], ax ; number = ax;
        mov [BYTE PTR bp - 3*8], 0  ; digitsCount = 0;
        getDigits:          ; do
            mov ax, [WORD PTR bp - 2*8]; number/10: ax = number / 10, dx: number % 10
            ;cwd
            mov dx, 0
            mov bx, 10
            div bx
            push dx         ; push number%10
            mov [WORD PTR bp - 2*8], ax; number = number/10;
            inc [byte PTR bp - 3*8]  ; digitsCount++;
            cmp [WORD PTR bp - 2*8], 0; compare number and 0
            je getDigitsEnd     ; if number == 0 goto getDigitsEnd
            jmp getDigits       ; goto getDigits;
        getDigitsEnd:
        ;while (digitsCount > 0)
        ;{
        ;   pop digit into ax
        ;   print digit
        ;   digitsCount--;
        ;}
        printDigits:
            cmp [BYTE PTR bp - 3*8], 0; compare digits count and 0
            je printDigitsEnd   ; if digitsCount == 0 goto printDigitsEnd
            pop ax          ; BYPASS_POP_MATCH
            add al, 30h     ; get character from digit into al
            mov ah, 0eh     ; wanna print digit!
            int 10h         ; BIOS, do it!
            dec [BYTE PTR bp - 3*8]  ; digitsCount--
            jmp printDigits     ; goto printDigits
        printDigitsEnd:
        ; Deallocate local variables back.
        mov sp, bp
        ; Restore state of registers in reverse order.
        POP BP
        ; Exit from procedure.
        RET
    ENDP PRINT_NUMBER
;=============================================================================
;                       END PROCEDURES                 
;=============================================================================      