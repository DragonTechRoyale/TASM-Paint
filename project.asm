; Created By Ed Lustig
; Drawing program 
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
	rectangle_x dw 0 ; used for the DrawRectangle proc for the start x point of the rectangle
	rectangle_y dw 0 ; used for the DrawRectangle proc for the start x point of the rectangle
	rectangle_width dw 0 ; used for the DrawRectangle proc for setting the width of the rectangle
	rectangle_height dw 0 ; used for the DrawRectangle proc for setting the height of the rectangle
	rectangle_color dw 0 ; used for the DrawRectangle proc for setting the color of the rectangle
	line_color dw 0 ; used for the DrawDotNearMousePos proc for setting the color of the line
	message db 'Exiting program',13,10,'$' ; show this message on screen (you can only see it if the program takes
	; time to quit
	loop_counter_1 dw 0 ; used for various loops in the program instead of the cx register when it's in use
	loop_counter_2 dw 0 ; used for various loops in the program instead of the cx register when it's in use 
	; (another one is needed for nested loops)
	save_color dw 0 ; used to save to color to set to when returning to the pen
	crrnt_mouse_pos_x dw 0 ; save here the current x position of the mouse
	crrnt_mouse_pos_y dw 0 ; save here the current x position of the mouse
; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here

	; Graphics mode
	mov ax, 13h
	int 10h
	
	; draw top rectangle
	mov [rectangle_x], 0
	mov [rectangle_y], 0
	mov [rectangle_width], 320
	mov [rectangle_height], 40
	mov [rectangle_color], 8
	call DRAWRECTANGLE

	; draw pen
	mov [rectangle_color], 7
	call DrawPen

	; draw eraser
	;mov [rectangle_color], 7
	call DrawEraser
	
	; draw canvas
	mov [rectangle_x], 0
	mov [rectangle_y], 40
	mov [rectangle_width], 320
	mov [rectangle_height], 160
	mov [rectangle_color], 15
	call DRAWRECTANGLE

	; draw color options
	; colors will be in a gird of 8 x 2 with each color being 10 x 10
	mov [rectangle_color], 0 ; first color will be black
	mov [rectangle_y], 10 ; start the gird on y = 10
	mov [rectangle_x], 167 ; start the gird on x = 167
	mov [rectangle_width], 10
	mov [rectangle_height], 10
	mov [loop_counter_1], 8
	mov [loop_counter_2], 2
	drawColorsRow:
		mov [loop_counter_1], 8
		mov [rectangle_x], 167 ; start the gird on y = 10
		; draw a raw
		drawColors:
			; draw the actual colors
			call drawrectangle
			; Wait for key press to see screen each eturation (debugging)
			;mov ah, 00h
			;int 16h
			add [rectangle_x], 10
			inc [rectangle_color] ; to switch colors
			dec [loop_counter_1] ; to signal that an eturation passed
			; for some reasonn I can't figure I need to re-do this every
			; eturation otherwise they change
			mov [rectangle_width], 10
			mov [rectangle_height], 10
			cmp [loop_counter_1], 0 ; to know if an eturation passed or not
			ja drawcolors
		add [rectangle_y], 10 ; add 4 to the y to go a row under
		dec [loop_counter_2] ; dec loop_counter_2 to signal one 
		; eturation passed
		cmp [loop_counter_2], 0 ; to know if one eturation passed or not
		ja drawColorsRow

	; init mouse
	mov ax, 0
	int 33h
	
	; show mouse
	mov ax, 1
	int 33h

	; example code from book
	; get mouse position (loop until mouse click)
	; the first bit in bx means the left mouse button is pressed
	; the second bit in bx means the right mouse button is pressed
	; cx / 2 is the mouse's y axis (it's initially in range of 0-639)
	; dx is mouse's x axis
	;MouseLP:
	;	mov ax, 3
	;	int 33h
	;	cmp bx, 1 ; check left mouse click
	;	jne MouseLP
	;	; print dot near mouse location
	;	shr cx, 1 ; adjust to range 0-319, to fit screen
	;	sub dx, 1 ; move one pixel, so the pixel will not be hidden by mouse
	;	mov bh, 0
	;	mov al, [line_color]
	;	mov ah, 0Ch
	;	int 10h

	; draw line (main loop, change after so eraser can work too)
	DrawLine:

		
		; get mouse pos
		mov ax, 3
		int 33h
		and bx, 1
		shr cx, 1 ; adjust to range 0-319, to fit screen
		;(byte-shift of cx to right = cx / 2) prevent too big value (cx)

		cmp bx, 1 ; check if left mouse button was pressed
		;jne DrawDotNearMousePosLable ; if button was pressed jmp to draw
		; Wait for 'ESC' key press to exit loop
		; ('ESC' to save but saving isn't programmed yet)
		jne mouseWasntPressed ; jmp if it wasn't pressed to not call the drawing proc
			;mov [line_color], 0 ; old, used before color picking
			
			mov [crrnt_mouse_pos_x], cx
			mov [crrnt_mouse_pos_y], dx

			; check if color was pressed
			call CheckColor

			; check if pen was pressed
			call CheckPen

			; check if eraser was pressed
			call CheckEraser

			call DrawDotNearMousePos		
		mouseWasntPressed: ; jmp here if the mouse wasn't pressed
		in al, 64h ; read keyboard status port
		cmp al, 10b ; data in buffer?
		je DrawLine
		in al, 60h ; get keyboard data
		cmp al, 1h ; is it the ESC key?
		jne DrawLine
		ESCpressed:
		mov cx, offset message
		mov ah, 9
		int 21h

	; Wait for key press to exit program
	mov ah, 00h
	int 16h
	
	; Return to text mode
	mov ah, 0
	mov al, 2
	int 10h
	
	jmp exit ; jump over the procs 
; --------------------------
	


; Procs start
; --------------------------

; Draw Pen
proc DrawPen
	mov [rectangle_x], 270
	mov [rectangle_y], 5
	mov [rectangle_width], 8
	mov [rectangle_height], 20
	call DRAWRECTANGLE
	mov [rectangle_x], 272
	mov [rectangle_y], 25
	mov [rectangle_width], 4
	mov [rectangle_height], 3
	;mov [rectangle_color], 7
	call DRAWRECTANGLE
	mov [rectangle_x], 273
	mov [rectangle_y], 28
	mov [rectangle_width], 2
	mov [rectangle_height], 3
	;mov [rectangle_color], 7
	call DRAWRECTANGLE	
	ret 
endp DrawPen

; Draw Eraser
proc DrawEraser
	mov [rectangle_x], 293
	mov [rectangle_y], 5
	mov [rectangle_width], 13
	mov [rectangle_height], 20
	;mov [rectangle_color], 7
	call DRAWRECTANGLE
	;mov [rectangle_x], 293
	mov [rectangle_y], 27
	;mov [rectangle_width], 13
	mov [rectangle_height], 3
	;mov [rectangle_color], 7
	call DRAWRECTANGLE
	ret
endp DrawEraser

; Draw rectangle
proc DrawRectangle
	rectangle_draw:
              row_number:
                      mov cx, [rectangle_width]
                      colom_number:
                              push cx
                              add cx, [rectangle_x]
                              mov dx, [rectangle_y]
                              add dx, [rectangle_height]
                              mov ax, [rectangle_color]
                              mov ah, 0Ch
                              int 10h
                              pop cx
                      loop colom_number
              dec [rectangle_height]
              cmp [rectangle_height], 0
              jg row_number
	ret
endp DRAWRECTANGLE

; print dot near mouse location
proc DrawDotNearMousePos
	cmp [crrnt_mouse_pos_x], 319
	ja dontdraw
	sub [crrnt_mouse_pos_y], 1 ; move one pixel, so the pixel will not be hidden by mouse
	; prevent too big value (dx)
	cmp [crrnt_mouse_pos_y], 200
	ja dontdraw
	; make drawing only possible on canvas 
	cmp [crrnt_mouse_pos_y], 40
	jb dontDraw
	mov bl, 0 ; reset bl (nessary to draw)
	mov ax, [line_color] 
	; drawing action
	mov ah, 0Ch
	int 10h
	dontDraw: ; jmp here if needed 
	ret
endp DrawDotNearMousePos

proc CheckColor
	; check if a color was pressed
	; colors are in 167 <= x <= 257, 10 <= y <= 30
		; check if colors are on line 1
		cmp [crrnt_mouse_pos_y], 10
		jb notline1a
		cmp [crrnt_mouse_pos_y], 30
		ja notline1a
			; if you reached here youre in line 1
			; check if black was pressed (167 <= x <= 177)
			cmp [crrnt_mouse_pos_x], 167
			jb notblack
			cmp [crrnt_mouse_pos_x], 177
			ja notblack
				; if you reached here you're black
				mov [line_color], 0
				mov [save_color], 0
			notBlack:
		
			; check if blue was pressed (178 <= x <= 188)
			cmp [crrnt_mouse_pos_x], 177
			jb notBlue
			cmp [crrnt_mouse_pos_x], 187
			ja notBlue
			; if you reached here you're blue
				mov [line_color], 1
				mov [save_color], 1
			notBlue:

			; check if green was pressed (189 <= x <= 199)
			cmp [crrnt_mouse_pos_x], 187
			jb notgreen
			cmp [crrnt_mouse_pos_x], 197
			ja notgreen
				; if you reached here you're green
				mov [line_color], 2
				mov [save_color], 2
			notgreen:
		
			; check if cyan was pressed (210 <= x <= 220)
			cmp [crrnt_mouse_pos_x], 197
			jb notcyan
			cmp [crrnt_mouse_pos_x], 207
			ja notcyan
				; if you reached here you're cyan
				mov [line_color], 3
				mov [save_color], 3
			notcyan:
		notLine1a:
		
		cmp [crrnt_mouse_pos_y], 10
		jb notline1b
		cmp [crrnt_mouse_pos_y], 30
		ja notline1b
			; check if red was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 207
			jb notred
			cmp [crrnt_mouse_pos_x], 217
			ja notred
				; if you reached here you're red
				mov [line_color], 4
				mov [save_color], 4
			notred:

			; check if magenta was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 217
			jb notmagenta
			cmp [crrnt_mouse_pos_x], 227
			ja notmagenta
				; if you reached here you're magenta
				mov [line_color], 5
				mov [save_color], 5
			notmagenta:

			; check if brown was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 227
			jb notbrown
			cmp [crrnt_mouse_pos_x], 237
			ja notbrown
				; if you reached here you're brown
				mov [line_color], 6
				mov [save_color], 6
			notbrown:

			; check if lightgray was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 237
			jb notlightgray
			cmp [crrnt_mouse_pos_x], 247
			ja notlightgray
				; if you reached here you're lightgray
				mov [line_color], 7
				mov [save_color], 7
			notlightgray:
		notline1b:

	; check if colors are on line 2
		cmp [crrnt_mouse_pos_y], 10
		jb notline2a
		cmp [crrnt_mouse_pos_y], 30
		ja notline2a
			; if you reached here youre in line 2
			; check if darkgray was pressed (167 <= x <= 177)
			cmp [crrnt_mouse_pos_x], 167
			jb notdarkgray
			cmp [crrnt_mouse_pos_x], 177
			ja notdarkgray
				; if you reached here you're darkgray
				mov [line_color], 8
				mov [save_color], 8
			notdarkgray:
		
			; check if lightblue was pressed (178 <= x <= 188)
			cmp [crrnt_mouse_pos_x], 177
			jb notlightblue
			cmp [crrnt_mouse_pos_x], 187
			ja notlightblue
			; if you reached here you're lightblue
				mov [line_color], 9
				mov [save_color], 9
			notlightblue:

			; check if lightgreen was pressed (189 <= x <= 199)
			cmp [crrnt_mouse_pos_x], 187
			jb notlightgreen
			cmp [crrnt_mouse_pos_x], 197
			ja notlightgreen
				; if you reached here you're lightgreen
				mov [line_color], 0Ah
				mov [save_color], 0Ah
			notlightgreen:
		
			; check if lightcyan was pressed (210 <= x <= 220)
			cmp [crrnt_mouse_pos_x], 197
			jb notlightcyan
			cmp [crrnt_mouse_pos_x], 207
			ja notlightcyan
				; if you reached here you're lightcyan
				mov [line_color], 0Bh
				mov [save_color], 0Bh
			notlightcyan:
		notLine2a:
		
		cmp [crrnt_mouse_pos_y], 10
		jb notline2b
		cmp [crrnt_mouse_pos_y], 30
		ja notline2b
			; check if lightred was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 207
			jb notlightred
			cmp [crrnt_mouse_pos_x], 217
			ja notlightred
				; if you reached here you're lightred
				mov [line_color], 0Ch
				mov [save_color], 0Ch
			notlightred:

			; check if lightmagenta was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 217
			jb notlightmagenta
			cmp [crrnt_mouse_pos_x], 227
			ja notlightmagenta
				; if you reached here you're lightmagenta
				mov [line_color], 0Dh
				mov [save_color], 0Dh
			notlightmagenta:

			; check if yellow was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 227
			jb notyellow
			cmp [crrnt_mouse_pos_x], 237
			ja notyellow
				; if you reached here you're yellow
				mov [line_color], 0Eh
				mov [save_color], 0Eh
			notyellow:

			; check if white was pressed (221 <= x <= 231)
			cmp [crrnt_mouse_pos_x], 237
			jb notwhite
			cmp [crrnt_mouse_pos_x], 247
			ja notwhite
				; if you reached here you're white
				mov [line_color], 0Fh
				mov [save_color], 0Fh
	   		notwhite:
		notline2b:
	ret 
endp checkcolor

proc CheckPen
	; check if pen was pressed
	; if yes then change the pen icon's color and the line color to
	; the last selected color (default black)
	; pen in on 270 <= x <= 290, 5 <= y <= 31
	cmp [crrnt_mouse_pos_x], 270
	jb notPen
	cmp [crrnt_mouse_pos_x], 290
	ja notPen
	cmp [crrnt_mouse_pos_y], 5
	jb notPen
	cmp [crrnt_mouse_pos_y], 31
	ja notPen
		; if you reached here you're a pen
		mov ax, [save_color]
		mov [line_color], ax
		mov [rectangle_color], ax
		call drawpen
	notPen:
	ret 
endp CheckPen

proc CheckEraser
	; check if eraser was pressed 
	; if yes, change it icon's color to black to indicated that it's
	; pressed and change the line color to white (the canvas' color)
	; eraser is on: 293 <= x <= 306, 5 <= y <= 31
	cmp [crrnt_mouse_pos_x], 293
	jb notEraser
	cmp [crrnt_mouse_pos_x], 306
	ja notEraser
	cmp [crrnt_mouse_pos_y], 5
	jb notEraser
	cmp [crrnt_mouse_pos_y], 31
	ja notEraser
		; if reached here you're in the erasers range
		mov [line_color], 0Fh
		mov [rectangle_color], 0
		call draweraser
	notEraser: ; jmp here if mouse is outside of the eraser icon's range
	ret
endp Checkeraser

; Procs end
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start
