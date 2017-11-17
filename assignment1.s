.data
invalid_error:  .asciiz "\nInvalid character in input!\n"
str:
  #declares space for 8 byte array
  .space 9
error: .asciiz "Invalid hexadecimal number"
newline: .asciiz "\n"


.text

main:     #needed so it runs in QTSPIM

  #loads string array into the address
  li $v0, 8
  la $a0, str
  li $a1, 9
  syscall

  la $a0, newline
  li $v0, 4
  syscall
  
  
  add $s0, $0, $zero                          #s0 -- location to save a character
  la $s1, str                                 #$s1 -- base address of string
  add $s2, $0, $zero                          #$s2 -- grand sum for hex
  add $s3, $0, $zero            #s3 -- character length of string
  

length_of_array:    

  lb $s0, 0($s1)  #loads next byte
  beq $s0, 10, exit_counter_loop  
  beq $s0, 0, exit_counter_loop #exits if reading end of string (newline(pressed enter) or null (8characters0))
   add $s1, $s1, 1  #adds to local address by 1 byte 
    beq $s0, 32, length_of_array #case of reading a space, continueloop, increment byte but NOT COUNTER
  add $s3, $s3, 1 #incrmeents counter if reading actual character
   
  j length_of_array

exit_counter_loop:
  # on exit of counter function, reinitialize values
    
  add $s0, $0, $zero                          #s0 -- location to save a character
  la $s1, str                                 #$s1 -- base address of string
  add $s2, $0, $zero                          #$s2 -- grand sum for hex
   #s3 -- character length of string
   
       #algoritm for shifting the hex digits
       # if you have a hex number of length n (Ex. 3 chars)
       #      AAA
       #  1: 1010
       #  1: 1010 
       #  1: 1010
  # the binary equivalent is 1010 1010 1010
  # For length 3, the first character is shifted by (3 - 1 * 4) = 8 bits
  #     the second character is shifted (2 -1  * 4) = 4 bits
  #so in general for length n, you shift N -1 * 4 bits for the first hex digit and then subtract 1 from N (or 4 from shift bits amount)
  
  li $t0, 4
  sub $s3, $s3, 1 #subtracting 1 from length as per above
  mult $t0, $s3  # N - 1 * 4
  mflo $s4      # this is the base shift amount for N chars (ex. if 3 then this is 8 as per above)


  
  
  
      
loop: 
  lb $s0, 0($s1)    #loads next byte
  #checks for end of the input
  beq $s0, 10, exit
  beq $s0, 0, exit
   #increment to next byte
  add $s1, $s1, 1
 
  beq $s0, 32, loop   #case of space, continue loop after incrementing byte
  
  #if the decimal is less than 48, 
  #it is invalid
  blt $s0, 48, invalid
  #48=58 is the range for numbers
  blt $s0, 58, check_numbers
  #58-65 are invalid characters for hexadecimal
  blt $s0, 65, invalid
  #65-71 is the the range for A-F
  blt $s0, 71, check_uppercase
  #71-97 is an invalid range for hexadecimal
  blt $s0, 97, invalid
  #97-103 is the range for a-f
  blt $s0, 103, check_lowercase
  #any decimal over 103 is invalid for hexadecimal
  bgt $s0, 103, invalid
  #jumps to loop again
  j loop
  
check_uppercase:
  subu $s0, $s0, 55
  #translation of A - F
  #add it to a sum
  
  sllv $s0, $s0, $s4  #shifts the decimal number 
  addu $s2, $s2, $s0    #adds to sum
  
  subu $s4, $s4, 4  #decrements shift amount

  #jump to the loop
  j loop
check_lowercase:
  #calculates the hex value of the characters
  subu $s0, $s0, 87
  
  sllv $s0, $s0, $s4  #shifts the decimal number 
  addu $s2, $s2, $s0    #adds to sum
  
  subu $s4, $s4, 4  #decrements shift amount
  
  #jump to the loop
  j loop
check_numbers:
  #if in the range, calculate hex value
  subu $s0, $s0, 48
  #add the hex value to the sum
  sllv $s0, $s0, $s4  #shifts the decimal number 
  addu $s2, $s2, $s0    #adds to sum
  
  subu $s4, $s4, 4  #decrements shift amount

  #jump to the loop
  j loop
invalid:
  li $v0, 4   #system call for outputting strings
  la $a0, error #outputs error message
  syscall
  #ends program
  li $v0, 10
  syscall
  
exit:
  
  #check if number is 8 digits (case of 2s complement where first bit is 1!)
  #already subtracted 1 from it sooooo check if its 7 instead
  bgt $s3, 6, TwosComplement
  
  
  
  #outputs sum
  li $v0, 1
  add $a0, $s2, $0
  syscall 
  
  
  #ends program
  li $v0, 10
  syscall


TwosComplement:
  li $t0, 10000 #prints unsigned version of 2s complement by dividing  sum by 10000 and printing quotient remainder together
  divu $s2, $t0
  mflo $t1
  mfhi $t2

  add $a0, $t1, $zero
  li $v0, 1
  syscall
  

  add $a0, $t2, $zero
  li $v0, 1
  syscall         
  
  
 
        li $v0,10 #end program
        syscall