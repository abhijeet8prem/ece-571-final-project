# #############################################################################################
#   crc-double-error.py : generate CRC pattern output for all 2 bits errors in 32 bit codeword
#   
#   Author          : Abhijeet Prem
#   Revisoion       : 1.0
#   Last Modified   : 9th March, 2023

#   References:
#   https://www.geeksforgeeks.org/cyclic-redundancy-check-python/ 
#   
# ###############################################################################################


input_string    = "0010010011100100"               # 16 bit message 
poly            = "10001000000100001"              # Polynomial used X^16 + X^12 + X^5 + 1

# open necessary files to writ to
crc_error_b_file = open("crc_rx_pattern_b.txt","w")
crc_error_h_file = open("crc_rx_pattern_h.txt","w")
crc_error_d_file = open("crc_rx_pattern_d.txt","w")
crc_error_case_file= open("crc_rx_pat_case.txt","w")

############### Define all the necessary functions #############

def bin_format(integer, length):
    return f'{integer:0>{length}b}'

def generate_2_bit_error_combinations(n_bits):
    error_combinations = []
    for i in range(n_bits):
        for j in range(i+1, n_bits):
            error_combinations.append((i, j))
    return error_combinations


def generate_32_bit_error_combinations():
    n_bits = 32
    error_combinations = generate_2_bit_error_combinations(n_bits)
    #print(error_combinations)
    #print ("\n\n")
    error_combinations_32_bit = []
    for i, j in error_combinations:
        error_combination = [0] * n_bits
        error_combination[i] = 1
        error_combination[j] = 1
        #print(''.join(str(x) for x in error_combination) + '\n') # creating a string 
        error_combinations_32_bit.append(error_combination)
    return error_combinations_32_bit

# defining xor gate 
def xor(a, b):
 
    # initialize result
    result = []
 
    # Traverse all bits, if bits are
    # same, then XOR is 0, else 1
    for i in range(1, len(b)):
        if a[i] == b[i]:
            result.append('0')
        else:
            result.append('1')
 
    return ''.join(result)


# Performs Modulo-2 division
def mod2div(dividend, divisor):
 
    # Number of bits to be XORed at a time.
    pick = len(divisor)
 
    # Slicing the dividend to appropriate
    # length for particular step
    tmp = dividend[0 : pick]
 
    while pick < len(dividend):
 
        if tmp[0] == '1':
 
            # replace the dividend by the result
            # of XOR and pull 1 bit down
            tmp = xor(divisor, tmp) + dividend[pick]
 
        else: # If leftmost bit is '0'
 
            # If the leftmost bit of the dividend (or the
            # part used in each step) is 0, the step cannot
            # use the regular divisor; we need to use an
            # all-0s divisor.
            tmp = xor('0'*pick, tmp) + dividend[pick]
 
        # increment pick to move further
        pick += 1
 
    # For the last n bits, we have to carry it out
    # normally as increased value of pick will cause
    # Index Out of Bounds.
    if tmp[0] == '1':
        tmp = xor(divisor, tmp)
    else:
        tmp = xor('0'*pick, tmp)
 
    checkword = tmp
    return checkword

# Function used at the sender side to encode
# data by appending remainder of modular division
# at the end of data.
# 'key' is the polynomial 
def encodeData(data, key):
    
    l_key = len(key)
 
    # Appends n-1 zeroes at end of data
    appended_data = data + '0'*(l_key-1)
    remainder = mod2div(appended_data, key)
 
    # Append remainder in the original data
    codeword = data + remainder
    return codeword


# perform calculations to generate all 498 CRC patters for 2 bit errors

# Generate all 32 bit errors
errors = generate_32_bit_error_combinations()

tx_codeword_str = encodeData(input_string, poly)
tx_crc = int(tx_codeword_str[16:],2)
tx_codeword = int(tx_codeword_str,2)


#print("All error pattern ",errors)

print("\n TX_ CRC \t: {:32b}".format(tx_crc))
print(" TX  code word \t: {:032b}" .format(tx_codeword))

# extraxting error of 1st case, can be made into a loop

i = 0
#error = int(''.join(str(x) for x in errors[i]),2)
error = 0x00000002
print(" 32 bit error\t: {:032b} ".format(error))

error_codeword = tx_codeword ^ error
error_codeword_str = bin_format(error_codeword,32)

print(" error codeword\t: {:032b} ".format(error_codeword))

rx_crc = int(mod2div(tx_codeword_str,poly),2)
print(" recived CRC\t: {:32b}".format(rx_crc))
rem1 = encodeData(error_codeword_str,poly)
rx_crc_er = int(rem1[32:],2)
print(" error CRC\t: {:016b}".format(rx_crc_er))

#print(" Error vector \t\t\t\t\t Error CRC")
#print(" {:032b}\t\t {:016b}".format(error,rx_crc_er))



# loop to calculate the rest of the patterns

l_error = len(errors)

print("\tTX_code word\t\t \t\tError vector \t\t\t\t\t Error Codeword bin\t\t Error_CW hex \t\t\tError CRC\t\tError CRC hex")


for i in range(l_error):
    error = int(''.join(str(x) for x in errors[i]),2)                                       # extracting the a error vector from the list
    error_codeword = tx_codeword ^ error                                                    # adding the error to the transimmted code word
    error_codeword_str = bin_format(error_codeword,32)
    rem = mod2div(error_codeword_str,poly)
    rem2 = encodeData(tx_codeword_str,poly)

   
    rem3 =  mod2div(error_codeword_str,poly)   
    #print("Err rem1:"+rem[32:] +" no error:"+ rem2[32:] + " Err rem2: {:016b}".format(int(rem3,2)))

    rx_crc_er = int(rem,2)                                                           # finding the CRC for the error injected code-word
    print("{:032b}\t {:032b}\t\t {:032b}\t\t{:08x}\t {:016b} \t\t{:08x}".format(tx_codeword,error, error_codeword, error_codeword,rx_crc_er,rx_crc_er))                                 # uncommet to display on terminal
    crc_error_b_file.write(" {:032b}\t {:016b}\n".format(error,rx_crc_er))                # writing to file, values in binary
    crc_error_h_file.write(" {:08x}\t {:08x}\n".format(error,rx_crc_er))                  # writing to file, values in hex
    crc_error_d_file.write(" {:d}\t {:d}\n".format(error,rx_crc_er))                      # writing to file, values in decimal
    #crc_error_case_file.write(" 16'b{:016b}\t:\t CorVec = 32'h{:08x}\n".format(rx_crc_er,error)) 
    crc_error_case_file.write("{:08x}\t{:016b}\n".format(error, rx_crc_er))                     # writing to file, values in decimal