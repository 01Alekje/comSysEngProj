### Text segment
		.text
start:
		la	$a0, matrix_24x24 		# a0 = A (base address of matrix)
		li	$a1, 24   		        # a1 = N (number of elements per row)
									# <debug>
		#jal 	print_matrix	    # print matrix before elimination
		#nop							# </debug>
		jal 	eliminate			# triangularize matrix!
		nop							# <debug>
		jal 	print_matrix		# print matrix after elimination
		nop							# </debug>
		jal 	exit

exit:
		li   	$v0, 10          	# specify exit system call
      	syscall						# exit program

################################################################################
# eliminate - Triangularize matrix.
#
# Args:		$a0  - base address of matrix (A)
#			$a1  - number of elements per row (N)

eliminate:
		# If necessary, create stack frame, and save return address from ra
		addiu	$sp, $sp, -4		# allocate stack frame
		sw	$ra, 0($sp)		# done saving registers

		##
		## Implement eliminate here
		li $s0, 0 # 0 = k = 0
		
		addi $s1, $s0, 1
		lui $t7, 0x3F80 # 1.0
		mtc1 $t7, $f6
		
k_loop: 
		 # s1 = j = k + 1

		#get address for A[k]
		sll $t0, $a1, 2
		sll $t1, $s0, 2
		
		multu $s0, $t0
		mflo $t0
		addu $t0, $t0, $a0 # t0 has address for A[k]

		#get A[k][k]
		addu $t1, $t1, $t0 # address of A[k][k] on t1
		lwc1 $f10, 0($t1) # f10 cointains value of A[k][k]
    		
    		div.s $f13, $f6, $f10 # f20 has inverse of A[k][k]
    		
    		
		sll $t2, $s1, 2
		
		addu $t2, $t2, $t0 # address of A[k][j] on t2
		
one_iteration:
		lwc1 $f11, 0($t2) # f11 cointains value of A[k][j]
		mul.s $f4, $f13, $f11
		addi $s1, $s1, 1
		
		swc1 $f4, 0($t2) # store new value in $t2
		blt $s1, $a1, one_iteration # end of j_loop
		addi $t2, $t2, 4
   		# store 1.0 in A[k][k]
    		swc1 $f6, 0($t1) # Value of A[k][k] set to 1.0
		
		addi $s2, $s0, 1 # prep i = k + 1
		sll $t3, $a1, 2
		sll $t9, $s0, 2
		addi $s5, $s0, 1
		
i_loop:	 # inner j = k + 1 what is this
		multu $s2, $t3
		sll $t6, $s5, 2
		mflo $s7
		move $t5, $t6
		#sll $t5, $s5, 2
		
		#multu $s2, $t3
		addu $s7, $s7, $a0 # t3 has address for A[i]
		addu $t6, $t6, $t0 # address of A[j][j] on t4
		addu $t5, $t5, $s7 # address of A[i][j] on t4
		
		#get A[i][k]
		addu $t4, $t9, $s7 # address of A[i][k] on t4
		
		 # f7 cointains value of A[i][k]
		
		sub $t8, $a1, $s5
		li $s4, 4
		ble $t8, $s4, bka
		lwc1 $f29, 0($t4)

bka2:	lwc1 $f7, 0($t6)         # A[k][j]
    		lwc1 $f12, 0($t5)        # A[i][j]
   		mul.s $f7, $f7, $f29
    		sub.s $f12, $f12, $f7
    		swc1 $f12, 0($t5)

    		lwc1 $f7, 4($t6)         # A[k][j]
    		lwc1 $f12, 4($t5)        # A[i][j]
   		mul.s $f7, $f7, $f29
   		
    		sub.s $f12, $f12, $f7
    	
    		swc1 $f12, 4($t5)
    		
    		lwc1 $f7, 8($t6)         # A[k][j]
    		lwc1 $f12, 8($t5)        # A[i][j]
   		mul.s $f7, $f7, $f29
   		addi $s5, $s5, 3
   		
    		sub.s $f12, $f12, $f7
    	
    		swc1 $f12, 8($t5)
    		
    		sub $t8, $a1, $s5
    		addi $t5, $t5, 12
    		bge $t8, $s4, bka2
    		addi $t6, $t6, 12

		         # A[k][j]
bka:		lwc1 $f7, 0($t6)
    		lwc1 $f12, 0($t5)        # A[i][j]
   		mul.s $f7, $f7, $f29
   		addi $s5, $s5, 1
    		sub.s $f12, $f12, $f7
    		addi $t6, $t6, 4
    		swc1 $f12, 0($t5)

    		#addi $s5, $s5, 1
    		#addi $t5, $t5, 4
    		
    		blt $s5, $a1, bka
    		addi $t5, $t5, 4
    		#lwc1 $f7, 0($t6)         # A[k][j]
		#addi $t6, $t6, 4
end_my_suffering:
		#sw $zero, 0($t4) # store 0.0
		
		addi $s2, $s2, 1
		addi $s5, $s0, 1

		blt $s2, $a1, i_loop # end of i_loop
		sw $zero, 0($t4) # store 0.0
		
		addi $s0, $s0, 1 # increment k
		
		blt $s0, $a1, k_loop # end of k_loop
		addi $s1, $s0, 1
		
		lw	$ra, 0($sp)			# done restoring registers
		addiu	$sp, $sp, 4			# remove stack frame

		jr	$ra				# return from subroutine
		nop					# this is the delay slot associated with all types of jumps

################################################################################
# getelem - Get address and content of matrix element A[a][b]. (Trash method)
#
# Argument registers $a0..$a3 are preserved across calls
#
# Args:		$a0  - base address of matrix (A)
#			$a1  - number of elements per row (N)
#			$a2  - row number (a)
#			$a3  - column number (b)
#						
# Returns:	$v0  - Address to A[a][b]
#			$f0  - Contents of A[a][b] (single precision)
getelem:
		addiu	$sp, $sp, -12		# allocate stack frame
		sw	$s2, 8($sp)
		sw	$s1, 4($sp)
		sw	$s0, 0($sp)		# done saving registers
		
		sll	$s2, $a1, 2		# s2 = 4*N (number of bytes per row)
		multu	$a2, $s2		# result will be 32-bit unless the matrix is huge, (will be index of wanted element)
		mflo	$s1				# s1 = a*s2 (but actually s1 = a2*s2)
		addu	$s1, $s1, $a0		# Now s1 contains address to row a
		sll	$s0, $a3, 2			# s0 = 4*b (byte offset of column b)
		addu	$v0, $s1, $s0		# Now we have address to A[a][b] in v0... (v0 = row address + offset to column)
		l.s	$f0, 0($v0)		    # ... and contents of A[a][b] in f0.
						    # ... l.s tells coprocessor 1 to load with single precision 32bit)
		lw	$s2, 8($sp)		# Load old s2
		lw	$s1, 4($sp)		# Load old s1
		lw	$s0, 0($sp)		# Load old s0, done restoring registers
		addiu	$sp, $sp, 12		# remove stack frame (i.e. go back 4 words)
		
		jr	$ra			# return from subroutine
		nop				# this is the delay slot associated with all types of jumps

################################################################################
# print_matrix
#
# This routine is for debugging purposes only. 
# Do not call this routine when timing your code!
#
# print_matrix uses floating point register $f12.
# the value of $f12 is _not_ preserved across calls.
#
# Args:		$a0  - base address of matrix (A)
#			$a1  - number of elements per row (N) 
print_matrix:
		addiu	$sp,  $sp, -20		# allocate stack frame
		sw	$ra,  16($sp)
		sw      $s2,  12($sp)
		sw	$s1,  8($sp)
		sw	$s0,  4($sp) 
		sw	$a0,  0($sp)		# done saving registers

		move	$s2,  $a0		# s2 = a0 (array pointer)
		move	$s1,  $zero		# s1 = 0  (row index)
loop_s1:
		move	$s0,  $zero		# s0 = 0  (column index)
loop_s0:
		l.s	$f12, 0($s2)        	# $f12 = A[s1][s0]
		li	$v0,  2			# specify print float system call
 		syscall					# print A[s1][s0]
		la	$a0,  spaces
		li	$v0,  4				# specify print string system call
		syscall						# print spaces

		addiu	$s2,  $s2, 4		# increment pointer by 4

		addiu	$s0,  $s0, 1        	# increment s0
		blt	$s0,  $a1, loop_s0  	# loop while s0 < a1
		nop
		la	$a0,  newline
		syscall				# print newline
		addiu	$s1,  $s1, 1		# increment s1
		blt	$s1,  $a1, loop_s1  	# loop while s1 < a1
		nop
		la	$a0,  newline
		syscall				# print newline

		lw	$ra,  16($sp)
		lw	$s2,  12($sp)
		lw	$s1,  8($sp)
		lw	$s0,  4($sp)
		lw	$a0,  0($sp)		# done restoring registers
		addiu	$sp,  $sp, 20		# remove stack frame

		jr	$ra			# return from subroutine
		nop				# this is the delay slot associated with all types of jumps

### End of text segment

### Data segment 
		.data
### String constants
spaces:
		.asciiz "   "   		# spaces to insert between numbers
newline:
		.asciiz "\n"  			# newline

## Input matrix: (4x4) ##
matrix_4x4:	
		.float 57.0
		.float 20.0
		.float 34.0
		.float 59.0
		
		.float 104.0
		.float 19.0
		.float 77.0
		.float 25.0
		
		.float 55.0
		.float 14.0
		.float 10.0
		.float 43.0
		
		.float 31.0
		.float 41.0
		.float 108.0
		.float 59.0
		
		# These make it easy to check if 
		# data outside the matrix is overwritten
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef

## Input matrix: (24x24) ##
matrix_24x24:
		.float	 92.00 
		.float	 43.00 
		.float	 86.00 
		.float	 87.00 
		.float	100.00 
		.float	 21.00 
		.float	 36.00 
		.float	 84.00 
		.float	 30.00 
		.float	 60.00 
		.float	 52.00 
		.float	 69.00 
		.float	 40.00 
		.float	 56.00 
		.float	104.00 
		.float	100.00 
		.float	 69.00 
		.float	 78.00 
		.float	 15.00 
		.float	 66.00 
		.float	  1.00 
		.float	 26.00 
		.float	 15.00 
		.float	 88.00 

		.float	 17.00 
		.float	 44.00 
		.float	 14.00 
		.float	 11.00 
		.float	109.00 
		.float	 24.00 
		.float	 56.00 
		.float	 92.00 
		.float	 67.00 
		.float	 32.00 
		.float	 70.00 
		.float	 57.00 
		.float	 54.00 
		.float	107.00 
		.float	 32.00 
		.float	 84.00 
		.float	 57.00 
		.float	 84.00 
		.float	 44.00 
		.float	 98.00 
		.float	 31.00 
		.float	 38.00 
		.float	 88.00 
		.float	101.00 

		.float	  7.00 
		.float	104.00 
		.float	 57.00 
		.float	  9.00 
		.float	 21.00 
		.float	 72.00 
		.float	 97.00 
		.float	 38.00 
		.float	  7.00 
		.float	  2.00 
		.float	 50.00 
		.float	  6.00 
		.float	 26.00 
		.float	106.00 
		.float	 99.00 
		.float	 93.00 
		.float	 29.00 
		.float	 59.00 
		.float	 41.00 
		.float	 83.00 
		.float	 56.00 
		.float	 73.00 
		.float	 58.00 
		.float	  4.00 

		.float	 48.00 
		.float	102.00 
		.float	102.00 
		.float	 79.00 
		.float	 31.00 
		.float	 81.00 
		.float	 70.00 
		.float	 38.00 
		.float	 75.00 
		.float	 18.00 
		.float	 48.00 
		.float	 96.00 
		.float	 91.00 
		.float	 36.00 
		.float	 25.00 
		.float	 98.00 
		.float	 38.00 
		.float	 75.00 
		.float	105.00 
		.float	 64.00 
		.float	 72.00 
		.float	 94.00 
		.float	 48.00 
		.float	101.00 

		.float	 43.00 
		.float	 89.00 
		.float	 75.00 
		.float	100.00 
		.float	 53.00 
		.float	 23.00 
		.float	104.00 
		.float	101.00 
		.float	 16.00 
		.float	 96.00 
		.float	 70.00 
		.float	 47.00 
		.float	 68.00 
		.float	 30.00 
		.float	 86.00 
		.float	 33.00 
		.float	 49.00 
		.float	 24.00 
		.float	 20.00 
		.float	 30.00 
		.float	 61.00 
		.float	 45.00 
		.float	 18.00 
		.float	 99.00 

		.float	 11.00 
		.float	 13.00 
		.float	 54.00 
		.float	 83.00 
		.float	108.00 
		.float	102.00 
		.float	 75.00 
		.float	 42.00 
		.float	 82.00 
		.float	 40.00 
		.float	 32.00 
		.float	 25.00 
		.float	 64.00 
		.float	 26.00 
		.float	 16.00 
		.float	 80.00 
		.float	 13.00 
		.float	 87.00 
		.float	 18.00 
		.float	 81.00 
		.float	  8.00 
		.float	104.00 
		.float	  5.00 
		.float	 57.00 

		.float	 19.00 
		.float	 26.00 
		.float	 87.00 
		.float	 80.00 
		.float	 72.00 
		.float	106.00 
		.float	 70.00 
		.float	 83.00 
		.float	 10.00 
		.float	 14.00 
		.float	 57.00 
		.float	  8.00 
		.float	  7.00 
		.float	 22.00 
		.float	 50.00 
		.float	 90.00 
		.float	 63.00 
		.float	 83.00 
		.float	  5.00 
		.float	 17.00 
		.float	109.00 
		.float	 22.00 
		.float	 97.00 
		.float	 13.00 

		.float	109.00 
		.float	  5.00 
		.float	 95.00 
		.float	  7.00 
		.float	  0.00 
		.float	101.00 
		.float	 65.00 
		.float	 19.00 
		.float	 17.00 
		.float	 43.00 
		.float	100.00 
		.float	 90.00 
		.float	 39.00 
		.float	 60.00 
		.float	 63.00 
		.float	 49.00 
		.float	 75.00 
		.float	 10.00 
		.float	 58.00 
		.float	 83.00 
		.float	 33.00 
		.float	109.00 
		.float	 63.00 
		.float	 96.00 

		.float	 82.00 
		.float	 69.00 
		.float	  3.00 
		.float	 82.00 
		.float	 91.00 
		.float	101.00 
		.float	 96.00 
		.float	 91.00 
		.float	107.00 
		.float	 81.00 
		.float	 99.00 
		.float	108.00 
		.float	 73.00 
		.float	 54.00 
		.float	 18.00 
		.float	 91.00 
		.float	 97.00 
		.float	  8.00 
		.float	 71.00 
		.float	 27.00 
		.float	 69.00 
		.float	 25.00 
		.float	 77.00 
		.float	 34.00 

		.float	 36.00 
		.float	 25.00 
		.float	  8.00 
		.float	 69.00 
		.float	 24.00 
		.float	 71.00 
		.float	 56.00 
		.float	106.00 
		.float	 30.00 
		.float	 60.00 
		.float	 79.00 
		.float	 12.00 
		.float	 51.00 
		.float	 65.00 
		.float	103.00 
		.float	 49.00 
		.float	 36.00 
		.float	 93.00 
		.float	 47.00 
		.float	  0.00 
		.float	 37.00 
		.float	 65.00 
		.float	 91.00 
		.float	 25.00 

		.float	 74.00 
		.float	 53.00 
		.float	 53.00 
		.float	 33.00 
		.float	 78.00 
		.float	 20.00 
		.float	 68.00 
		.float	  4.00 
		.float	 45.00 
		.float	 76.00 
		.float	 74.00 
		.float	 70.00 
		.float	 38.00 
		.float	 20.00 
		.float	 67.00 
		.float	 68.00 
		.float	 80.00 
		.float	 36.00 
		.float	 81.00 
		.float	 22.00 
		.float	101.00 
		.float	 75.00 
		.float	 71.00 
		.float	 28.00 

		.float	 58.00 
		.float	  9.00 
		.float	 28.00 
		.float	 96.00 
		.float	 75.00 
		.float	 10.00 
		.float	 12.00 
		.float	 39.00 
		.float	 63.00 
		.float	 65.00 
		.float	 73.00 
		.float	 31.00 
		.float	 85.00 
		.float	 31.00 
		.float	 36.00 
		.float	 20.00 
		.float	108.00 
		.float	  0.00 
		.float	 91.00 
		.float	 36.00 
		.float	 20.00 
		.float	 48.00 
		.float	105.00 
		.float	101.00 

		.float	 84.00 
		.float	 76.00 
		.float	 13.00 
		.float	 75.00 
		.float	 42.00 
		.float	 85.00 
		.float	103.00 
		.float	100.00 
		.float	 94.00 
		.float	 22.00 
		.float	 87.00 
		.float	 60.00 
		.float	 32.00 
		.float	 99.00 
		.float	100.00 
		.float	 96.00 
		.float	 54.00 
		.float	 63.00 
		.float	 17.00 
		.float	 30.00 
		.float	 95.00 
		.float	 54.00 
		.float	 51.00 
		.float	 93.00 

		.float	 54.00 
		.float	 32.00 
		.float	 19.00 
		.float	 75.00 
		.float	 80.00 
		.float	 15.00 
		.float	 66.00 
		.float	 54.00 
		.float	 92.00 
		.float	 79.00 
		.float	 19.00 
		.float	 24.00 
		.float	 54.00 
		.float	 13.00 
		.float	 15.00 
		.float	 39.00 
		.float	 35.00 
		.float	102.00 
		.float	 99.00 
		.float	 68.00 
		.float	 92.00 
		.float	 89.00 
		.float	 54.00 
		.float	 36.00 

		.float	 43.00 
		.float	 72.00 
		.float	 66.00 
		.float	 28.00 
		.float	 16.00 
		.float	  7.00 
		.float	 11.00 
		.float	 71.00 
		.float	 39.00 
		.float	 31.00 
		.float	 36.00 
		.float	 10.00 
		.float	 47.00 
		.float	102.00 
		.float	 64.00 
		.float	 29.00 
		.float	 72.00 
		.float	 83.00 
		.float	 53.00 
		.float	 17.00 
		.float	 97.00 
		.float	 68.00 
		.float	 56.00 
		.float	 22.00 

		.float	 61.00 
		.float	 46.00 
		.float	 91.00 
		.float	 43.00 
		.float	 26.00 
		.float	 35.00 
		.float	 80.00 
		.float	 70.00 
		.float	108.00 
		.float	 37.00 
		.float	 98.00 
		.float	 14.00 
		.float	 45.00 
		.float	  0.00 
		.float	 86.00 
		.float	 85.00 
		.float	 32.00 
		.float	 12.00 
		.float	 95.00 
		.float	 79.00 
		.float	  5.00 
		.float	 49.00 
		.float	108.00 
		.float	 77.00 

		.float	 23.00 
		.float	 52.00 
		.float	 95.00 
		.float	 10.00 
		.float	 10.00 
		.float	 42.00 
		.float	 33.00 
		.float	 72.00 
		.float	 89.00 
		.float	 14.00 
		.float	  5.00 
		.float	  5.00 
		.float	 50.00 
		.float	 85.00 
		.float	 76.00 
		.float	 48.00 
		.float	 13.00 
		.float	 64.00 
		.float	 63.00 
		.float	 58.00 
		.float	 65.00 
		.float	 39.00 
		.float	 33.00 
		.float	 97.00 

		.float	 52.00 
		.float	 18.00 
		.float	 67.00 
		.float	 57.00 
		.float	 68.00 
		.float	 65.00 
		.float	 25.00 
		.float	 91.00 
		.float	  7.00 
		.float	 10.00 
		.float	101.00 
		.float	 18.00 
		.float	 52.00 
		.float	 24.00 
		.float	 90.00 
		.float	 31.00 
		.float	 39.00 
		.float	 96.00 
		.float	 37.00 
		.float	 89.00 
		.float	 72.00 
		.float	  3.00 
		.float	 28.00 
		.float	 85.00 

		.float	 68.00 
		.float	 91.00 
		.float	 33.00 
		.float	 24.00 
		.float	 21.00 
		.float	 67.00 
		.float	 12.00 
		.float	 74.00 
		.float	 86.00 
		.float	 79.00 
		.float	 22.00 
		.float	 44.00 
		.float	 34.00 
		.float	 47.00 
		.float	 25.00 
		.float	 42.00 
		.float	 58.00 
		.float	 17.00 
		.float	 61.00 
		.float	  1.00 
		.float	 41.00 
		.float	 42.00 
		.float	 33.00 
		.float	 81.00 

		.float	 28.00 
		.float	 71.00 
		.float	 60.00 
		.float	101.00 
		.float	 75.00 
		.float	 89.00 
		.float	 76.00 
		.float	 34.00 
		.float	 71.00 
		.float	  0.00 
		.float	 58.00 
		.float	 92.00 
		.float	 68.00 
		.float	 70.00 
		.float	 57.00 
		.float	 44.00 
		.float	 39.00 
		.float	 79.00 
		.float	 88.00 
		.float	 74.00 
		.float	 16.00 
		.float	  3.00 
		.float	  6.00 
		.float	 75.00 

		.float	 20.00 
		.float	 68.00 
		.float	 77.00 
		.float	 62.00 
		.float	  0.00 
		.float	  0.00 
		.float	 33.00 
		.float	 28.00 
		.float	 72.00 
		.float	 94.00 
		.float	 19.00 
		.float	 37.00 
		.float	 73.00 
		.float	 96.00 
		.float	 71.00 
		.float	 34.00 
		.float	 97.00 
		.float	 20.00 
		.float	 17.00 
		.float	 55.00 
		.float	 91.00 
		.float	 74.00 
		.float	 99.00 
		.float	 21.00 

		.float	 43.00 
		.float	 77.00 
		.float	 95.00 
		.float	 60.00 
		.float	 81.00 
		.float	102.00 
		.float	 25.00 
		.float	101.00 
		.float	 60.00 
		.float	102.00 
		.float	 54.00 
		.float	 60.00 
		.float	103.00 
		.float	 87.00 
		.float	 89.00 
		.float	 65.00 
		.float	 72.00 
		.float	109.00 
		.float	102.00 
		.float	 35.00 
		.float	 96.00 
		.float	 64.00 
		.float	 70.00 
		.float	 83.00 

		.float	 85.00 
		.float	 87.00 
		.float	 28.00 
		.float	 66.00 
		.float	 51.00 
		.float	 18.00 
		.float	 87.00 
		.float	 95.00 
		.float	 96.00 
		.float	 73.00 
		.float	 45.00 
		.float	 67.00 
		.float	 65.00 
		.float	 71.00 
		.float	 59.00 
		.float	 16.00 
		.float	 63.00 
		.float	  3.00 
		.float	 77.00 
		.float	 56.00 
		.float	 91.00 
		.float	 56.00 
		.float	 12.00 
		.float	 53.00 

		.float	 56.00 
		.float	  5.00 
		.float	 89.00 
		.float	 42.00 
		.float	 70.00 
		.float	 49.00 
		.float	 15.00 
		.float	 45.00 
		.float	 27.00 
		.float	 44.00 
		.float	  1.00 
		.float	 78.00 
		.float	 63.00 
		.float	 89.00 
		.float	 64.00 
		.float	 49.00 
		.float	 52.00 
		.float	109.00 
		.float	  6.00 
		.float	  8.00 
		.float	 70.00 
		.float	 65.00 
		.float	 24.00 
		.float	 24.00 
		
matrix_6x6:	.float 6.0, 4.0, 9.0, 3.0, 8.0, 5.0
  		.float 2.0, 8.0, 7.0, 6.0, 4.0, 9.0
    		.float 5.0, 3.0, 6.0, 2.0, 7.0, 8.0
    		.float 7.0, 9.0, 2.0, 4.0, 5.0, 6.0
    		.float 3.0, 2.0, 8.0, 9.0, 6.0, 7.0
    		.float 4.0, 5.0, 3.0, 8.0, 2.0, 6.0


### End of data segment
