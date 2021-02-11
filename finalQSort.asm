.data
	array: .word 45,53,48,10,89,4,3,10,8,99,111
.text
	main:
		add $a1,$a0,40						        #send h (numper of elements )
		add $a0,$a0,0							#send l
		jal quickSort
		li $v0, 10
		syscall
		
	
	partitation:
		addi $sp, $sp, -4						#make room for a place in stack to store the return address
		sw $ra, 0($sp)              					#saving return address
		addi $t1, $s3, 0						#get t1(i)
		addi $t2, $s4, 0          					#get t2 (j)
		
		lw $t3, array($t1)						#pivot = arr[t1]	
		while:								#while loop
			bge $t1,$t2,exit					#i < j 
			loop1:
				addi $t1, $t1, 4				#increasing i first because we use do while in c
    				lw $t4, array($t1)				#load arr[i]				
				bge $t3, $t4, loop1				#while(arr[i]<=pivot) repeat
			loop2:	
				addi $t2, $t2, -4				#decreasing j first because we use do while in c
				lw $t5, array($t2)				#load arr[j]
				bgt $t5, $t3, loop2				#while (arr[j]>pivot) repeat
			
			ifcon:
				bge $t1, $t2, dontswap				#if(i=>j) it willnt swap
				lw $t0,array($t1)				#load arr [i]
				lw $t6,array($t2)				#load arr[j]
				sw $t0,array($t2)				#swap arr[i]
				sw $t6,array($t1)				#swap arr[j]
			dontswap:													
		j while
		exit:								#that rest of code after the while
			lw $t0,array($s3)					#load arr[l]
			lw $t7,array($t2)					#load arr[j]
			sw $t0,array($t2)					#swap arr[j]
			sw $t7,array($s3)					#swap arr[l]			
			lw $ra, 0($sp)						#load return address
			addi $sp, $sp, 4					#restore the stack
			addi $v1, $t2,0 					#return v1 to quicksort(j)
			jr $ra
		
	quickSort:
		addi $sp, $sp, -16						#make room for 4 places in stack
		sw $a0, 0($sp)							#store low
		sw $a1, 4($sp)							#store high
		sw $ra, 8($sp)							#store return address
		
		lw $s3,0($sp)							#loading low to send it to partition
		lw $s4,4($sp)							#loading high to send it to partition
		bge $s3,$s4,endif						#if(l[s3]<h[s4]) 		
		jal partitation							#call partition
		sw $v1, 12($sp)							#store j
		move $a1, $v1							#getting pivot index from partition and move it to a1[the sec arg sent to quick sort]	
		jal quickSort							#call quicksort
		lw $a0, 12($sp) 						#putting j to send it as low to the next quicksort
		addi $a0, $a0, 4						#increasing j (j++)
		lw $a1, 4($sp)							#load high to send it again as high
		jal quickSort							#call quicksort
		
	endif:
 		lw $ra, 8($sp)							#restore return address
 		addi $sp, $sp, 16						#restore the stack
 		jr $ra	
