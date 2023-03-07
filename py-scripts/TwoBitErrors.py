# writen using the help of chat GPT

def generate_2_bit_error_combinations(n_bits):
    error_combinations = []
    for i in range(n_bits):
        for j in range(i+1, n_bits):
            error_combinations.append((i, j))
    return error_combinations

def generate_32_bit_error_combinations():
    n_bits = 32
    error_combinations = generate_2_bit_error_combinations(n_bits)
    error_combinations_32_bit = []
    for i, j in error_combinations:
        error_combination = [0] * n_bits
        error_combination[i] = 1
        error_combination[j] = 1
        error_combinations_32_bit.append(error_combination)
    return error_combinations_32_bit

print(generate_32_bit_error_combinations())
