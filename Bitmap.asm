# This program uses this Bitmap Display to change the background color of the display and draw vertical and horizontal lines.
# Runs from MARS IDE.

.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

.macro getCoordinates(%input %x %y)
	srl %x %input 16
	sll %y %input 16
	srl %y %y 16
.end_macro

.macro formatCoordinates(%output %x %y)
	sll %x %x 16
	or %output %x %y
.end_macro 

.macro getPixelAddress(%output %x %y)
	sll %output %y 7 
	add %output %output %x
	sll %output %output 2
	addi %output %output 0xffff0000
.end_macro


.text
# prevent this file from being run as main
li $v0 10 
syscall

#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# REGISTER USAGE
# $t6 = 128
# $t0 = representing row
# $t1 = has color value
# $t2 = representing col
# $t3 = for temporary usage
# $t4 = for temporary usage
# $t5 = for temporary usage
clear_bitmap: nop
	push($ra)
	li $t6 128
	li $t0 0
	add $t1 $0 $a0
	forloop1:
	li $t2 0
	forloop2:
	add $t3 $0 $t0
	add $t4 $0 $t2
	formatCoordinates($t5, $t3, $t4)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	push($t5)
	push($t6)
	add $a0 $0 $t5
	add $a1 $0 $t1
	jal draw_pixel
	pop($t6)
	pop($t5)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	addi $t2 $t2 1
	bne $t2 $t6 forloop2
	addi $t0 $t0 1
	bne $t0 $t6 forloop1
	pop($ra)
 	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
# REGISTER USAGE
# $t0 = as x
# $t1 = as y
# $t2 = hold pixel address
draw_pixel: nop
	getCoordinates($a0, $t0, $t1)
	getPixelAddress($t2, $t0, $t1)
	sw $a1 ($t2)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
# REGISTER USAGE
# $t0 = as x
# $t1 = as y
# $t2 = hold pixel address
get_pixel: nop
	getCoordinates($a0, $t0, $t1)
	getPixelAddress($t2, $t0, $t1)
	lw $v0 ($t2)
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# REGISTER USAGE
# $t2 = 128
# $t0 = y-coordinate
# $t1 = representing col
# $t3 = for temporary usage
# $t4 = for temporary usage
draw_horizontal_line: nop
	push($ra)
	add $t0 $0 $a0
	li $t1 0
	li $t2 128
loop:
	add $t3 $0 $t1
	formatCoordinates($t4, $t3, $t0)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	add $a0 $0 $t4
	jal draw_pixel
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	addi $t1 $t1 1
	bne $t1 $t2 loop	
	pop($ra)
 	jr $ra

#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# REGISTER USAGE
# $t2 = 128
# $t0 = x-coordinate
# $t1 = representing row
# $t3 = for temporary usage
# $t4 = for temporary usage
draw_vertical_line: nop
	push($ra)
	add $t0 $0 $a0
	li $t1 0
	li $t2 128
loop1:
	add $t3 $0 $t1
	add $t4 $0 $t0
	formatCoordinates($t5, $t4, $t3)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	push($t5)
	add $a0 $0 $t5
	jal draw_pixel
	pop($t5)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	addi $t1 $t1 1
	bne $t1 $t2 loop1	
	pop($ra)
 	jr $ra
#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# REGISTER USAGE
# $t0 = holding x and y
# $t1 = color
# $t2 = for temporary usage
# $t3 = for temporary usage
# $t4 = for temporary usage
# $t5 = for temporary usage
# $t6 = holding the cross pixel address
# $t7 = holding cross color
draw_crosshair: nop
	push($ra)

	add $t0 $0 $a0  
	add $t1 $0 $a1
	getCoordinates($a0 $t2 $t3)
	getPixelAddress($t6 $t2 $t3)
	lw $t7 ($t6) 
	
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	push($t5)
	push($t6)
	push($t7)
	li $a0 0x00000040
	add $a1 $0 $t1
	jal draw_horizontal_line
	pop($t7)
	pop($t6)
	pop($t5)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	push($t5)
	push($t6)
	push($t7)
	li $a0 0x00000050
	add $a1 $0 $t1
	jal draw_vertical_line
	pop($t7)
	pop($t6)
	pop($t5)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	sw $t7 ($t6)
	pop($ra)
	jr $ra
