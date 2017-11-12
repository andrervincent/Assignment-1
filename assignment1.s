.data
str:
  #declares space for 8 byte array 
  .space 8
.text
  #syscall fo rreading in a string
  li $v0, 8
  #loads string array into the address
  la $a0, str
  li $a1, 9
  syscall
  #buffer for space in array that is used
  add $t0, $0,  $zero
  #sum for hex
  add $t2, $0, $zero
  #iteration variable to handle num of iterations
  add $t3, $0, zero
  #variable for num of places to shift by
  addi $t4, $zero, 28
loop:
  lb $t1, 0($a0)
  j check_uppercase
  j check_ending
check_uppercase:
  blt $t1, 65, check_lowercase
  bgt $t1, 70, check_lowercase
  subu $t1, $t1, 55
  
  #translation of A - F
  #add it to a sum
  addu $t2, $t2, $t1
  #shifts sum to the left
  j loop
check_lowercase:
  #checks for range of lowercase letters
  blt $t1, 97, check_numbers
  bgt $t1, 101, check_numbers
  #calculates the hex value of the characters
  subu $t1, $t1, 87
  #adds hex to the sum
  addu $t2, $t2, $t1
  #shift the hex sum to the let
  sll $t2, $t2, $t4
  #decrement shift num
  subu $t4, $t4, 4
check_numbers:
  #checks for the range 0-9
  blt $t1, 47, exit,
  bgt, $t1, 58, exit
  #if in the range, calculate the hex value
  subu $t1, $t1, 48
  #add the hex value to the sum
exit:
  li $v0, 10
  syscall
