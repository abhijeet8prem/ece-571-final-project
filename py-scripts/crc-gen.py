def crc_remainder(input_string, poly):
    # Append zeros to the input string to make room for the CRC remainder
    input_string += "0" * (len(poly) )
    
    # Convert the input string and polynomial to binary integers
    input_int = int(input_string, 2)
    poly_int = int(poly, 2)
    
    # Calculate the CRC remainder using polynomial division
    for i in range(len(input_string)):
        if input_int >> (len(input_string) - i - 1) & 1:
            input_int ^= poly_int << (len(input_string) - i - len(poly))
    
    # Convert the CRC remainder to a binary string
    crc = bin(input_int)[2:]
    
    # Pad the CRC remainder with leading zeros if necessary
    crc = "0" * (len(poly) - len(crc)) + crc
    
    return crc


# Test the function
input_string = "1101011011101001"
poly = "1000100000010001"
crc = crc_remainder(input_string, poly)
print(crc)
