.data
invalid_error:  .asciiz "\nInvalid character in input!\n"
str:
  #declares space for 8 byte array
  .space 8
.text
  #syscall for reading in a string
  li $v0, 8
  #loads string array into the address
  la $a0, str
  li $a1, 9
  syscall
  #buffer for space in array that is used
  add $t0, $0, $zero
  #sum for hex
  add $t2, $0, $zero
  #iteration variable to handle num of iterations
  add $t3, $0, $zero
  #variable for num of places to shift by
  addi $t4, $zero, 28
  addi $t5, $zero, 16
  lb $t1, 0($a0)      #checks first character in array
  #copy of array to find length of array
  add $t6, $zero, $t1
  #length of array
  addi $t7, $zero, 0
  addi $t8, $zero, 0
length_of_array:
  #increments length by 1
  addi $t7, $t7, 1
  #increments to next element
  addi $t6, $t6, 1
  #increment counter
  addi $t8, $t8, 1
  #for newline character move to loop
  beq $t6, 10, invalid
  #for null character 
  beq $t6, 0, invalid
  #checks for counter 
  beq $t8, 7, exit
  #jump to length loop again
  j loop
loop:
  #checks for end of the input
  beq $t1, 10, exit
  beq $t1, 0, exit
  #if the decimal is less than 48, 
  #it is invalid
  blt $t1, 48, invalid
  #48=58 is the range for numbers
  blt $t1, 58, check_numbers
  #58-65 are invalid characters for hexadecimal
  blt $t1, 65, invalid
  #65-71 is the the range for A-F
  blt $t1, 71, check_uppercase
  #71-97 is an invalid range for hexadecimal
  blt $t1, 97, invalid
  #97-103 is the range for a-f
  blt $t1, 103, check_lowercase
  #any decimal over 103 is invalid for hexadecimal
  bgt $t1, 103, invalid
  j loop
check_uppercase:
  subu $t1, $t1, 55
  #translation of A - F
  #add it to a sum
  addu $t2, $t2, $t1
  #shift sum to the left by x
  sllv $t2, $t2, $t4
  #decrement x
  subu $t4, $t4, 4
  #increment to next byte
  addi $a0, $a0, 1
  #jump to the loop
  j loop
check_lowercase:
  #calculates the hex value of the characters
  subu $t1, $t1, 87
  
  #adds the hex to the sum
  addu $t2, $t2, $t1
  #shift the hex sum to the left
  sllv $t2, $t2, $t4
  #decrement shift x
  subu $t4, $t4, 4
  #increments to next byte
  addi $a0, $a0, 1
  #jump back to the loop
  j loop
check_numbers:
  #if in the range, calculate hex value
  subu $t1, $t1, 48

  #add the hex value to the sum
  addu $t2, $t2, $t1
  #shift the hex sum to the left
  sllv $t2, $t2, $t4
  #decrement shift value
  subu $t4, $t4, 4
  #increments to the next byte
  addi $a0, $a0, 1
  #jumps to loop
  j loop
check_ending:
  #checks for the endline or null character
  beq $t1, 0, exit
  beq $t1, 10, exit
invalid:
  li $v0, 4   #system call for outputting strings
  la $a0, invalid_error #outputs error message
  syscall
  #ends program
  li $v0, 10
  syscall
exit:
  #outputs sum
  li $v0, 1
  add $a0, $t2, $0
  syscall 
  #ends program
  li $v0, 10
  syscall