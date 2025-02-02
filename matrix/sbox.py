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


def indepABq(Ax, Ay, Bx, By, Z):
    
    A_res = add(multiply(Ax,Ay), add(multiply(Ax, By), Z))
    B_res = add(multiply(Bx,By), add(multiply(Bx, Ay), Z))
    
    return A_res, B_res


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


def sqscl(x, w):
    if w == 1:
        return [x[0] ^ x[1], x[1]] 
    else:
        return [x[0], x[1]^ x[0]] 


def gf2_matrix_multiply(A, B):
    return (np.dot(A, B) % 2)


def canright(x, m_in, m_out):
    
    transform = gf2_matrix_multiply(bin4ToArr(x), m_in)
    
    y = split(transform) # split(bin4ToArr(x)) 
    y_0 = readBin(y[1])
    y_1 = readBin(y[0])
    
    temp1 = y_0 ^ y_1
    scl = sqscl(bin2ToArr(temp1),1)
    y_01 = multiply(y_0, y_1)
    
    scl_y = readBin(scl) ^ y_01
    inverse = inv(bin2ToArr(scl_y))
    
    res1 = multiply(readBin(inverse), y_0)
    res0 = multiply(readBin(inverse), y_1)
    
    result = fuse(bin2ToArr(res1), bin2ToArr(res0))
    
    retransform = gf2_matrix_multiply(result, m_out)
    
    return readBin(retransform) # readBin(result)
    

first_in = np.array([
    [0,0,0,1],
    [1,1,0,0],
    [0,1,1,0],
    [1,1,1,1]
])

first_out = np.array([
    [1,0,0,0],
    [1,1,1,1],
    [0,1,0,0],
    [1,1,1,0]
])
    
first_inv = np.array([
    [1,0,1,1],
    [1,1,1,1],
    [1,1,0,1],
    [1,0,0,0]
])

second_in = np.array([
    [0,1,0,0],
    [0,0,1,1],
    [1,0,0,1],
    [1,1,1,1]
])

second_inv = np.array([
    [1,1,0,1],
    [1,0,0,0],
    [1,0,1,1],
    [1,1,1,1]
])

third_in = np.array([
    [0,1,1,1],
    [0,1,1,0],
    [0,0,1,1],
    [1,1,1,1]
])

third_inv = np.array([
    [1,0,0,1],
    [1,0,1,0],
    [1,1,1,0],
    [1,1,0,0]
])

fourth_in = np.array([
    [1,1,0,1],
    [1,0,0,1],
    [1,1,0,0],
    [1,1,1,1]
])

fourth_inv = np.array([
    [1,1,1,0],
    [1,1,0,0],
    [1,0,0,1],
    [1,0,1,0]
])

refirst_in = np.array([
    [0,1,0,0],
    [0,0,1,1],
    [1,0,0,1],
    [1,1,1,1]
])

refirst_out = np.array([
    [0,0,1,0],
    [1,1,1,1],
    [0,0,0,1],
    [1,0,1,1]
])


def inv_and_sbox(q, m_in, m_out):
    z0 = random.randint(0,3)
    z10 = random.randint(0,3)
    z1 = random.randint(0,3)
    z11 = random.randint(0,3)
    z2 = random.randint(0,3)
    z12 = random.randint(0,3)
    b = random.randint(0,15)
    a = q ^ b
    print("q, A, B:",q,a,b)
    
    a_tf = gf2_matrix_multiply(bin4ToArr(a), m_in)
    b_tf = gf2_matrix_multiply(bin4ToArr(b), m_in)
    
    a1 = readBin(split(a_tf)[0])
    a0 = readBin(split(a_tf)[1])
    b1 = readBin(split(b_tf)[0])
    b0 = readBin(split(b_tf)[1])
    # print("A1:", a1, "A0", a0, "B1:", b1, "B0:", b0)
    
    a01 = a0 ^ a1
    b01 = b0 ^ b1
    # print("XOR:",a01,b01)
    
    a_sq = sqscl(bin2ToArr(a01),1)
    b_sq = sqscl(bin2ToArr(b01),1)
    # print("SqScale:", a_sq, b_sq)
    
    dom = indepABq(a1, a0, b1, b0, z0)
    # print("0 X 1:", dom[0], dom[1])
    
    a_xor = dom[0] ^ readBin(a_sq)
    b_xor = dom[1] ^ readBin(b_sq)
    # print("Pre Inv:",a_xor, b_xor)
    
    a_inv = readBin(inv(bin2ToArr(a_xor)))
    b_inv = readBin(inv(bin2ToArr(b_xor)))
    # print("Post Inv:",a_inv, b_inv)
    
    dom1 = indepABq(a1, a_inv, b1, b_inv, z1)
    dom2 = indepABq(a_inv, a0, b_inv, b0, z2)
    # print("O X 1:",dom1[0], dom1[1])
    # print("O X 0:", dom2[0], dom2[1])
    
    res_a = fuse(bin2ToArr(dom2[0]), bin2ToArr(dom1[0])) # fuse(bin2ToArr(dom1[0]), bin2ToArr(dom2[0]))
    res_b = fuse(bin2ToArr(dom2[1]), bin2ToArr(dom1[1])) # fuse(bin2ToArr(dom1[1]), bin2ToArr(dom2[1]))
    
    a_outtf = gf2_matrix_multiply(res_a, m_out)
    b_outtf = gf2_matrix_multiply(res_b, m_out)
    
    
    
    return readBin(a_outtf), readBin(b_outtf), readBin(a_outtf) ^ readBin(b_outtf), readBin(a_outtf) ^ 6, readBin(b_outtf), (readBin(a_outtf) ^ 6) ^ readBin(b_outtf)
    
    
inverse = []
stransform = []
for i in range(16):
    
    t = inv_and_sbox(i, first_in, first_inv)
    s = inv_and_sbox(i, first_in, first_out)
    inverse.append(t[2])
    stransform.append(s[5])
    
print("Inverse:",inverse,"\nSBox:", stransform)    
