.data
invalid_error:  .asciiz "\nInvalid character in input!\n"
str:
  #declares space for 8 byte array
  .space 8
branch_error48: .asciiz "\nLess-than 48 character found \n"
branch_error65: .asciiz "\nLess-than 65 character found \n"
branch_error97: .asciiz "\nLess-than 97 character found \n"
branch_error103: .asciiz "\nGreater-than 103 character found \n"
random_string: .asciiz "\nHello World!\n"
.text
  #loads string array into the address
  li $v0, 8
  la $a0, str
  li $a1, 9
  syscall

  
  
  add $t0, $0, $zero                          #t0 - buffer for space in array that is used
  lb $t1, 0($a0)                              #$t1 - holds elements of the array
  add $t2, $0, $zero                          #$t2 - grand sum for hex
  add $t3, $0, $zero                          #$t3 - iteration variable to handle num of iterations
  addi $t4, $zero, 28                         #$t4 - variable for num of places to shift by
  addi $t5, $zero, 16           #$t5 - variable for powers of 16
  add $t6, $zero, $t1                         #$t6 - copy of array to find length of array
  addi $t7, $zero, 0                          #$t7 - length of array copy
  addi $t8, $zero, 0                          #$t8 - handles the number of times the counting loop iterates
  addi $t9, $zero, 4                          #$t9 - byte constant; multiplied by the length to find the num places
                                              #       needed to shift by
  addi $s0, $zero, 0            # product of the integer multiplication to find power
  addi $s1, $zero, 0            # sum for the final product
length_of_array:
  #increments length of array by 1,
  #moves to next element in the array,
  #increments counter 
  add $t7, $t7, 1
  add $t6, $t6, 1
  add $t8, $t8, 1
  
  #prints the character
  li $v0, 1
  la $a0, ($t7)
  syscall
  # newline characters signify the end of the string, so move on
  # null characters are invalid, and will end the program
  # continues length loop if there are still more characters left
  beq $t6, '\n', calculate
  beq $t6, '\0', invalid
  bne $t8, 7, length_of_array
  b calculate

calculate: 
  # multiplies number of characters by 4
  # moves product from hi order bytes
  multu $t8, $t9
  mflo $t4
  
  #prints shift num
  #li $v0, 4
  #la $a1, ($t4)
  #syscall
loop:
  #checks for end of the input
  beq $t1, 10, exit
  beq $t1, 0, exit
  #if the decimal is less than 48, 
  #it is invalid
  blt $t1, 48, branch48
  #48=58 is the range for numbers
  blt $t1, 58, check_numbers
  #58-65 are invalid characters for hexadecimal
  blt $t1, 65, branch65
  #65-71 is the the range for A-F
  blt $t1, 71, check_uppercase
  #71-97 is an invalid range for hexadecimal
  blt $t1, 97, branch97
  #97-103 is the range for a-f
  blt $t1, 103, check_lowercase
  #any decimal over 103 is invalid for hexadecimal
  bgt $t1, 103, branch103
  #jumps to loop again
  j loop
check_uppercase:
  subu $t1, $t1, 55
  #translation of A - F
  #add it to a sum
  addu $t2, $t2, $t1
  #shift sum to the left by x
  sllv $t2, $t2, $t4
  #decrement shift by 4
  subu $t4, $t4, 4
  #increment to next byte
  add $t1, $a0, 1
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
  add $t1, $a0, 1
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
  addi $t1, $a0, 1
  #jumps to loop
  j loop
check_ending:
  #checks for the endline or null character
  beq $t1, 0, exit
  beq $t1, 10, exit
compute_power:
#TODO - $t9 needs to become length -1 to make true exponent
  multu $t5, $t5
  mflo $s0              #finds the correct number to multiply by the number
  addu $s1, $s0, 0
  subu $t9, $t9, 1
  bne $t9, 0, compute_power
invalid:
  li $v0, 4   #system call for outputting strings
  la $a0, invalid_error #outputs error message
  syscall
  #ends program
  li $v0, 10
  syscall
branch48:
  li $v0, 4   #system call for outputting strings
  la $a0, branch_error48  #outputs error message
  syscall
  j invalid
branch65:
  li $v0, 4   #system call for outputting strings
  la $a0, branch_error65  #outputs error message
  syscall
  j invalid
branch97:
  li $v0, 4   #system call for outputting strings
  la $a0, branch_error97  #outputs error message
  syscall
  j invalid
branch103:
  li $v0, 4   #system call for outputting strings
  la $a0, branch_error103  #outputs error message
  syscall
  j invalid
exit:
  #outputs sum
  li $v0, 1
  add $a0, $t2, $0
  syscall 
  #ends program
  li $v0, 10
  syscall