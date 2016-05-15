TITLE School Project - Assembly
Name Snake 
IDEAL
MODEL small
STACK 100h

	include "projmac.asm"		;All macros

DATASEG
	include "projasc.asm"		;All Ascii art in text mode
;=================================================================
                    ;Structs start
;=================================================================                                                                                                    
	struc hulia
		x dw ?				;start x point of squad
		y dw ?				;start y point of squad
		endx dw ?			;end x point of squad
		endy dw ?			;end y point of squad
		direcB db ?			;DirecB = Direction Before
		direcN db ?			;1=up,2=down,3=left,4=right
		next db ?			;DirecN = Direction Now
	ends hulia
	
	struc Player
		l1 db ?				;=Letter1
		l2 db ?				;=Letter2
		l3 db ?				;=Letter3
		l4 db ?				;=Letter4
		l5 db ?				;=Letter5
		l6 db ?				;=Letter6
		l7 db ?				;=Letter7
		l8 db ?				;=Letter8
		scorep  db ?		;Scorep = score player
		scorep2 db ?	;	Scorep2 = Score player digit 2
	ends Player
	
;=================================================================
                    ;Variables
;=================================================================
        File_Name db 'SL.txt',0							;scorelist file to open
        Buffer dw 100 dup (0)							;buffer to get the information from scorelist file
        File_Handle dw ?								;file handler to the scorelist file
        x1 dw ?                        					; move to x1 the x starting point of squad to print squads                          
        x2 dw ?											; move to x2 the endx starting point of squad to print squads      
        y1 dw ?											; move to y1 the y starting point of squad to print squads      
        y2 dw ?											; move to y2 the endy starting point of squad to print squads      
        prevMil db ?                    				;check if the timer change
        Clock equ es:6Ch                				;Memory location of timer
        randX dw ?                      				;cordinatot of random apples
        randY dw ?										;cordinatot of random apples
        endRandX dw ?									;cordinatot of random apples
        endRandY dw ? 									;cordinatot of random apples
        username db 8									;user variable to put name after game
        user db 10 dup (0)								;user variable to put name after game
        Score_Text db 'Score:$' 						;Score Text Showing
        Level_Text db 'Level:$'							;Level Text Showing
        Name_String db 'Name$'							;Name Text Showing
        instruc_design db 'Pick A Color $'				;Text To Show To User
		Press_Enter db 'Press Enter To Start Playing$'	;Text To Show To User
		Example db 'Example$'							;Text To Show To User
		Score_String db 'Score$'						;Score Text Showing
        Present_Score db 'Your Score is: $'				;YourSCORE Text Showing
        Enter_Name db 'Enter Your Name: $'				;EnterName Text Showing
        GameOver_Instructions db '* By Pressing Enter Your Name Will Be Written In The Score List.',10,'    If You Dont Want To Be In The Score List,',10,'    Do Not Write Anything And Press Enter.$'
	    Level_Instruction db 'Press 1 For Level Easy',10,'			  Press 2 For Level Hard$'
		level_note db '*Note: The Game Will Start When You Click 1 or 2',10,'            Else, This Page Is Not Going To Replace To The Game$'
		OpenScreen_Instruction db 'Press I For Instructions',10,'		    	  Press S To Play',10,'		    	  Press L For Score List',10,'	    		  Press E To Exit$'
		PressAny db 'Press Any Key To Continue..$'
		notelength db '*The Name Has To Be More Then 2 Letters$'
		Instruction_Text db 'the goal of the game is to move the snake and eat as many apples',10,'     as you can. pay attention! the snake gets bigger and bigger every',10,'    time it eats an apple. be careful not to crash against the the borders',10,'                      of the field or into yourself.',10,10,10,'                 the keys you use to move the snake are:',10,'		  	        A- Left',10,'  			        S-Down',10,'   		     	        D-Right',10,'   			        W-Up',10,10,10,'		  Have Fun! Press Any Key To Continue...$' 
		colorsnake db 14								;variable hold the color of snake
		ColorsOptions db 14,6,10,2,11,3,9,1,13,5		;Options for snake color
		flagsc db ?										;=1=dont need to update the list, else, need to update
		Score_Number dw 0    							;Score Number That Change when snake eat the apple
		pointapple db 10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155		;array of 30 possible position to put random apples
		postemp db ?									;Variable that helps to move the cursor in a loop
		space db '                     $'				;Space for Score List: Name -space- score
		flagout db 0									;flag=0=didnt touch himself, else  = touch himself
		squad db 11										;use for set position of cursor in loop
		arr hulia 5000 dup (?)							;Array Of Squads of snake
		plyr Player 3 dup (?)							;Array of players top3 infromation
		flagrand db 0									;flagrand=0=random values are not equals to any squads values, else, we need to generate another random value
CODESEG

	include "projproc.asm"								;All Procedures
	
start:
        mov ax, @data
        mov ds, ax
        mov es,ax               ;For Strings
        mov ax,40h
        mov es,ax               ;For Timer
; --------------------------
; Your code here
; --------------------------
		mov ax,13h
		int 10h
		;Show Open Screen and open all the files i need
		call Open_File  
        call Read_File 
		call Get_Information
		
		mov ax,0002h
		int 10h
		call OpenScreen
exit:
        mov ax, 4c00h
        int 21h
END start