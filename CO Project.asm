.data
    myarray:.space 40  
    st:.asciiz "Enter the 10 Elements \n"
	choose: .asciiz "\n1: for insertion sort\n2: for Merge Sort\n3: for Search (Binary Search)\n4: to Exit.\n"
	chooseNum: .asciiz "Choose a number:\n"
	warning: .asciiz "!!!! You Should Sort the array first!!!!\n"
	newLine: .asciiz "\n"
	foundItem: .asciiz "Item Found In Index: "
	notFound: .asciiz "Item not Found\n"
	length: .word 10
.text
    li $v0,4
    la $a0,st
    syscall
    jal scanArray
    #li $v0, 0
    la $t1, myarray				# Load the start address of the array
    lw $a1, length				# size of the array
    j MainWhile
    
 
 		########################## START SCAN ARRAY ##########################
scanArray:  
	add $t0,$zero,0					# initialize i = 0
	loopScan:		
	beq  $t0,40,exitScan				# if $t0 == 40 exit otherwise continue
    li $v0,5						# to read an item
    syscall							
    sw $v0,myarray($t0)				# store the item into array
    addi $t0, $t0, 4				# add 4 into i to access the next element in the array
    j loopScan						# loop again until $t0 equal to 40
    
    exitScan:
    	jr $ra
    	########################## END SCAN ARRAY ##########################
    
    
    
    	########################## START MAIN WHILE LOOP ##########################
    MainWhile:
    # for choose between sorting and searching
    li $v0, 4
    la, $a0, choose
    syscall
    
    li $v0,5						# to read an item $a3
    syscall
    move $a3, $v0
    
    # for choosing between sorts and search
    beq $a3, 1, i
    beq $a3, 2, helpMergeSort
 	beq $a3, 3, checkArray   
 	beq $a3, 4, exitProgram
 	
 	########################## END MAIN WHILE LOOP ##########################
 	
 	
 	########################## START MERGE SORT ##########################
 	 	
 	helpMergeSort:
 		la $a0, myarray				# Load the start address of the array
 		lw $t0, length				# Load the array length
 		sll $t0, $t0, 2
 		add $a1, $a0, $t0			# Calculate the array end address
 		jal	mergesort				# Call the merge sort function
 		jal printArray
 		j MainWhile
 		
	mergesort:

		addi	$sp, $sp, -16		# Adjust stack pointer
		sw	$ra, 0($sp)		# Store the return address on the stack
		sw	$a0, 4($sp)		# Store the array start address on the stack
		sw	$a1, 8($sp)		# Store the array end address on the stack
	
		sub 	$t0, $a1, $a0		# Calculate the difference between the start and end address (i.e. number of elements * 4)

		ble	$t0, 4, mergesortend	# If the array only contains a single element, just return
	
		srl	$t0, $t0, 3		# Divide the array size by 8 to half the number of elements (shift right 3 bits)
		sll	$t0, $t0, 2		# Multiple that number by 4 to get half of the array size (shift left 2 bits)
		add	$a1, $a0, $t0		# Calculate the midpoint address of the array
		sw	$a1, 12($sp)		# Store the array midpoint address on the stack
	
		jal	mergesort		# Call recursively on the first half of the array
	
		lw	$a0, 12($sp)		# Load the midpoint address of the array from the stack
		lw	$a1, 8($sp)		# Load the end address of the array from the stack
	
		jal	mergesort		# Call recursively on the second half of the array
	
		lw	$a0, 4($sp)		# Load the array start address from the stack
		lw	$a1, 12($sp)		# Load the array midpoint address from the stack
		lw	$a2, 8($sp)		# Load the array end address from the stack
	
		jal	merge			# Merge the two array halves
	
	mergesortend:				

		lw	$ra, 0($sp)		# Load the return address from the stack
		addi	$sp, $sp, 16		# Adjust the stack pointer
		jr	$ra			# Return 
	

#
# @param $a0 First address of first array
# @param $a1 First address of second array
# @param $a2 Last address of second array
##
	merge:
		addi	$sp, $sp, -16		# Adjust the stack pointer
		sw	$ra, 0($sp)		# Store the return address on the stack
		sw	$a0, 4($sp)		# Store the start address on the stack
		sw	$a1, 8($sp)		# Store the midpoint address on the stack
		sw	$a2, 12($sp)		# Store the end address on the stack
	
		move	$s0, $a0		# Create a working copy of the first half address
		move	$s1, $a1		# Create a working copy of the second half address
	
	mergeloop:

		lw	$t0, 0($s0)		# Load the first half position pointer
		lw	$t4, 0($s1)		# Load the second half position pointer
	
	
		bgt	$t4, $t0, noshift	# If the lower value is already first, don't shift
	
		move	$a0, $s1		# Load the argument for the element to move
		move	$a1, $s0		# Load the argument for the address to move it to
		jal	shift			# Shift the element to the new position 
	
		addi	$s1, $s1, 4		# Increment the second half index
	noshift:
		addi	$s0, $s0, 4		# Increment the first half index
	
		lw	$a2, 12($sp)		# Reload the end address
		bge	$s0, $a2, mergeloopend	# End the loop when both halves are empty
		bge	$s1, $a2, mergeloopend	# End the loop when both halves are empty
		b	mergeloop
	
	mergeloopend:
	
		lw	$ra, 0($sp)		# Load the return address
		addi	$sp, $sp, 16		# Adjust the stack pointer
		jr 	$ra			# Return

##
# Shift an array element to another position, at a lower address
#
# @param $a0 address of element to shift
# @param $a1 destination address of element
##
	shift:
		li	$t0, 10
		ble	$a0, $a1, shiftend	# If we are at the location, stop shifting
		addi	$t6, $a0, -4		# Find the previous address in the array
		lw	$t7, 0($a0)		# Get the current pointer
		lw	$t8, 0($t6)		# Get the previous pointer
		sw	$t7, 0($t6)		# Save the current pointer to the previous address
		sw	$t8, 0($a0)		# Save the previous pointer to the current address
		move	$a0, $t6		# Shift the current position back
		b 	shift			# Loop again
	shiftend:
		jr	$ra			# Return

 	########################## END MERGE SORT ##########################
 	 	 	
 	 	 	 	 	 	 	 	 	 	



	########################## START INSERTION SORT ##########################
	

	i:
    	jal insertionSort
    	jal printArray
    	j MainWhile


insertionSort:
	addi $t0, $zero, 1  				# $t0 = 0 + 1 => i = 1
	OuterLoop: slt $t3, $t0, $a1		# set $t3 = 1 if $t0(i) < $a1(size of array) , 0 otherwise
	beq $t3, $0, exit					# if $t3 == 0 go to exit
	sll $t4, $t0, 2						# $t4 = i * 4
	add $t4, $t4, $t1					# base + offset
	lw $t2, 0($t4)						# $t2(key) = arr[i]
	addi $t9, $t0, -1					# $t1(j) = i - 1
	InnerLoop: slt $t4, $t9, $0			# set $t5 = 1 if $t1 < 0 
	bne $t4, $0, ExitWhileLoop   		# if $t4 != 0 exit inner while loop
	sll $t4, $t9, 2						# j * 4
	add $t4, $t4, $t1					# base + offset
	lw $t4, 0($t4)
	slt $t6, $t2, $t4					# set $t6 = 1 if $t2 < $t4   ==>  key < arr[j]
	beq $t6, $0, ExitWhileLoop			# if $t6 == 0 exit inner while loop 
	addi $t6, $t9, 1					# increment j by one and store it in $t6
	sll $t6, $t6, 2						# (j+1) * 4
	add $t6, $t6, $t1					# base + offset
	sw $t4, 0($t6)						# store the value of $t4 into $t6    ===> arr[j+1] = arr[j]
	addi $t9, $t9, -1 					# j--
	j InnerLoop
	ExitWhileLoop:
	addi $t9, $t9, 1					# increment j by one 
	sll $t7, $t9, 2						# j * 4
	add $t7, $t7, $t1					# base + offset
	sw $t2, 0($t7)
	
	addi $t0, $t0, 1					# incrment i by one		
	j OuterLoop							# loop again
				
exit:
    jr $ra
    
    
    ########################## END INSERTION SORT ##########################
    
    
    
    ########################## START BINARY SEARCH ##########################
    
    	
    
checkArray:
    	jal isArraySorted
    	addi $t0, $v1, 0
    	beq $t0, 1, bin
    	li $v0,4
    	la $a0,warning
    	syscall
    	jal printArray
    	j MainWhile
    	
    bin:
    	li $v0,4
    	la $a0,chooseNum
    	syscall
    	
    	
    	li $v0, 5
		syscall
		
		move $a2, $v0
    	jal binarySearch
    	addi $t0, $v1, 0
    	
    	beq $t0, -1, notFoundItem
    	
    		
    	li $v0,4
    	la $a0,foundItem
    	syscall
    	
    	
		li $v0, 1
		move $a0, $t0
		syscall
		li $v0,4
    	la $a0,newLine
    	syscall
		jal printArray
		j MainWhile
		
	notFoundItem:
    	li $v0,4
	    la $a0,notFound
    	syscall
    	jal printArray
    	j MainWhile
    	

#$t7 = Left , $t2 = Right, $t3 = Mid 
binarySearch:
	
	addi $t7, $zero, 0 # left =0
	subi $t2, $a1, 1	# right = size -1	
	while:
		sle $t0, $t7, $t2				# set $t0 = 1 if $t7 <= $a1
		beq $t0, $0, ExitWhile
		add $t4, $t7, $t2		# left + right
		div $t3, $t4, 2
		sll $t5, $t3, 2				# mid * 4 
		add $t4, $t5, $t1			# base + offset
		lw	$t5, 0($t4)				# $t5 = arr[mid]
		beq $t5, $a2, return
		
		
		
		
		slt $t6, $t5, $a2
		
		beq $t6, $0, else
		
		add $t7, $t3, 1
		j while
		else:
		subi $t2, $t3, 1
		j while 
		ExitWhile:
		add $v1, $zero, -1		# return -1 if the number not found
		jr $ra
		
		
return:
	add $v1, $t3, 0				# return the index of the key searched for
    jr  $ra




# size $a1 				array $t1
isArraySorted:
	la $t1, myarray
	lw $a1, length
	addi $t6, $zero, 1				# a = 1
	addi $t2, $zero, 0				# i = 0
	subi $t3, $a1, 1				# $t3 = size - 1
	whileLoop: 
	bne $t6, 1, ExitWhilee		
	
	slt $t4, $t2, $t3				# set $t4 = 1 if i < size - 1
	beq $t4, 0, ExitWhilee
	
	sll $t4, $t2, 2					# i * 4
	add $t4, $t4, $t1				# base + offset
	lw $t4, 0($t4)					# arr[i]
	
	addi $t5, $t2, 1				# i + 1
	sll $t5, $t5, 2					# (i + 1) * 4
	add $t5, $t5, $t1				# base + offset
	lw $t5, 0($t5)					# arr[i+1]
	
	bgt  $t4, $t5, ifStatement		# if arr[i] > arr[i+1] go to if statement
	
	
	# if arr[i] not greater than arr[i+1]	
	addi $t2, $t2, 1				# i++
	j whileLoop
	
	ifStatement:
		add $t6, $zero, 0			# make a = 0
		
	ExitWhilee:
		beq $t6, 1, returnFromLoop
		
	
	returnFromLoop:
		add $v1, $t6, 0				# return 1 if array is sorted
    	jr  $ra
    	
    	
    	
    	
		########################## END BINARY SEARCH ##########################
		
		
		
		
		########################## START PRINT ARRAY ##########################
		
printArray:
	lw $a1, length
	addi $t0, $zero, 0				# i = 0
	loop: slt $t3, $t0, $a1			# set $t3 = 1 if $t0 < $a1   => i < n
	beq $t3, 0, exit
	sll $t4, $t0, 2					# i * 4
	add $t4, $t4, $t1				# base + offset
	lw $t4, 0($t4)					# arr[i]
	li $v0, 1						# to print an integer
	move $a0, $t4					# move $t4, to $a0 to print it
	syscall
	
	# To print a empty character
	li $a0, 32					
    li $v0, 11  				
    syscall
	
	add $t0, $t0, 1
	j loop

		########################## END PRINT ARRAY ##########################
		
		
		
	########################## !!!END THE PROGRAM!!! ##########################
exitProgram:
    li $v0,10
    syscall
	########################## !!!END THE PROGRAM!!! ##########################
