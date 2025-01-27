import numpy as np
import random

def add(x, y):
    return x ^ y


def multiply(x, y):
    if x == 0b00 or y == 0b00:
        return 0b00
    elif (x == 0b01 and y == 0b11) or (x == 0b10 and y == 0b10) or (x == 0b11 and y == 0b01):
        return 0b01
    elif (x == 0b01 and y == 0b01) or (x == 0b10 and y == 0b11) or (x == 0b11 and y == 0b10):
        return 0b10
    else:
        return 0b11

    
def ABq(Ax, Ay, Bx, By, Z0, Z1):
    
    A_res = add(multiply(Ax, add(Ay, add(By, Z0))), add(multiply(Ax, Z0), Z1))
    B_res = add(multiply(Bx, add(By, add(Ay, Z0))), add(multiply(Bx, Z0), Z1))
    
    return [A_res, B_res]


def ABqx(Ax, Ay, Bx, By, Az, Bz, Z):
    
    A_res = add(add(multiply(Ax, add(add(Ay, Az), add(By, Bz))), multiply(Ax, Az)), add(multiply(Ax, Bz), Z))
    B_res = add(add(multiply(Bx, add(add(Ay, Az), add(By, Bz))), multiply(Bx, Bz)), add(multiply(Bx, Az), Z))

    return [A_res, B_res]


def bin4ToArr(x):
    return [int(bit) for bit in f"{x:04b}"]


def bin2ToArr(x):
    return [int(bit) for bit in f"{x:02b}"]


def readBin(x):
    return int("".join(map(str, x)), 2)


def split(x):
    return [x[0:2], x[2:4]]


def fuse(x,y):
    return x + y


def inv(x):
    return x[::-1]


def sqscl(x):
    return [x[0] ^ x[1], x[1]] 


def gf2_matrix_multiply(A, B):
    return (np.dot(A, B) % 2)


def SBox(A, B):

    az0 = random.randint(0,3)
    az1 = random.randint(0,3)
    az2 = random.randint(0,3)
    bz0 = random.randint(0,3)
    bz1 = random.randint(0,3)
    bz2 = random.randint(0,3)
    z0 = random.randint(0,3)
    z1 = random.randint(0,3)
    z2 = random.randint(0,3)
    rng = [az0, az1, az2, bz0, bz1, bz2, z0, z1, z2]
    #print("random shares:", rng)
    
    M_in = np.array([
        [0,0,0,1],
        [1,1,0,0],
        [0,1,1,0],
        [1,1,1,1]
    ])

    M_out = np.array([
        [1,0,0,0],
        [1,1,1,1],
        [0,1,0,0],
        [1,1,1,0]
    ])
    
    M_inv = np.array([
        [1,0,1,1],
        [1,1,1,1],
        [1,1,0,1],
        [1,0,0,0]
    ])
    
    transformed_A = gf2_matrix_multiply(bin4ToArr(A), M_in)
    transformed_B = gf2_matrix_multiply(bin4ToArr(B), M_in)
    #print("A transformed:", transformed_A, "B transformed:", transformed_B)
    
    A_gamma_1 = readBin(transformed_A[0:2])
    A_gamma_0 = readBin(transformed_A[2:4])
    B_gamma_1 = readBin(transformed_B[0:2])
    B_gamma_0 = readBin(transformed_B[2:4])
    #print("A_gamma_1:", A_gamma_1, "A_gamma_0:", A_gamma_0, "B_gamma_1:", B_gamma_1, "B_gamma_0:", B_gamma_0)
    
    A_gamma = A_gamma_0 ^ A_gamma_1
    B_gamma = B_gamma_0 ^ B_gamma_1
    
    A_sqscl = sqscl(bin2ToArr(A_gamma))
    B_sqscl = sqscl(bin2ToArr(B_gamma))
    #print("A scaled:", A_sqscl, "B scaled:", B_sqscl)
    
    dom = ABqx(A_gamma_1, B_gamma_0, B_gamma_1, A_gamma_0, az0, bz0, z0)
    #print("Gamma1 mult Gamma2:", dom)
    
    domA_Asqscl = readBin(A_sqscl) ^ dom[0]
    domB_Bsqscl = readBin(B_sqscl) ^ dom[1]
    
    A_inv = readBin(inv(bin2ToArr(domA_Asqscl)))
    B_inv = readBin(inv(bin2ToArr(domB_Bsqscl)))
    #print("Inverse A:",A_inv,"Inverse B:", B_inv)
    
    domA = ABqx(A_gamma_1, B_gamma_0, B_inv, A_inv, az1, bz1, z1)
    domB = ABqx(B_gamma_1, A_gamma_0, A_inv, B_inv, az2, bz2, z2)
    #print("Gamma1:", domA, "Gamma0:", domB)
    
    preA = fuse(bin2ToArr(domA[0]), bin2ToArr(domB[1]))
    preB = fuse(bin2ToArr(domA[1]), bin2ToArr(domB[0]))
    #print("preA:", preA, "preB:", preB)
   
    retransform_A = gf2_matrix_multiply(preA, M_out)
    retransform_B = gf2_matrix_multiply(preB, M_out)

    return [readBin(retransform_A) ^ 6, readBin(retransform_B) ^ 6], (readBin(retransform_B) ^ 6) ^ (readBin(retransform_A) ^ 6) 


for i in range(16):
    q = i
    r = random.randint(0,15)
    
    a = q ^ r
    b = r

    sbox = SBox(a, b)
    print(sbox)
