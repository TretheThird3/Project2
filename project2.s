.section .data
    output: .ascii "The double is: "
    output_len: .long 16 

.section .bss
    .lcomm input_buffer, 16    # buffer to store input
    .lcomm output_buffer, 16   

.section .text
    .globl _start

_start:
    # Read input from stdin into input_buffer
    movl $3, %eax           # sys_read
    movl $0, %ebx           # stdin
    movl $input_buffer, %ecx 
    movl $16, %edx          # max bytes to read
    int $0x80

    # Setup for the loop
    movl $0, %eax           # Clear eax (this will hold the doubled number)
    movl $input_buffer, %esi # Point esi to the start of the user input

convert_loop:
    movb (%esi), %bl        # Load the next byte into bl
    
    # Check for end of input 
    cmpb $10, %bl           # Is it a newline 
    je end_convert
    cmpb $0, %bl            # Is it null
    je end_convert

    # Convert ASCII to integer
    subb $48, %bl           # Subtract 48 ('0') to get raw digit
    
    # Multiply current total by 10
    # (EAX = EAX * 10)
    imull $10, %eax         
    
    # Add the new digit to the total
    # (Use ebx because the digit is in bl; zero out the rest of ebx first)
    movzbl %bl, %ebx        # Move bl to ebx and fill high bits with zero
    addl %ebx, %eax         

    incl %esi               # Move to the next character in the buffer
    jmp convert_loop

end_convert:
    # At this point, %eax contains the integer. 
    # double it by adding it to itself (eax = eax + eax)
    addl %eax, %eax

movl $output_buffer, %edi
    addl $15, %edi          # Move pointer to the end of the 16-byte buffer
    movb $0, (%edi)         # Null-terminate the string
    decl %edi               # Move back one spot for the first digit

    movl $10, %ebx          # divide by 10

reverse_convert_loop:
    movl $0, %edx           # Clear edx (required for 32-bit division)
    divl %ebx               # Divide EAX by 10. eax = Quotient, edx = Remainder

    addb $48, %dl           # Convert Remainder to ASCII
    movb %dl, (%edi)        # Store the ASCII character in the buffer
    
    cmpl $0, %eax           # Is the quotient 0?
    je end_reverse_loop     # If yes, loop done
    
    decl %edi               # Move the buffer pointer back one spot
    jmp reverse_convert_loop

end_reverse_loop:
    # %edi now points to the START of your numeric string
    # You can now use sys_write to print from the address in %edi
  
    movl $4, %eax           # sys_write
    movl $1, %ebx           # stdout
    movl $output, %ecx      # address of "The double is: "
    movl output_len, %edx   # length of the string
    int $0x80



    movl $output_buffer, %edx
    addl $15, %edx          # Points to the end of the buffer
    subl %edi, %edx         # EDX = length of the numeric string

    movl $4, %eax           # sys_write
    movl $1, %ebx           # stdout
    movl %edi, %ecx         # Use EDI (it points to the first digit)
    int $0x80


    movl $1, %eax           # sys_exit
    movl $0, %ebx           # return 0 
    int $0x80
