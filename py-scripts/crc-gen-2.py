#refernece https://www.geeksforgeeks.org/cyclic-redundancy-check-python/ 


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
def encodeData(data, key):
 
    l_key = len(key)
 
    # Appends n-1 zeroes at end of data
    appended_data = data + '0'*(l_key-1)
    remainder = mod2div(appended_data, key)
 
    # Append remainder in the original data
    codeword = data + remainder
    return codeword

#input_string = "0110100001101001"
input_string = "0010010011100100"
poly = "10001000000100001"              # one of the crc-16 polynomial
#poly = "1011"
crc = mod2div(input_string,poly)
codeword = encodeData(input_string, poly)
print(input_string)
print(codeword[16:])
print(codeword)
int_code = int(codeword,2)
#error = bin_format(0x00010000,32)
error = 0x00004000
print("{:032b}".format(error))
error_codeword1 = int_code ^ error
error_codeword1 = bin_format(error_codeword1,32)
print(error_codeword1)

#receiver CRC
crc_rec = mod2div(codeword,poly)
print(crc_rec)

#received error CRC
crc_rec_er = mod2div(error_codeword1,poly)
print(crc_rec_er)