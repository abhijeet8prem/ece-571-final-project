# #############################################################################################
#   gen_case.py : A golden model to generate CRC pattern output for all 1 bit and 2 bits errors 
#                 in 32 bit codeword
#   
#   Author          : Abhijeet Prem
#   Revisoion       : 1.0
#   Last Modified   : 9th March, 2023

#   References:
#   https://www.geeksforgeeks.org/cyclic-redundancy-check-python/ 
#   
# ###############################################################################################
import os

print(os.getcwd())


# open necessary files to writ to
input_file = "input-message.txt"

with open(input_file, 'r') as f:
    inputContent = f.read().strip()

codewords = open("codewords.txt","w")

############### Define all the necessary functions #############

def bin_format(integer, length):
    return f'{integer:0>{length}b}'


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

input_string    = ""                                # 16 bit message 
poly            = "10001000000100001"              # Polynomial used X^16 + X^12 + X^5 + 1


if len(inputContent) % 2 != 0:
    inputContent += ' '

for i in range(0, len(inputContent), 2):
    
    input_string = ''.join(str(bin_format(ord(c),8)) for c in inputContent[i:i+2])
    tx_codeword_str = encodeData(input_string, poly)

    print(inputContent[i:i+2] + "\t"+ ''.join(str(bin_format(ord(c),8)) for c in inputContent[i:i+2]) +"\t" + tx_codeword_str)
    codewords.write(tx_codeword_str+"\n") 