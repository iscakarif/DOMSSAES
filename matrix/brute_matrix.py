import numpy as np
import itertools

def generate_all_4x4_gf2_matrices():
    entries = [0, 1]
    
    all_combinations = itertools.product(entries, repeat=16)
    
    matrices = []
    for combination in all_combinations:
        matrix = np.array(combination).reshape(4, 4)
        matrices.append(matrix)
    
    return matrices

# Function to multiply matrices in GF(2)
def gf2_matrix_multiply(A, B):
    return (np.dot(A, B) % 2)

# Function return True if matrix is invertible
def is_invertible(matrix):
    det = int(round(np.linalg.det(matrix))) % 2
    return det == 1

# Function to calculate inverse
def gf2_inverse(matrix):
    if matrix.shape != (4, 4):
        raise ValueError("Input matrix must be 4x4.")
    
    if not np.all((matrix == 0) | (matrix == 1)):
        raise ValueError("Matrix must only contain 0s and 1s for GF(2).")
    
    identity = np.eye(4, dtype=int)
    augmented = np.concatenate((matrix, identity), axis=1)
    
    # Perform Gaussian elimination
    for i in range(4):
        if augmented[i, i] == 0:
            for j in range(i + 1, 4):
                if augmented[j, i] == 1:
                    augmented[[i, j]] = augmented[[j, i]]
                    break
            else:
                return None

        for j in range(4):
            if j != i and augmented[j, i] == 1:
                augmented[j] ^= augmented[i]
    
    inverse = augmented[:, 4:]
    
    return inverse

# Function to map the values according to the CanrightInverter
def map_4bit (matrix, mapping):
    transformed = np.zeros_like(matrix)
    
    for i, row in enumerate(matrix):
        row_tuple = tuple(row)
        if row_tuple in mapping:
            transformed[i] = mapping[row_tuple]
        else: 
            raise ValueError(f"Row {row_tuple} not found in mapping.")
        
    return transformed

#Multiplicative Inverse in GF(2^4)
Inv = np.array([
    [0, 0, 0, 0],
    [0, 0, 0, 1],
    [1, 0, 0, 1],
    [1, 1, 1, 0],
    [1, 1, 0, 1],
    [1, 0, 1, 1],
    [0, 1, 1, 1],
    [0, 1, 1, 0],
    [1, 1, 1, 1],
    [0, 0, 1, 0],
    [1, 1, 0, 0],
    [0, 1, 0, 1],
    [1, 0, 1, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 1],
    [1, 0, 0, 0]
])

#PolynomialBase Input
PolyInput = np.array([
    [0, 0, 0, 0],
    [0, 0, 0, 1],
    [0, 0, 1, 0],
    [0, 0, 1, 1],
    [0, 1, 0, 0],
    [0, 1, 0, 1],
    [0, 1, 1, 0],
    [0, 1, 1, 1],
    [1, 0, 0, 0],
    [1, 0, 0, 1],
    [1, 0, 1, 0],
    [1, 0, 1, 1],
    [1, 1, 0, 0],
    [1, 1, 0, 1],
    [1, 1, 1, 0],
    [1, 1, 1, 1]
])

# Define your 4x4 matrix M
M = generate_all_4x4_gf2_matrices()

# Define a mapping for the 4-bit rows
mapping = {
    (0, 0, 0, 0): (0, 0, 0, 0),
    (0, 0, 0, 1): (0, 1, 0, 0),
    (0, 0, 1, 0): (1, 1, 0, 0),
    (0, 0, 1, 1): (1, 0, 0, 0),
    (0, 1, 0, 0): (0, 0, 0, 1),
    (0, 1, 0, 1): (1, 0, 1, 0),
    (0, 1, 1, 0): (1, 1, 1, 0),
    (0, 1, 1, 1): (1, 1, 0, 1),
    (1, 0, 0, 0): (0, 0, 1, 1),
    (1, 0, 0, 1): (1, 0, 1, 1),
    (1, 0, 1, 0): (0, 1, 0, 1),
    (1, 0, 1, 1): (1, 0, 0, 1),
    (1, 1, 0, 0): (0, 0, 1, 0),
    (1, 1, 0, 1): (0, 1, 1, 1),
    (1, 1, 1, 0): (0, 1, 1, 0),
    (1, 1, 1, 1): (1, 1, 1, 1)
}

for i in range(65536):
   
    if is_invertible(M[i]):
        M_inv = gf2_inverse(M[i]) 
        
        temp = gf2_matrix_multiply(PolyInput, M[i])
        mapped = map_4bit(temp, mapping)
        result = gf2_matrix_multiply(mapped, M_inv)
        
        if np.array_equal(result, Inv):
            print("Solution found:", i)
            print("Matrix M: \n", M[i])
            print("Matrix M_inv: \n", M_inv)
            
        #else:
        #    print("No solution: ", i)
               